import shutil
import os
import time

#absolute path
src_path = r"data.json"
dst_path = r"../../../../Frontend/battery-app/src/data.json"
print("Type ctrl+c if you want to stop")
while(True):
    try:
	shutil.move(src_path, dst_path)
	time.sleep(5)
    except keyboardInterrupt:
	break
