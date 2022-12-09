import socket
import tqdm
import os
import ast

SEPARATOR = "<SEPARATOR>"
BUFFER_SIZE = 4096

##host = "127.0.0.1"
host = "10.90.75.220"
port = 8080
filename = "data.json"
filesize = os.path.getsize(filename)

s = socket.socket()

s.connect((host,port))

#send the filename and size
s.send(f"{filename}{SEPARATOR}{filesize}".encode())
#start sending file
progress = tqdm.tqdm(range(filesize),f"Sending {filename}",unit="B",unit_scale=True,unit_divisor=1024)
with open(filename,"rb") as f:
    while True:
        bytes_read = f.read(BUFFER_SIZE)
        if not bytes_read:
            break
        s.sendall(bytes_read)
        progress.update(len(bytes_read))
s.close()
print("finish?")