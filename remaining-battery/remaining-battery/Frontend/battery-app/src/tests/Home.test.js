import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';
import { BrowserRouter } from 'react-router-dom';
import App from './../components/App.js';
import JsonData from './../data.json';

//verifies that main dashboard includes title
test('has title', () => {
  render(<BrowserRouter><App /></BrowserRouter>);
  const title = screen.getByText(/Remaining Battery Life/i);
  expect(title).toBeInTheDocument();
});

//verifies that main dashboard includes data table structure
test('has table', () => {
  render(<BrowserRouter><App /></BrowserRouter>);
  const table = screen.queryByRole('table');
  expect(table).toBeInTheDocument();
});

//verifies that main dashboard data file is non-empty
test('has data', () => {
  expect(JsonData.length > 0);
});

//finds first item in the table (should be row 1 name), clicks on the row and verifies that battery page opens
test('row click event', () => {
  render(<BrowserRouter><App /></BrowserRouter>);
  var row = JsonData[0];
  var vals = Object.values(row);
  var first = vals[0];
  const list = screen.getAllByText(first);
  const el = list[0];
  el.props = row;
  expect(el).toBeInTheDocument();
  fireEvent.click(el);
  const back = screen.getByText('Back');
  expect(back).toBeInTheDocument();
});