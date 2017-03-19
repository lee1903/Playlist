var express = require('express');
 
// Get the router
var router = express.Router();
 
var Session = require('./models/session');
 
// Middleware for all this routers requests
router.use(function timeLog(req, res, next) {
  console.log('Request Received: ', dateDisplayed(Date.now()));
  next();
});
 
// Welcome message for a GET at http://localhost:8080/restapi
router.get('/', function(req, res) {
    res.json({ message: 'Welcome to the REST API' });   
});

// GET all sessions (using a GET at http://localhost:8080/sessions)
router.route('/sessions')
    .get(function(req, res) {
        Session.find(function(err, sessions) {
            if (err)
                res.send(err);
            res.json(sessions);
        });
    });

// Create a session (using POST at http://localhost:8080/sessions)
router.route('/sessions')
    .post(function(req, res) {
        var session = new Session();
    // Set text and user values from the request
	session.name = req.body.name;
    session.date = req.body.date;
 
        // Save session and check for errors
        session.save(function(err) {
            if (err)
                res.send(err);
            res.json({ message: "success" });
        });
    });

router.route('/sessions/name=:name')
    // GET session with user created title
    .get(function(req, res) {
        Session.findOne({name : req.params.name}, function(err, session) {
            if (err)
                res.send(err);
            res.json(session);
        });
    });

 
module.exports = router;
 
function dateDisplayed(timestamp) {
    var date = new Date(timestamp);
    return (date.getMonth() + 1 + '/' + date.getDate() + '/' + date.getFullYear() + " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds());
}