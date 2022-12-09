import React from 'react';
import { useNavigate } from 'react-router-dom';
import Typography from '@material-ui/core/Typography'
import { DataTable, Collapsible, Grommet } from 'grommet';
import JsonData from '../data.json';
import Columns from '../columns.json';
import CellNames from '../cellNames.json';
import * as styles from '../styles/HomeStyles';

const inputStyle = {
    marginRight: 10
};

const editButtonStyle = {
    display: 'block',
    width: 120,
    height: 30,
    borderWidth: 0,
    borderColor: "#29339B",
    borderRadius: 15,
    color: "white",
    backgroundColor: "#29339B",
    fontWeight: "bold"
}

const saveButtonStyle = {
    width: 70,
    height: 30,
    borderWidth: 0,
    borderColor: "#29339B",
    borderRadius: 15,
    color: "white",
    backgroundColor: "#29339B",
    fontWeight: "bold"
}


const Home = (props) => {
    const navigate = useNavigate();

    const [open, setOpen] = React.useState(false);

    const handleSubmit = (event) => {
        setOpen(!open);
        event.preventDefault();

        JsonData.map(x => Object.assign(x, CellNames.find(y => y.channelName === x.channelName)))

        /*console.log(event.target[1].value)
        console.log(event.target.elements.cellName.value)
        console.log(event.target.cellName.value)*/
    }

    return (
        <Grommet theme={styles.theme}>
            <styles.AppBar>
                <Typography variant="h6" color="inherit" noWrap>
                    Remaining Battery Life
                </Typography>
                <button primary onClick={() => setOpen(!open)} style={editButtonStyle}>Edit Cell Names</button>
                <Collapsible open={open} {...props}>
                    <div>
                        <form onSubmit={handleSubmit}>
                            <label style={inputStyle}>
                                Channel:
                                <input
                                    type="text"
                                    name="channelName"
                                />
                            </label>
                            <label style={inputStyle}>
                                New Cell Name:
                                <input
                                    type="text"
                                    name="cellName"
                                />
                            </label>
                            <button type="submit" style={saveButtonStyle}>Save</button>
                        </form>
                    </div>
                </Collapsible>
            </styles.AppBar>
            <styles.AppTable>
                <DataTable
                    columns={Columns}
                    data={JsonData.map(x => Object.assign(x, CellNames.find(y => y.name === x.name)))}
                    sortable="true"
                    sort={{ direction: "asc" | "desc", external: false, property: "status" }}
                    onClickRow={({ datum }) => {
                        const page = "battery/" + datum.name;
                        navigate(page, { state: datum })
                    }}
                />
            </styles.AppTable>
        </Grommet >
    );
}

export default Home;