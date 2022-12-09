# Documentation

## data_reader.py
**Usage Example**
```python
from data_reader import DataReader

dr = DataReader()

# Unused channel for testing. Use a "live" channel when downloading full historical data. 
channel_id = {"ip": "127.0.0.1", "devtype":"22", "devid":"54", "subdevid":"8", "chlid":"5"}

# Returns DataFrame containing basic information on available channels
devices = dr.get_device_info()

# Returns string indicating channel status.
chl_status = dr.get_channel_status(channel_id)

# Returns DataFrame containing full historical data of channel.
chl_data = dr.get_channel_full_data(channel_id)

# Returns xml string containing latest readings of variables.
chl_update = dr.get_channel_update(channel_id)
```

For function calls that fetches data of a specific channel, you need to pass a `dict` with specific keys as parameter. Refer to `channel_id` in the example for the expected keys and values. Call `get_device_info()` to fetch a `DataFrame` containing the channel information you need for other function calls.


**Setup**
1. Requires nda_parser.py placed in the same directory.
2. Runs only on the project's (battery testing) lab machine.

---


## plot.py
```python
# Returns capacity fade curve for the given [unit]-[channel]
graph_data = get_capacity_fade_curve(unit_id, channel_id)
```