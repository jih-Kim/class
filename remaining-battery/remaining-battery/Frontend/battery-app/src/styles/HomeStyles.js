import { Box } from 'grommet';

export const AppBar = (props) => (
    <Box
        tag='header'
        direction='row'
        align='center'
        justify='between'
        background='app-bar'
        pad={{ vertical: 'small', horizontal: 'medium' }}
        elevation='medium'
        {...props}
    />
);

export const AppCollapsible = (props) => (
    <Box
        background="light-2"
        round="medium"
        pad="medium"
        align="center"
        justify="center"
        {...props}
    />
);

export const AppTable = (props) => (
    <Box
        tag='header'
        display='flex'
        justify-content='space-between'
        align-items='center'
        flex-direction='row'
        background='white'
        pad={{ vertical: 'small', horizontal: 'medium' }}
        elevation='medium'
        {...props}
    />
);



export const theme = {
    global: {
        colors: {
            'dark-blue': '#29339B',
            'turqouise': '#7AE7C7',
            'blue-grey': '#75BBA7',
            'grey': '#645244',
            'light-2': '#f5f5f5',
            'light-3': '#9df5da',
            'app-bar': 'light-2',
            'app-bar2': '#f7f5e0',
            'text': {
                light: 'rgba(0, 0, 0, 0.87)',
            },
            control: 'light-2',
        },
        edgeSize: {
            small: '14px',
        },
        elevation: {
            light: {
                medium: '0px 2px 4px -1px rgba(0, 0, 0, 0.2), 0px 4px 5px 0px rgba(0, 0, 0, 0.14), 0px 1px 10px 0px rgba(0, 0, 0, 0.12)',
            },
        },
        font: {
            family: 'Roboto',
            size: '16px',
            height: '20px',
        },
    },
    button: {
        border: {
            width: '5px',
            radius: '2px',
            color: 'dark-blue'
        },
        color: 'black',
        padding: {
            vertical: '20px',
            horizontal: '10px',
        },
    },
    table: {
        alignSelf: 'center',
        body: {
            border: {
                color: 'dark-blue',
            },
        },
        header: {
            background: 'dark-blue',
            border: {
                size: "small",
                color: 'dark-blue',
            },
        }
    },
};
