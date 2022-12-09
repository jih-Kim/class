import { Box } from 'grommet';
import { VictoryLine, VictoryAxis, VictoryLabel, VictoryScatter } from 'victory';




export function TabPanel(props) {
    const { children, value, index, ...other } = props;

    return (
        <Box
            role="tabpanel"
            hidden={value !== index}
            id={`simple-tabpanel-${index}`}
            aria-labelledby={`simple-tab-${index}`}
            width='100%'
            {...other}
        >
            {value === index && (
                <Box>{children}</Box>
            )}
        </Box>
    );
}



export const Indicator = {
    style: {
        backgroundColor: '#29339B',
        height: "3px",
        borderRadius: "2px"
    }
};


export const graphTheme = {
    axis: {
        crossAxis: false
    },
    grid: {
        stroke: 'none'
    }, ticks: { stroke: "grey", size: 5 },
    tickLabels: { fontSize: 12, padding: 5 },
    data: {
        stroke: 'blue',
        strokeWidth: 1,
    },
    offsetY: 30,
    size: 3,
    'aria-label': 'plots',
    selectedTabClassName: 'SelectedTab',
    padding: 0,
    TabIndicatorProps: {
        Indicator
    },
};


export const DepAxis = (props) => (
    <VictoryAxis className='Dependent'
        dependentAxis={true}
        axisLabelComponent={<VictoryLabel dy={-5} />}
        style={graphTheme}
        {...props}
    />
);
export const StyledLine = (props) => (
    <VictoryLine
        interpolation='linear'
        x='x'
        y='y'
        {...props}
    />
);

export const Scatter = (props) => (
    <VictoryScatter
        padding={20}
        size={3} //changes size of points, not whole graph
        {...props}
    />
);

export const DownloadButton = (data) => (
    <a className='Download'
        href={`data:text/json;charset=utf-8,${encodeURIComponent(
            JSON.stringify(data)
        )}`}
        download="downloadedData.json"
        justify-content="center"
    >
        {`Download Json Data`}
    </a>
);
