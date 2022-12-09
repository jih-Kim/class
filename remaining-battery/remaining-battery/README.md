# Remaining Battery

## To view frontend:
Note - Data will only update in real-time if the backend is running in the lab computer. Ensure that runner.py is running if the data seems to be outdated (should update approximately every 9 seconds on main page)

### Option 1: Open site running on server (Best for just viewing data/using site)
1. In your browser, navigate to http://10.90.75.220:8443/
2. Note: some features may not be available in all browsers (for example, Download Data is not available with Internet Explorer).
    This project was tested with both Chrome and Edge, and features should be available in up-to-date browsers. 
3. If the service which hosts the site has stopped, it should restart automatically - however, it can be restarted manually by opening the CI/CD jobs page, finding a row with name build, and clicking the circular arrow on the far right to restart the service. 

### Option 2: Development Server (Takes some time to start up, but good for developing)
1. Open terminal, in remaining-battery\Frontend\battery-app folder
2. The first time it's run, or if any packages have been updated, run `npm install`
3. To run, run `npm run "local start"`, and a browser window will open with the frontend (may take up to ~10 seconds)

### Option 3: From html (Takes time to build, but once built you can click on index file and open instantly on your local machine)
1. Open build/index.html (inside of Frontend\battery-app folder) and run in your preferred browser
    Has been tested with Chrome & Edge
2. If build folder does not exist, in remaining-battery\Frontend\battery-app:
    1. run `npm install`
    2. run `npm run build` to create the build folder
    3. Open build/index.html (inside of Frontend\battery-app folder) and run in your preferred browser

# External Packages Used
- Material-ui
- Grommet
- React
- Victory
