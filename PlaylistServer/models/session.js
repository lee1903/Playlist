var mongoose = require('mongoose');
var Schema = mongoose.Schema;
 
var sessionSchema = new Schema({
    name: String,
    date: String
});
 
module.exports = mongoose.model('Session', sessionSchema);