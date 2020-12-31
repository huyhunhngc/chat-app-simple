const users = [];
const usersCall = [];
function userJoin(chatId, username, room, socketId) {
  const user = {
    chatId,
    username,
    room,
    socketId
  };
  users.push(user);
  return user;
}
function userCall(chatId, socketId) {
  const user = {
    chatId,
    socketId
  };
  usersCall.push(user);
  return user;
}
function getCurrentUser(id) {
  return users.find(user => user.chatId === id);
}
function getSocketid(chatId) {
  return users.find(user => user.chatId = chatId).socketId;
}
function userLeave(id) {
  const index = users.findIndex(user => user.socketId === id);

  if (index !== -1) {
    return users.splice(index, 1)[0];
  }
}

function getRoomUsers(room) {
  return users.filter(user => user.room === room);
}

module.exports = {
  userJoin,
  userCall,
  getCurrentUser,
  getSocketid,
  userLeave,
  getRoomUsers
};