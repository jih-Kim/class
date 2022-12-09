#detect the file change and run the client.py if it has been changed
time1 = 0
print("Type ctrl+c if you want to stop")
while True:
    try:
        time = os.path.getmtime("data.json")
        if time!=time1:
            os.system('python sendFile.py')
        time1 = time
    except KeyboardInterrupt:
        break