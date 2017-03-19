var express    = require('express');
var app        = express();
var bodyParser = require('body-parser');
var routes     = require('./routes');

var mongoose = require("mongoose");
mongoose.connect('mongodb://localhost/restdb')

// var uristring = 'mongodb://heroku_txjq8jr7:1hsdjvrs0u9pi35q4i9q2k3nt4@ds015335.mlab.com:15335/heroku_txjq8jr7'

// mongoose.connect(uristring, function (err, res) {
//     if (err) {
//       console.log ('ERROR connecting to: ' + uristring + '. ' + err);
//     } else {
//       console.log ('Succeeded connected to: ' + uristring);
//     }
// });
 
// express app will use body-parser to get data from POST
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
 
// Set port
var port = process.env.PORT || 8080;        // set the port
 
// Define a prefix for all routes	
// Can define something unique like MyRestAPI
// We'll just leave it so all routes are relative to '/'
app.use('/', routes);
 
// Start server listening on port 8080
app.listen(port);
console.log('RESTAPI listening on port: ' + port);