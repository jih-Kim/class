import { render, screen } from '@testing-library/react';
import React from 'react';
import { Simulate } from 'react-dom/test-utils';
import { BrowserRouter } from 'react-router-dom';
import Battery from '../components/Battery.js';

const Data = {
  "name": "1",
  "status": "Rest",
  "cycle": "1",
  "current": "0.1238",
  "voltage": "15",
  "capacity": "0.2371",
  "energy": "0.9254",
  "cycleLife": "98.7361"
};

const mockHistoryPush = jest.fn();
jest.mock('react-router-dom', () => ({
  ...jest.requireActual('react-router-dom'),
  useHistory: () => ({
    push: mockHistoryPush,
  }),
  useLocation: () => ({
    pathname: "/",
    state: { Data }
  })
}));


//verifies that main dashboard includes title
test('has chart', () => {
  render(<BrowserRouter><Battery /></BrowserRouter>);
  const graphPanel = screen.queryByRole('tabpanel');
  expect(graphPanel).toBeInTheDocument();
});

test('has back button', () => {
  render(<BrowserRouter><Battery /></BrowserRouter>);
  const el = screen.getByText('Back');
  expect(el).toBeInTheDocument();
});

test('has tab context', () => {
  render(<BrowserRouter><Battery /></BrowserRouter>);
  var list = [];
  list.push(screen.getByText('Q-V Curve'));
  list.push(screen.getByText('Capacity Fade Curve'));
  list.push(screen.getByText('Time -- Voltage and Current'));
  list.push(screen.getByText('Capacity -- Voltage'));
  list.push(screen.getByText('Time -- Capacity and Capacity Density'));
  expect(list.length == 5);
});

test('tab clickable', () => {
  render(<BrowserRouter><Battery /></BrowserRouter>);
  const el = screen.getByText('Q-V Curve');
  expect(el).toBeInTheDocument;
  Simulate.click(el);
});