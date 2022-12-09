# datareader.py
from ctypes import *
from ctypes.wintypes import *
import xml.dom.minidom as xm
import time
import pandas as pd
from nda_parser import new_nda

GENERIC_READ = 0x80000000
GENERIC_WRITE = 0x40000000
OPEN_EXISTING = 0x3
INVALID_HANDLE_VALUE = -1
PIPE_READMODE_MESSAGE = 0x2
PIPE_TYPE_BYTE = 0x00000000
ERROR_PIPE_BUSY = 231
ERROR_MORE_DATA = 234
BUFSIZE = 2048
NEWARE_PIPE_PATH = u'\\\\.\\pipe\\NewareBtsAPI'


class DataReader:
	""" DataReader is a wrapper-class for Neware Battery Testing System BTSAPI 
	Protocol.
	"""

	def __init__(self):
		# Connects to BTSAPI file pipe.
		self.pipe = windll.kernel32.CreateFileW(NEWARE_PIPE_PATH, 
		                                        GENERIC_READ|GENERIC_WRITE, 0, 
																						None, OPEN_EXISTING, 0, None)
		if self.pipe == INVALID_HANDLE_VALUE:
			print('Invalid pipe_handle')
			exit()

		# Makes a request to connect to Neware API
		connect_params = u"""
			<username>test</username>
			<password>123</password>
			<type>Bfgs</type>
			"""
		response = self.__make_request('connect', connect_params)
		if get_xml_node_value(response, 'result') == 'fail':  # expects 'ok'
			print('Failed to connect to BTSAPI')
			exit()

	def get_device_info(self):
		""" Fetches a table of available channels.
 
		Use this function to list all channels created in BTSAPI. The table
		contains information to identify each channel. Use this information 
		to call other functions that reads data from a specific channel. 

		Returns:
			A pandas DataFrame containing all available channels.
		"""
		response = self.__make_request('getdevinfo')
		df = pd.read_xml(response, xpath='.//channel')
		return df

	def get_channel_status(self, channel_id):
		""" Fetches the status of given channel.

		Args:
			channel_id: A dict containing the keys; "ip", "devtype", "devid", 
				"subdevid", "chlid". The value of every key is a string.

		Returns:
			A string describing the status of given channel.
			The possible status are {working, stop, finish, protect, pause}
		"""

		chl = channel_id
		status_params = u"""
			<list count="1">
				<status ip="{}" devtype="{}" devid="{}" subdevid="{}" chlid="{}">true
				</status>
			</list>
			""".format(chl['ip'], chl['devtype'], chl['devid'], chl['subdevid'],
			           chl['chlid'])
		response = self.__make_request('getchlstatus', status_params)		
		return response

	def get_channel_full_data(self, channel_id, column_filter=''):
		""" Fetches entire time series data of given channel.

		Args:
			channel_id: A dict containing the keys; "ip", "devtype", "devid", 
				"subdevid", "chlid". The value of every key is a string.
			column_filter: A list of strings containing column names to return. For
				any column returned by BTSAPI, but not found in this list is dropped.
				To return all columns, use the default parameter. 

		Returns:
			A pandas DataFrame containing the full historical data of a valid channel.
			If the provided channel identifier is invalid, returns None.
		"""

		chl = channel_id		
		download_params = u"""
		<list count = "1">
			<download ip="{}" devtype="{}" devid="{}" subdevid="{}" chlid="{}" 
			auxid="0" testid="0" startpos="1" count="1000">true</download>
		</list>
		""".format(chl['ip'], chl['devtype'], chl['devid'], chl['subdevid'],
			           chl['chlid'])
		response = self.__make_request('download', download_params)
		nda_file_path = get_xml_node_value(response, 'download')
		
		if nda_file_path == 'false':  # checks if data is available
			return None
		else:
			df = new_nda(nda_file_path, testcols=False, split=False, small=False)
			df.set_index('record_ID', inplace=True)
			return df

	def get_channel_update(self, channel_id):
		""" Fetches the latest update of a given channel.

		Args:
			channel_id: A dict containing the keys; "ip", "devtype", "devid", 
				"subdevid", "chlid". The value of every key is a string.

		Returns:
			A string containing the latest update in xml. 
		"""
		
		chl = channel_id
		update_params = u"""
				<list count = "1">
					<inquire ip="{}" devtype="{}" devid="{}" subdevid="{}" chlid="{}" 
					aux="0">true</inquire>
				</list>
			""".format(chl['ip'], chl['devtype'], chl['devid'], chl['subdevid'],
			           chl['chlid'])

		response = self.__make_request('inquire', update_params)
		# Currently, returns xml string
		# TODO: parse xml string into pandas/json
		return response  

	def __make_request(self, command_id, params=''):
		""" 
		Args:
			command_id: A string containing the command name.
			params: A string containing additional parameters in the request.
		"""

		request_message = u"""
			<?xml version="1.0" encoding="UTF-8" ?>
			<bts version="1.0">
			<cmd>{}</cmd>
			{}
			</bts>
			\n\n""".format(command_id, params)

		byte_written = DWORD(0)
		write_flag = windll.kernel32.WriteFile(
			self.pipe,
			request_message.encode('UTF-8'),
			len(request_message),
			byref(byte_written),
			None)

		response = ''
		while '\n\n' not in response:
			read_buffer = create_string_buffer(BUFSIZE)
			byte_read = DWORD(0)
			read_flag = windll.kernel32.ReadFile(
				self.pipe,
				read_buffer,
				BUFSIZE,
				byref(byte_read),
				None)
			response += str(read_buffer.value.decode())
			if '</bts>' in response:
				break
				
		return response

	def __del__(self):
		if self.pipe != INVALID_HANDLE_VALUE:
			windll.kernel32.CloseHandle(self.pipe)
	 

def get_xml_node_value(xml_string, tag_name):
	dom = xm.parseString(xml_string)
	elements = dom.getElementsByTagName(tag_name)
	node = elements[0]
	value = node.firstChild.nodeValue
	return value