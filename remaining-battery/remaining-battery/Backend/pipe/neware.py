from ctypes import *
from ctypes.wintypes import *
import time
import string
import xml.dom.minidom 
import os
import tkinter
from tkinter import *
import datetime
from tkinter import ttk
import tkinter as tk
import tkinter.filedialog

GENERIC_READ = 0x80000000
GENERIC_WRITE = 0x40000000
OPEN_EXISTING = 0x3
INVALID_HANDLE_VALUE = -1
PIPE_READMODE_MESSAGE = 0x2
PIPE_TYPE_BYTE = 0x00000000
ERROR_PIPE_BUSY = 231
ERROR_MORE_DATA = 234
BUFSIZE = 2048

szPipename = u"\\\\.\\pipe\\NewareBtsAPI"

root = tkinter.Tk()
root.title(u'Neware API Tester')
root.geometry('600x450+500+300')
m = tkinter.Message(root,text = 'API Tester',width = 200,fg = 'blue',aspect = 400)
m.pack()
m.place(x = 240,y = 5)


ip = tkinter.Label(root,text = 'Server(mysql)IP:')
ip.pack(side = LEFT,padx = 20,pady = 10)
ip.place(x = 30, y = 50)
e = tkinter.StringVar()
add = tkinter.Entry(root,width = 50,textvariable = e)
add.pack(side = LEFT)
e.set('127.0.0.1')
add.place(x = 120, y = 50)


def callback():
    stepload.delete(0,END) #empty entry
     #Use filedialog askopenfilename() to open test profile
    #global filepath
    filepath = filedialog.askopenfilename()
    if filepath:
        stepload.insert(0,filepath) #Load path to entry
step = tkinter.Label(root,text = 'Test pofile path:')
step.pack(side = LEFT,padx = 20,pady = 10)
step.place(x = 30, y = 80)
e = tkinter.StringVar()
stepload = tkinter.Entry(root,width = 50,textvariable = e)
stepload.pack(side = LEFT)
e.set(os.getcwd()+"\\test.xml")
stepload.place(x = 120, y = 80)

button10 = Button(root,text = u"Test profile",fg = 'blue',bg = 'gray',width = 8,height = 1,command = callback)
button10.pack(side = RIGHT)
button10.place(x = 475,y = 78)



dev = tkinter.Label(root,text = 'Dev Type:')
dev.pack(side = LEFT,padx = 20,pady = 10)
dev.place(x = 30, y = 110)
e = tkinter.StringVar()
de = tkinter.Entry(root,width = 5,textvariable = e)
de.pack(side = LEFT)
e.set('24')
de.place(x = 100, y = 110)



zwj = tkinter.Label(root,text = 'Dev ID:')
zwj.pack(side = LEFT,padx = 20,pady = 10)
zwj.place(x = 30, y = 140)
e = tkinter.StringVar()
zw = tkinter.Entry(root,width = 5,textvariable = e)
zw.pack(side = LEFT)
e.set('3')
zw.place(x = 100, y = 140)
m6 = tkinter.Message(root,text = u'To',width = 200,fg = 'blue',aspect = 400)
m6.pack()
m6.place(x = 140,y = 140)
e = tkinter.StringVar()
devn = tkinter.Entry(root,width = 5,textvariable = e)
devn.pack(side = LEFT)
e.set('3')
devn.place(x = 170, y = 140)


unit = tkinter.Label(root,text = 'Unit ID:')
unit.pack(side = LEFT,padx = 20,pady = 10)
unit.place(x = 30, y = 170)
e = tkinter.StringVar()
un = tkinter.Entry(root,width = 5,textvariable = e)
un.pack(side = LEFT)
e.set('1')
un.place(x = 100, y = 170)
m7 = tkinter.Message(root,text = u'To',width = 200,fg = 'blue',aspect = 400)
m7.pack()
m7.place(x = 140,y = 170)
e = tkinter.StringVar()
ucu = tkinter.Entry(root,width = 5,textvariable = e)
ucu.pack(side = LEFT)
e.set('1')
ucu.place(x = 170, y = 170)



chl = tkinter.Label(root,text = 'Channel ID:')
chl.pack(side = LEFT,padx = 20,pady = 10)
chl.place(x = 30, y = 200)
e = tkinter.StringVar()
co = tkinter.Entry(root,width = 5,textvariable = e)
co.pack(side = LEFT)
e.set('1')
co.place(x = 100, y = 200)
m8 = tkinter.Message(root,text = u'To',width = 200,fg = 'blue',aspect = 400)
m8.pack()
m8.place(x = 140,y = 200)
e = tkinter.StringVar()
ccu = tkinter.Entry(root,width = 5,textvariable = e)
ccu.pack(side = LEFT)
e.set('8')
ccu.place(x = 170, y = 200)


chl_tz = tkinter.Label(root,text = 'Jump to:')
chl_tz.pack(side = LEFT,padx = 20,pady = 10)
chl_tz.place(x = 30, y = 230)
e = tkinter.StringVar()
co_tz = tkinter.Entry(root,width = 5,textvariable = e)
co_tz.pack(side = LEFT)
e.set('0')
co_tz.place(x = 100, y = 230)

v10=tkinter.StringVar()
ch10=tkinter.Checkbutton(root,variable = v10,text='Get Dev into',offvalue='0',onvalue='1')
ch10.pack(side=LEFT,padx = 20,pady = 10)
ch10.place(x = 30, y = 290)
v10.set('0')

v11=tkinter.StringVar()
ch11=tkinter.Checkbutton(root,variable = v11,text='Channel Start',offvalue='0',onvalue='1')
ch11.pack(side=LEFT,padx = 20,pady = 10)
ch11.place(x = 130, y = 290)
v11.set('0')

v12=tkinter.StringVar()
ch12=tkinter.Checkbutton(root,variable = v12,text='Stop',offvalue='0',onvalue='1')
ch12.pack(side=LEFT,padx = 20,pady = 10)
ch12.place(x = 230, y = 290)
v12.set('0')

v14=tkinter.StringVar()
ch14=tkinter.Checkbutton(root,variable = v14,text='Resume',offvalue='0',onvalue='1')
ch14.pack(side=LEFT,padx = 20,pady = 10)
ch14.place(x = 330, y = 290)
v14.set('0')

#Jump
v15=tkinter.StringVar()
ch15=tkinter.Checkbutton(root,variable = v15,text='Jump',offvalue='0',onvalue='1')
ch15.pack(side=LEFT,padx = 20,pady = 10)
ch15.place(x = 430, y = 290)
v15.set('0')

v16=tkinter.StringVar()
ch16=tkinter.Checkbutton(root,variable = v16,text='',offvalue='0',onvalue='1')
ch16.pack(side=LEFT,padx = 20,pady = 10)
ch16.place(x = 30, y = 350)
v16.set('0')
number16 = tk.StringVar()
numberChosen16 = ttk.Combobox(root, width=4, textvariable=number16, state='readonly')
numberChosen16.pack()
numberChosen16['values'] = ('Light on', 'Light off')     # Dropdown list
numberChosen16.grid(column=1, row=1)
numberChosen16.current(0)
numberChosen16.place(x = 50, y = 350)


    #DF data download
v17=tkinter.StringVar()
ch17=tkinter.Checkbutton(root,variable = v17,text='DF data download',offvalue='0',onvalue='1')
ch17.pack(side=LEFT,padx = 20,pady = 10)
ch17.place(x = 130, y = 320)
v17.set('0')
    #Real time data query
v18=tkinter.StringVar()
ch18=tkinter.Checkbutton(root,variable = v18,text='Real time data query',offvalue='0',onvalue='1')
ch18.pack(side=LEFT,padx = 20,pady = 10)
ch18.place(x = 230, y = 320)
v18.set('0')
    #DF data query
v19=tkinter.StringVar()
ch19=tkinter.Checkbutton(root,variable = v19,text='DF data query',offvalue='0',onvalue='1')
ch19.pack(side=LEFT,padx = 20,pady = 10)
ch19.place(x = 330, y = 320)
v19.set('0')
    #Channel status
v20=tkinter.StringVar()
ch20=tkinter.Checkbutton(root,variable = v20,text='Channel stat.',offvalue='0',onvalue='1')
ch20.pack(side=LEFT,padx = 20,pady = 10)
ch20.place(x = 430, y = 320)
v20.set('0')     
    #Connect
v21=tkinter.StringVar()
ch21=tkinter.Checkbutton(root,variable = v21,text='Connect',offvalue='0',onvalue='1')
ch21.pack(side=LEFT,padx = 20,pady = 10)
ch21.place(x = 30, y = 320)
v21.set('0') 
    #Broadcast off
v22=tkinter.StringVar()
ch22=tkinter.Checkbutton(root,variable = v22,text='Broadcast off',offvalue='0',onvalue='1')
ch22.pack(side=LEFT,padx = 20,pady = 10)
ch22.place(x = 130, y = 350)
v22.set('0') 
    #Channel on/off
v23=tkinter.StringVar()
ch23=tkinter.Checkbutton(root,variable = v23,text='',offvalue='0',onvalue='1')
ch23.pack(side=LEFT,padx = 20,pady = 10)
ch23.place(x = 230, y = 350)
v23.set('0')
number23 = tk.StringVar()
numberChosen23 = ttk.Combobox(root, width=10, textvariable=number23, state='readonly')
numberChosen23.pack()
numberChosen23['values'] = ('Channel on', 'Channel off')     
numberChosen23.grid(column=1, row=1) 
numberChosen23.current(0)
numberChosen23.place(x = 250, y = 350)

#Pipe class
class BtsPipe:
    def __init__(self, name):
        while True:
            self.hPipe = windll.kernel32.CreateFileW(name, GENERIC_READ | GENERIC_WRITE,
                                                     0, None, OPEN_EXISTING, 0, None)
            if (self.hPipe != INVALID_HANDLE_VALUE):
                 break
            else:
                print("Invalid Handle Value")
            if (windll.kernel32.GetLastError() != ERROR_PIPE_BUSY):
                print("Could not open pipe")
                return
            elif ((windll.kernel32.WaitNamedPipeA(szPipename, 20000)) ==0):
                print("Could not open pipe\n")
                return    
    def __del__(self):
        if self.isOK():
            windll.kernel32.CloseHandle(self.hPipe)
    def isOK(self):
        return self.hPipe != INVALID_HANDLE_VALUE
    def Write(self, strText):
        strSend = strText.encode("UTF-8")
        cbWritten = DWORD(0)
        fSuccess = windll.kernel32.WriteFile(self.hPipe, strSend, len(strSend),
                                             byref(cbWritten), None)
        if ((not fSuccess) or (len(strSend) != cbWritten.value)):
            print("Write File failed")
            return
        else:
            print("Number of bytes written:", cbWritten.value)
    def Read(self, strText, loop = False):
        while (True): # repeat loop if ERROR_MORE_DATA
            chBuf = create_string_buffer(BUFSIZE)
            cbRead = DWORD(0)
            
            fSuccess = windll.kernel32.ReadFile(self.hPipe, chBuf, BUFSIZE, byref(cbRead), None)
            if fSuccess == 1:
                print("Number of bytes read:", cbRead.value)
                print(chBuf.value.decode())
                strText += str(chBuf.value.decode())
            if fSuccess <= 0:
                print('Error exit!')
                break
            if '\n\n' in strText: #Protocol end                
                print('Resp is ok!')                
                print('\n\n')
                ParseXml(strText)
                if not loop and (windll.kernel32.GetLastError() != ERROR_MORE_DATA):                
                    return
#XML parse
def ParseXml(strXml):
    dom = xml.dom.minidom.parseString(strXml)
    root = dom.documentElement
    if root.nodeName == 'bts':
        print('bts is ok')
    else:
        print('error')
#
def Repeat(btsPipe, strSend, loop = False):
    btsPipe.Write(strSend)
    strResp = ''
    btsPipe.Read(strResp, loop)
def connect_test():
    print('0')
def getdevinfo():
    btsPipe = BtsPipe(szPipename)
    if not btsPipe.isOK():
        print('pipe open fail!')
        return
    test=u"""
<?xml version="1.0" encoding="UTF-8" ?>
<bts version="1.0">
<cmd>getdevinfo</cmd>
</bts>
\n\n"""
    Repeat(btsPipe, test, False)
def start(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount,barcode,step):
    num=devcount*unitcount*chlcount
    btsPipe = BtsPipe(szPipename)
    if not btsPipe.isOK():
        print('pipe open fail!')
        return
    test=u"""
<?xml version="1.0" encoding="UTF-8" ?>
<bts version="1.0">
<cmd>start</cmd>
<list count = \""""+str(num)+"""\">"""
    for i in range(devcount):
        devid=dev+i
        for ii in range(unitcount):
            unitid=unit+ii
            for iii in range(chlcount):
                chlid=chl+iii
                test=str(test)+"""
        <start ip=\""""+str(ip)+"""\" devtype=\""""+str(devtype)+"""\" devid=\""""+str(devid)+"""\" subdevid=\""""+str(unitid)+"""\" chlid=\""""+str(chlid)+"""\" barcode=\""""+str(barcode)+"""\">"""+str(step)+"""</start>"""
    test=str(test)+"""
</list>
</bts>
\n\n"""
    Repeat(btsPipe, test, False)

def stop(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount):
    num=devcount*unitcount*chlcount
    btsPipe = BtsPipe(szPipename)
    if not btsPipe.isOK():
        print('pipe open fail!')
        return
    test=u"""
<?xml version="1.0" encoding="UTF-8" ?>
<bts version="1.0">
<cmd>stop</cmd>
<list count = \""""+str(num)+"""\">"""
    for i in range(devcount):
        devid=dev+i
        for ii in range(unitcount):
            unitid=unit+ii
            for iii in range(chlcount):
                chlid=chl+iii
                test=str(test)+"""
          <stop ip=\""""+str(ip)+"""\" devtype=\""""+str(devtype)+"""\" devid=\""""+str(devid)+"""\" subdevid=\""""+str(unitid)+"""\" chlid=\""""+str(chlid)+"""\">true</stop>"""
    test=str(test)+"""
</list>
</bts>
\n\n"""
    Repeat(btsPipe, test, False)
def continue_test(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount):
    num=devcount*unitcount*chlcount
    btsPipe = BtsPipe(szPipename)
    if not btsPipe.isOK():
        print('pipe open fail!')
        return
    test=u"""
<?xml version="1.0" encoding="UTF-8" ?>
<bts version="1.0">
<cmd>continue</cmd>
<list count = \""""+str(num)+"""\">"""
    for i in range(devcount):
        devid=dev+i
        for ii in range(unitcount):
            unitid=unit+ii
            for iii in range(chlcount):
                chlid=chl+iii
                test=str(test)+"""
        <continue ip=\""""+str(ip)+"""\" devtype=\""""+str(devtype)+"""\" devid=\""""+str(devid)+"""\" subdevid=\""""+str(unitid)+"""\" chlid=\""""+str(chlid)+"""\" >true</continue>"""
    test=str(test)+"""
</list>
</bts>
\n\n"""
    Repeat(btsPipe, test, False)
def connect_test():
    btsPipe = BtsPipe(szPipename)
    if not btsPipe.isOK():
        print('pipe open fail!')
        return
    test=u"""
<?xml version="1.0" encoding="UTF-8" ?>
<bts version="1.0">
<cmd>connect</cmd>
<username>test</username>
<password>123</password>
<type>bfgs</type>
</bts>
\n\n"""
    Repeat(btsPipe, test, False)
def light(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount,dd):
    num=devcount*unitcount*chlcount
    btsPipe = BtsPipe(szPipename)
    if not btsPipe.isOK():
        print('pipe open fail!')
        return
    test=u"""
<?xml version="1.0" encoding="UTF-8" ?>
<bts version="1.0">
<cmd>light</cmd>
<list count = \""""+str(num)+"""\">"""
    for i in range(devcount):
        devid=dev+i
        for ii in range(unitcount):
            unitid=unit+ii
            for iii in range(chlcount):
                chlid=chl+iii
                test=str(test)+"""
          <light ip=\""""+str(ip)+"""\" devtype=\""""+str(devtype)+"""\" devid=\""""+str(devid)+"""\" subdevid=\""""+str(unitid)+"""\" chlid=\""""+str(chlid)+"""\">"""+str(dd)+"""</light>"""
    test=str(test)+"""
</list>
</bts>
\n\n"""
    Repeat(btsPipe, test, False)
def getchlstatus(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount):
    num=devcount*unitcount*chlcount
    btsPipe = BtsPipe(szPipename)
    if not btsPipe.isOK():
        print('pipe open fail!')
        return
    test=u"""
<?xml version="1.0" encoding="UTF-8" ?>
<bts version="1.0">
<cmd>getchlstatus</cmd>
<list count = \""""+str(num)+"""\">"""
    for i in range(devcount):
        devid=dev+i
        for ii in range(unitcount):
            unitid=unit+ii
            for iii in range(chlcount):
                chlid=chl+iii
                test=str(test)+"""
          <status ip=\""""+str(ip)+"""\" devtype=\""""+str(devtype)+"""\" devid=\""""+str(devid)+"""\" subdevid=\""""+str(unitid)+"""\" chlid=\""""+str(chlid)+"""\">true</status>"""
    test=str(test)+"""
</list>
</bts>
\n\n"""
    Repeat(btsPipe, test, False)
def download(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount):
    num=devcount*unitcount*chlcount
    btsPipe = BtsPipe(szPipename)
    if not btsPipe.isOK():
        print('pipe open fail!')
        return
    test=u"""
<?xml version="1.0" encoding="UTF-8" ?>
<bts version="1.0">
<cmd>download</cmd>
<list count = "1">"""
    for i in range(devcount):
        devid=dev+i
        for ii in range(unitcount):
            unitid=unit+ii
            for iii in range(chlcount):
                chlid=chl+iii
                test=str(test)+"""
          <download ip="127.0.0.1" devtype=\""""+str(devtype)+"""\" devid=\""""+str(devid)+"""\" subdevid=\""""+str(unitid)+"""\" chlid=\""""+str(chlid)+"""\" auxid="0" testid="0" startpos="1" count="1000">true</download>"""
    test=str(test)+"""
    </list>
</bts>
\n\n"""
    #print('>>>',test)
    Repeat(btsPipe, test, False)

def inquire(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount):
    num=devcount*unitcount*chlcount
    btsPipe = BtsPipe(szPipename)
    if not btsPipe.isOK():
        print('pipe open fail!')
        return
    test=u"""
<?xml version="1.0" encoding="UTF-8" ?>
<bts version="1.0">
<cmd>inquire</cmd>
<list count = \""""+str(num)+"""\">"""
    for i in range(devcount):
        devid=dev+i
        for ii in range(unitcount):
            unitid=unit+ii
            for iii in range(chlcount):
                chlid=chl+iii
                test=str(test)+"""
          <inquire ip=\""""+str(ip)+"""\" devtype=\""""+str(devtype)+"""\" devid=\""""+str(devid)+"""\" subdevid=\""""+str(unitid)+"""\" chlid=\""""+str(chlid)+"""\">true</inquire>"""
    test=str(test)+"""
</list>
</bts>
\n\n"""
    Repeat(btsPipe, test, False)
def broadcaststop(ip,devtype,dev,devcount):
    btsPipe = BtsPipe(szPipename)
    if not btsPipe.isOK():
        print('pipe open fail!')
        return
    test=u"""
<?xml version="1.0" encoding="UTF-8" ?>
<bts version="1.0">
<cmd>broadcaststop</cmd>
<list count = \""""+str(devcount)+"""\">"""
    for i in range(devcount):
        devid=dev+i
        test=str(test)+"""
          <stop ip=\""""+str(ip)+"""\" devtype=\""""+str(devtype)+"""\" devid=\""""+str(devid)+"""\">true</stop>"""
    test=str(test)+"""
</list>
</bts>
\n\n"""
    Repeat(btsPipe, test, False)

def chl_ctrl(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount,kz):
    num=devcount*unitcount*chlcount
    btsPipe = BtsPipe(szPipename)
    if not btsPipe.isOK():
        print('pipe open fail!')
        return
    test=u"""
<?xml version="1.0" encoding="UTF-8" ?>
<bts version="1.0">
<cmd>chl_ctrl</cmd>
               <list count = \""""+str(num)+"""\">"""
    for i in range(devcount):
        devid=dev+i
        for ii in range(unitcount):
            unitid=unit+ii
            for iii in range(chlcount):
                chlid=chl+iii
                test=str(test)+"""
<chl_ctrl ip=\""""+str(ip)+"""\" devtype=\""""+str(devtype)+"""\" devid=\""""+str(devid)+"""\" subdevid=\""""+str(unitid)+"""\" chlid=\""""+str(chlid)+"""\" >"""+str(kz)+"""</chl_ctrl>"""
    test=str(test)+"""
</list>
</bts>
\n\n"""
    Repeat(btsPipe, test, False)

def Goto(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount,step_tz):
    num=devcount*unitcount*chlcount
    btsPipe = BtsPipe(szPipename)
    if not btsPipe.isOK():
        print('pipe open fail!')
        return
    test=u"""
<?xml version="1.0" encoding="UTF-8" ?>
<bts version="1.0">
<cmd>goto</cmd>
<list count = \""""+str(num)+"""\">"""
    for i in range(devcount):
        devid=dev+i
        for ii in range(unitcount):
            unitid=unit+ii
            for iii in range(chlcount):
                chlid=chl+iii
                test=str(test)+"""
        <goto ip=\""""+str(ip)+"""\" devtype=\""""+str(devtype)+"""\" devid=\""""+str(devid)+"""\" subdevid=\""""+str(unitid)+"""\" chlid=\""""+str(chlid)+"""\"  step=\""""+str(step_tz)+"""\">true</goto>"""
    test=str(test)+"""       
</list>
</bts>
\n\n"""
    Repeat(btsPipe, test, False)
def inquiredf(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount):
    num=devcount*unitcount*chlcount
    btsPipe = BtsPipe(szPipename)
    if not btsPipe.isOK():
        print('pipe open fail!')
        return
    test=u"""
<?xml version="1.0" encoding="UTF-8" ?>
<bts version="1.0">
<cmd>inquiredf</cmd>
<list count = \""""+str(num)+"""\">"""
    for i in range(devcount):
        devid=dev+i
        for ii in range(unitcount):
            unitid=unit+ii
            for iii in range(chlcount):
                chlid=chl+iii
                test=str(test)+"""
<chl devtype=\""""+str(devtype)+"""\" devid=\""""+str(devid)+"""\" subdevid=\""""+str(unitid)+"""\" chlid=\""""+str(chlid)+"""\" testid="0"/>"""
    test=str(test)+"""
</list>
</bts>
\n\n"""
    #print(test)
    Repeat(btsPipe, test, False)


    
#Main function
def main():
    ip=add.get()
    step=stepload.get()
    devtype=de.get()
    dev=int(zw.get())
    devcount=int(devn.get())-int(zw.get())+1
    unit=int(un.get())
    unitcount=int(ucu.get())-int(un.get())+1
    chl=int(co.get())
    chlcount=int(ccu.get())-int(co.get())+1
<<<<<<< HEAD:Backend/docs/Neware-API-20210914.py
=======
    print("ip is " + str(ip))
    print("dev is "+str(devn.get()))
    print("zw is "+str(zw.get()))
    print("un is "+str(un.get()))
    print("ucu is "+str(ucu.get()))
    print("co is "+str(co.get()))
    print("ccu is "+str(ccu.get()))

>>>>>>> ad0dffe14b4301eb064e1c47aa9318cb50c0ca01:Backend/pipe/neware.py
    #print(step)
    #hs=int(v10.get())
    #sta=int(v11.get())
    #sto=int(v12.get())
    #con=int(v14.get())
    step_tz=int(co_tz.get())
    barcode='123'

    #Get dev info
    if int(v10.get())==1:
        getdevinfo()
    #Startup
    if int(v11.get())==1:
        start(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount,barcode,step)
    #Stop
    if int(v12.get())==1:
        stop(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount)
    #Resume
    if int(v14.get())==1:
        continue_test(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount)

    #Jump
    if int(v15.get())==1 and step_tz==0:
        print('>>>Please input jump step number')
    if int(v15.get())==1:
        Goto(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount,step_tz)

    #Light
    dd_light=str(numberChosen16.get())
    if dd_light=="Light on":
        dd="true"
    elif dd_light=="Light off":
        dd="false"
    else:
        print(">>>error:Channel light function error")
    if int(v16.get())==1:
        light(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount,dd)


    #DF data download
    if int(v17.get())==1 and int(devn.get())==int(zw.get()) and int(ucu.get())==int(un.get()) and int(ccu.get())==int(co.get()):
        download(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount)
    elif int(v17.get())==1:
        print('>>>DF data download works only on single channel, please reset DEVIT, UNIT ID and Channel ID')
    #real-time data query
    if int(v18.get())==1:
        inquire(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount)
    #DF data query
    if int(v19.get())==1:
        inquiredf(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount)
    #Channel status
    if int(v20.get())==1:
        getchlstatus(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount)
    #Connect
    if int(v21.get())==1:
        connect_test()
    #Broadcast stop
    if int(v22.get())==1:
        broadcaststop(ip,devtype,dev,devcount)
    #Channel on/off
    ch_kgkz=str(numberChosen23.get())
    if ch_kgkz=="Channel on":
        kz=1
    elif ch_kgkz=="Channel off":
        kz=0
    else:
        print(">>>error:Channel on/off function error")
    if int(v23.get())==1:
        chl_ctrl(ip,devtype,dev,devcount,unit,unitcount,chl,chlcount,kz)
    

#def cycle_start():
#    print('0')


button = tkinter.Button(root,text = u"Start",fg = 'blue',bg = 'gray',width = 8,height = 1,command = main)
button.pack(side = RIGHT)
button.place(x = 60,y = 400)

#button = tkinter.Button(root,text = u"Restart",fg = 'blue',bg = 'gray',width = 8,height = 1,command = cycle_start)
#button.pack(side = RIGHT)
#button.place(x = 150,y = 400)

root.mainloop()
