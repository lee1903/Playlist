var express = require('express');
 
// Get the router
var router = express.Router();
 
var Session = require('./models/session');
var Track = require('./models/track')
 
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
	    session.playlist = []
 
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
    })
    .put(function(req, res) {
        Session.findOne({name : req.params.name}, function(err, session) {
            if (err)
                res.send(err);

            if(req.body.updateVote != null) {
            	for(var i = 0; i < session.tracklist.length; i++) {
            		if(session.tracklist[i].name == req.body.name) {
            			var track = session.tracklist[i]
            			track.votes = track.votes + 1
            			session.tracklist.splice(i, 1)
            			var didInsert = 0
            			for(var k = 0; k < i; k++) {
            				if(session.tracklist[k].votes < track.votes){
            					session.tracklist.splice(k, 0, track)
            					didInsert = 1
            					break
            				}
            			}
            			if(didInsert == 0) {
            				session.tracklist.splice(i, 0, track)
            			}
            		}
            	}
            	session.save(function(err) {
	                if (err)
	                    res.send(err);
	                res.json({ message: 'Success'})
	            });
            } else {
            	var track = new Track()
	            track.name = req.body.name
	            track.votes = req.body.votes
	            track.playableURI = req.body.playableURI

	        	session.tracklist.push(track)
	            session.save(function(err) {
	                if (err)
	                    res.send(err);
	                res.json({ message: 'Tracklist successfully updated!' });
	            });
            }
        });
    });

router.route('/sessions/tracklist/name=:name')
    // GET session with user created title
    .get(function(req, res) {
        Session.findOne({name : req.params.name}, function(err, session) {
            if (err)
                res.send(err);
            res.json(session.tracklist);
        });
    });

 
module.exports = router;
 
function dateDisplayed(timestamp) {
    var date = new Date(timestamp);
    return (date.getMonth() + 1 + '/' + date.getDate() + '/' + date.getFullYear() + " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds());
}