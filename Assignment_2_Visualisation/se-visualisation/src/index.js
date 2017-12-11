import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import registerServiceWorker from './registerServiceWorker';

var jsonData = require('./data.json');

ReactDOM.render(<App data={jsonData}/>, document.getElementById('root'));
registerServiceWorker();
