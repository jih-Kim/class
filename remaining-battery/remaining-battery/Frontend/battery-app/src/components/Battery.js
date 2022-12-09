import React from 'react';
import { Tab, Tabs } from '@mui/material'
import TabContext from '@mui/lab/TabContext';
import { Box, Button, Grommet } from 'grommet';
import { useParams, useLocation, useNavigate } from "react-router-dom";
import { VictoryChart, VictoryAxis } from 'victory';
import * as home from '../styles/HomeStyles';
import * as styles from '../styles/BatteryStyles';
import '../styles/Battery.css';

const battData = {
    number: '97-3-1',
    startTime: '2022-02-03 17:56:06',
    stepID: 1,
    stepName: 'Chg3',
    stepTime: '01:22:02',
    voltage: '4.1040',
    voltRange: '5',
    current: '-0.12518',
    cutOffCurr: '5.5',
    capacity: '0.00208',
    cycle: '7',
    cycleCapacity: '81.35'
};


function propsHelp(index) {
    return {
        id: `simple-tab-${index}`,
        'aria-controls': `simple-tabpanel-${index}`,
    };
}

const graphData = [
    { x: 0, y: 2 },
    { x: 5, y: 2.5 },
    { x: 10, y: 4 },
    { x: 15, y: 5 },
    { x: 20, y: 3 },
    { x: 25, y: 1 },
    { x: 30, y: 3 }
];

const QVCurveData = [
    { x: 0, y: 50 },
    { x: 0.2, y: -35 },
    { x: 0.3, y: -115 },
    { x: 0.4, y: -160 },
    { x: 0.5, y: -175 },
    { x: 0.6, y: -170 },
    { x: 0.7, y: -155 },
    { x: 0.8, y: -135 },
    { x: 0.9, y: -105 },
    { x: 1, y: -40 },
    { x: 1.1, y: 85 }
];

const CapFadeData = [
    { x: 0, y: 1.08 },
    { x: 200, y: 1.07 },
    { x: 400, y: 1.06 },
    { x: 600, y: 1.04 },
    { x: 800, y: 1.02 },
    { x: 1000, y: 0.9 }
];


const Battery = (props) => {
    //const params = useParams();
    const { state } = useLocation();
    const navigate = useNavigate();
    //const string = '-1';
    const [value, setValue] = React.useState(0);

    return (
        <>
            <Grommet theme={home.theme}>
                <Box >
                    <Box className='MainView'>
                        <Box className='Title' direction='row'>
                            <p className='BattNum'>Dev-Unit Channel #{state.name}</p>
                            <p className='StartTime'>Start Time: {battData.startTime}</p>
                            <p><button className='Back' onClick={() => navigate(-1)}>Back</button></p>
                        </Box>
                        <TabContext value={value.toString()} >
                            <Box
                                sx={{ borderBottom: 1, borderColor: 'divider' }}
                                className='TabsBox'
                            >
                                <Tabs className='Tabs'
                                    value={value}
                                    onChange={(event, newValue) => {
                                        setValue(newValue);
                                    }}
                                    TabIndicatorProps={
                                        styles.Indicator
                                    }
                                    variant="scrollable"
                                >
                                    <Tab label='Q-V Curve' className='Tab'
                                        wrapped {...propsHelp(0)} />
                                    <Tab label='Capacity Fade Curve' className='Tab'
                                        wrapped{...propsHelp(1)} />
                                    <Tab label='Time -- Voltage and Current' className='Tab'
                                        wrapped {...propsHelp(2)} />
                                    <Tab label='Capacity -- Voltage' className='Tab'
                                        wrapped{...propsHelp(3)} />
                                    <Tab label='Time -- Capacity and Capacity Density' className='Tab'
                                        wrapped {...propsHelp(4)} />
                                </Tabs>
                            </Box>

                            {/* Q-V Curve */}
                            <styles.TabPanel value={value} index={0} width='100%' >
                                <Box direction='row'>
                                    <Box className='Graphs' >
                                        <styles.DownloadButton data={QVCurveData} />
                                        <VictoryChart data={QVCurveData} className='Graph'>

                                            <styles.Scatter
                                                data={QVCurveData}
                                                style={styles.graphTheme}
                                            />
                                            <styles.StyledLine
                                                domain={{ x: [0, 1.1], y: [-200, 150] }}
                                                data={QVCurveData}
                                                style={styles.graphTheme} />
                                            <VictoryAxis
                                                label='Voltage (V)'
                                                offsetY={50}
                                                style={styles.graphTheme} />
                                            <styles.DepAxis
                                                label='Q (MVar)'
                                                style={styles.graphTheme}
                                            />
                                        </VictoryChart>
                                    </Box>
                                    <Box className='Graphs' >
                                        <styles.DownloadButton data={QVCurveData} />
                                        <VictoryChart data={QVCurveData} className='Graph'>
                                            <styles.Scatter
                                                data={QVCurveData}
                                                style={styles.graphTheme}
                                            />
                                            <styles.StyledLine
                                                domain={{ x: [0, 1.1], y: [-200, 150] }}
                                                data={QVCurveData}
                                                style={styles.graphTheme} />
                                            <VictoryAxis
                                                label='Capacity (Ah)'
                                                offsetY={50}
                                                style={styles.graphTheme} />
                                            <styles.DepAxis
                                                label={'dV/dQ(V Ah⁻¹)'}
                                                style={styles.graphTheme}>

                                            </styles.DepAxis>
                                        </VictoryChart>
                                    </Box>
                                </Box>
                                <Box direction='row'>
                                    <Box className='Graphs' >
                                        <styles.DownloadButton data={QVCurveData} />
                                        <VictoryChart data={QVCurveData} className='Graph'>
                                            <styles.Scatter
                                                data={QVCurveData}
                                                style={styles.graphTheme}
                                            />
                                            <styles.StyledLine
                                                domain={{ x: [0, 1.1], y: [-200, 150] }}
                                                data={QVCurveData}
                                                style={styles.graphTheme} />
                                            <VictoryAxis
                                                label='Voltage (V)'
                                                offsetY={50}
                                                style={styles.graphTheme} />
                                            <styles.DepAxis
                                                label={'dQ/dV(Ah V⁻¹)'}
                                                style={styles.graphTheme}>

                                            </styles.DepAxis>
                                        </VictoryChart>
                                    </Box>
                                </Box>
                            </styles.TabPanel>

                            {/* Capacity Fade Curve */}
                            <styles.TabPanel value={value} index={1}>
                                <Box className='Graphs'>
                                    <styles.DownloadButton data={CapFadeData} />
                                    <VictoryChart data={CapFadeData} className='Graph'>
                                        <styles.Scatter
                                            data={CapFadeData}
                                            style={styles.graphTheme}
                                        />
                                        <styles.StyledLine
                                            domain={{ x: [0, 1000], y: [0.85, 1.1] }}
                                            data={CapFadeData}
                                            style={styles.graphTheme}
                                        />
                                        <VictoryAxis
                                            label='Cycle / N'
                                            style={styles.graphTheme}
                                        />
                                        <styles.DepAxis
                                            label='Discharge Capacity (Ah)'
                                            style={styles.graphTheme}
                                        />
                                    </VictoryChart>
                                </Box>
                            </styles.TabPanel>

                            {/* Time -- Voltage and Current */}
                            <styles.TabPanel value={value} index={2}>
                                <Box className='Graphs'>
                                    <styles.DownloadButton data={graphData} />
                                    <VictoryChart data={graphData} className='Graph'>
                                        <styles.Scatter
                                            data={graphData}
                                            style={styles.graphTheme}
                                        />
                                        <styles.StyledLine
                                            domain={{ x: [0, 40], y: [0, 6] }}
                                            data={graphData}
                                            style={styles.graphTheme}
                                        />
                                        <VictoryAxis
                                            label='Time (sec)'
                                            style={styles.graphTheme}
                                        />
                                        <styles.DepAxis
                                            label='Voltage (V)'
                                            style={styles.graphTheme}
                                        />
                                    </VictoryChart>
                                </Box>
                            </styles.TabPanel>
                        </TabContext>
                    </Box>
                </Box >
            </Grommet >
        </>
    );
}

export default Battery;
