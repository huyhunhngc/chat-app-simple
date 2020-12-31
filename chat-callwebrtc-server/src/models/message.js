var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var messageSchema = new Schema({
    type: {
        type: Number,
        require: true
    },
    content: {
        type: String,
        require: true
    },
    senderChatID: {
        type: String,
        require: true
    },
    receiverChatID: {
        type: String,
        require: true
    },

})

module.exports = mongoose.model('Message', messageSchema)