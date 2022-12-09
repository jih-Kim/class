import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Home from './Home';
import Battery from './Battery';

const App = () => {
    return (
        <Routes>
            < Route exact path='/' element={<Home />} > </Route>
            < Route exact path='/battery/:id' element={<Battery />} > </Route>
        </Routes>
    );
}

export default App;