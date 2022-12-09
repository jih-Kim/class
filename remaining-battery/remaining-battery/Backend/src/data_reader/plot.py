from nda_parser import new_nda
import numpy as np
import pandas as pd
from scipy import interpolate
import matplotlib.pyplot as plt
from data_reader import DataReader


dr = DataReader()

def resample_step(df):
    rules = {'timestamp':'first', 'step_name':'first', 'time_in_step': 'last', 
             'voltage_V': 'last', 'current_mA':'last', 'capacity_mAh':'last', 
             'energy_mWh':'last'}
    return df.groupby('step_ID').agg(rules)


def get_capacity_fade_curve(unit_id: str, chl_id: str):
    """ Returns capacity fade curve data for the given channel.

    Args:
        unit_id  unit id
        chl_id channel id
    
    Returns:
        A list of dict (json objects) containing the x (step) and y (capacity) values.
        [{"x": "1", "y": "0.5",
        ...
        ...
        }]
    """
    channel_id = {"ip": "127.0.0.1", "devtype":"22", "devid":"54", "subdevid":unit_id, "chlid":chl_id}
    df = dr.get_channel_full_data(channel_id)
    df = resample_step(df)
    df = df.loc[df.step_name == 'CCCV_Chg']
    df = df.iloc[1:].copy()
    df.rename(columns={'capacity_mAh': 'y'}, inplace=True)
    df['x'] = df.index
    return df[['x', 'y']].to_json(orient='records')