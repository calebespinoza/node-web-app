'use strict';

const express = require('express');

// Constants
//const PORT = 8080;
//const HOST = '0.0.0.0';

// App
const app = express();
app.get('/', (req, res) => {
  res.json({message: 'Hello World'});
});
app.get('/atlatam01', (req, res) => {
  res.json({message: 'Hello Bootcampers!!'});
});
app.get('/bye', (req, res) => {
  res.json({message: 'Bye Bootcampers!!'});
});

module.exports = app
