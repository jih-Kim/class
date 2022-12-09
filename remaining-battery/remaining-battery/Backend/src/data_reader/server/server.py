import socket
import tqdm
import os

serverIP = "0.0.0.0"
serverPort = 8080

BUFFER_SIZE = 4096
SEPARATOR = "<SEPARATOR>"

s = socket.socket()

s.bind((serverIP,serverPort))

s.listen(5)
print("Type ctrl+c to stop the server\n")

while True:

    try:
        c, add = s.accept()

        print(f"[+] {add} is connected.")

        received = c.recv(BUFFER_SIZE).decode()
        filename, filesize = received.split(SEPARATOR)

        filename = os.path.basename(filename)
        filesize = int(filesize)

        progress = tqdm.tqdm(range(filesize), f"Receiving {filename}",unit="B",unit_scale=True,unit_divisor=1024)
        with open(filename, "wb") as f:
            while True:
                bytes_read = c.recv(BUFFER_SIZE)
                if not bytes_read:
                    break
                f.write(bytes_read)
                progress.update(len(bytes_read))

        c.close()
        print("finish try return to while")
    except KeyboardInterrupt:
        s.close()
        break