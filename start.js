// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

// App
const app = require('./server.js');
app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);
