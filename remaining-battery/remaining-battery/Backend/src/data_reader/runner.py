"""
    Stores channel information in 'data.json' on a loop.
"""
import json
import pandas as pd

from data_reader import DataReader
from data_reader import get_xml_node_value
import time
dr = DataReader()

#We need to get all active channels and call get_channel_update for each channel

# Unused channel for testing. Use a "live" channel when downloading full historical data. 
channel_id = {"ip": "127.0.0.1", "devtype":"22", "devid":"54", "subdevid":"8", "chlid":"5"}

# Returns DataFrame containing basic information on available channels

def parse_channel_ids(df):
    df.rename({"Channelid": "chlid"}, axis='columns', inplace=True)
    df.drop('channel', axis=1, inplace=True)
    return df.to_dict('records')
 
def make_update_info_json(channel_ids):
    df_lists = [pd.read_xml(x, xpath='.//inquire') for x in channel_ids]
    df = pd.concat(df_lists, axis=0)
    column_name_map = {'workstatus':'status', 'relativetime':'cycleLife', 'step_id':'cycle'}
    df.rename(columns=column_name_map, inplace=True)
    df['name'] = [x[-5:-2] for x in df.dev.to_list()]
    df.drop(['step_type', 'auxtemp', 'auxvol', 'dev'], axis=1, inplace=True)
    return df.to_json(orient='records')



# Returns string indicating channel status.
# chl_status = dr.get_channel_status(channel_id)

# Returns DataFrame containing full historical data of channel.
# chl_data = dr.get_channel_full_data(channel_id)

# Returns xml string containing latest readings of variables.
# chl_update = dr.get_channel_update(channel_id)

# print(chl_update)

while True:
    devices = dr.get_device_info()
    channel_ids = parse_channel_ids(devices)

    # Filter out working channels
    active_channels = channel_ids
    # active_channels = []
    # for dev in devices:
    #     channel_status = get_xml_node_value(dr.get_channel_status(dev), 'status')
    #     if channel_status == 'working':
    #         active_channels.append(dev)

    # Get latest
    active_channel_info = []
    for channel in active_channels:
        active_channel_info.append(dr.get_channel_update(channel))

    data = make_update_info_json(active_channel_info)
    f = open('data.json', 'w')
    f.write(data)
    f.close()

    time.sleep(2)