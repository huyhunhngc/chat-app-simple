const app = require('express')();
const http = require('http').createServer(app);
const io = require('socket.io')(http);
const routes = require('./routes/index')
const connectDB = require('./db')
const mess = require('./models/message')
//const formatMessage = require('./utils/messages');
const {
    userJoin,
    userCall,
    getCurrentUser,
    getSocketid,
    userLeave,
    getRoomUsers
} = require('./utils/users');
const port = process.env.PORT;

const CLIENT_ID_EVENT = 'client-id-event';
const OFFER_EVENT = 'offer-event';
const ANSWER_EVENT = 'answer-event';
const ICE_CANDIDATE_EVENT = 'ice-candidate-event';

const activateUser = [];
const room = "general";
const roomList = [];
const clientList = [];

app.use(routes);

function findPeerId(hostId) {
    for (let i = 0; i < roomList.length; i++) {
        if (roomList[i].host == hostId) {
            return roomList[i].peer;
        }
    }
}

function findHostId(peerId) {
    for (let i = 0; i < roomList.length; i++) {
        if (roomList[i].peer == peerId) {
            return roomList[i].host;
        }
    }
}
io.on('connection', socket => {
    var chatID = socket.handshake.query.chatID;
    var callID = socket.handshake.headers.callid;
    console.log(callID);
    var socketID = socket.id;
    console.log("Client call connect "+socketID+" " +callID);
    
    try {
        if (!activateUser.find(user => user.socketId == socketID)&& callID==null) {
            activateUser.push(userJoin(chatID, "chuaco", room, socketID));
            socket.join(room);
        }
        if(callID != null){
            clientList.push(userCall(callID, socketID));
            console.log(clientList);
            socket.emit(CLIENT_ID_EVENT, socket.id);
        }
       

    } catch (err) {
        console.log(err.message)
    }

    socket.on('disconnect', () => {
        socket.leave(room);
        userLeave(socket.id);
        const index = activateUser.findIndex(user => user.socketId === socket.id);
       const indexCall = clientList.findIndex(user => user.socketId === socket.id);
        if (index !== -1) {
            console.log(activateUser[index].name + "leave")
            activateUser.splice(index, 1)[0];
        }
        if(indexCall!==-1){
            clientList.splice(indexCall,1)[0];
        }
        for (let i = 0; i < roomList.length; i++) {
            if (roomList[i].host == socket.id ||
                roomList[i].peer == socket.id) {
                roomList.splice(i, 1);
            }
        }

    })
    console.log(activateUser);
    socket.on(OFFER_EVENT, data => {
        //console.log(data);
        try{
            var peerSocketId = clientList.find(user => user.chatId == data.peerId).socketId;
            console.log(peerSocketId);
            //data.peerId = peerSocketId;
            roomList.push({
                host: socket.id,
                peer: peerSocketId
            });
            const peer = io.to(peerSocketId);
            if (peer) {
                peer.emit(OFFER_EVENT, data.description);
            } else {
                console.log('onOfferEvent: Peer does not found');
            }
        }catch(err){
            console.log(err);
        }
    })
    socket.on(ANSWER_EVENT, data => {
        console.log(data);
        const hostId = findHostId(socket.id);
        const host = io.to(hostId);
        if (host) {
            host.emit(ANSWER_EVENT, data.description);
        } else {
            console.log('onAnswerEvent: Host does not found');
        }
    })
    socket.on(ICE_CANDIDATE_EVENT, data => {
        console.log(data);
        let clientId;
        if (data.isHost) {
            clientId = findPeerId(socket.id);
        } else {
            clientId = findHostId(socket.id);
        }
        const peer = io.to(clientId);
        if (peer) {
            peer.emit(ICE_CANDIDATE_EVENT, data.candidate);
        } else {
            console.log('onIceCandidateEvent: Peer does not found');
        }
    })
    socket.on('send_message', message => {
        var receiverChatID = message.receiverChatID;
        var senderChatID = message.senderChatID;
        var content = message.content;
        var type = message.type;
        mess.create({
            type: message.type,
            content:message.content,
            senderChatID: message.senderChatID,
            receiverChatID:message.receiverChatID,
        })
        try {
            var receiverSocketId = activateUser.find(user => user.chatId == receiverChatID).socketId
        } catch (err) {
            console.log(err.message)
        }
        console.log(receiverSocketId);
        io.to(receiverSocketId).emit('receive_message', {
            'type': type,
            'content': content,
            'senderChatID': senderChatID,
            'receiverChatID': receiverChatID,
        })
        console.log(senderChatID + " send " + content + " to " + receiverChatID);
    })
});

connectDB();
http.listen(port, () => console.log(`Server running on port ${port}`));