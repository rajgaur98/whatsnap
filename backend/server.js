const http = require('http');
const express = require('express');
const socketio = require('socket.io');
const users = require('./utils/users');

const app = express();
const server = http.createServer(app);
const io = socketio(server);

io.on('connection', (socket) => {

    console.log('connection made');

    socket.on('join', (username) => {
        if(users.getUserByName(username) === undefined){
            console.log('user does not exist');
            const user = users.createUser(socket.id, username);
            socket.emit('userLoggedIn');
        }
        else{
            console.log('user exists');
            socket.emit('userAlreadyExists');
        }
    });

    socket.on('privateChat', ({msg, targetname, date}) => {
        if(users.getUserByName(targetname) === undefined){
            socket.emit('receiverDoesntExistError', `${targetname} doesnt exist or isnt online`);
        }
        else{
            const targetUser = users.getUserByName(targetname);
            //console.log(user, socket.id);
            const user = users.getUser(socket.id);
            console.log(msg);
            if(users.areUsersMapped(user.name, targetname) !== undefined){
                console.log('users mapped');
            }
            else{
                console.log('not mapped');
                const targetSocket = io.sockets.connected[targetUser.id];
                targetSocket.join(user.name + '-' + targetname);
                socket.join(user.name + '-' + targetname);
                users.addUserMapping(user.name, targetname, user.name + '-' + targetname);
            }
            const mappedEle = users.areUsersMapped(user.name, targetname);
            //socket.emit('message', {username: user.name, room: '', msg});
            io.to(mappedEle.room).emit('message', {username: user.name, room: mappedEle.room, msg, type: 'private', date});
        }
    });

    socket.on('chatMessage', ({msg, room, date}) => {
        console.log(msg);
        const user = users.getUser(socket.id);
        io.to(room).emit('message', {username: user.name, room, msg, type: 'room', date});
    });

    socket.on('disconnect', () => {
        console.log('user disconneted');
        const user = users.getUser(socket.id);
        if(user !== undefined){
            const mappedRooms = users.roomMapping[user.name];
            for(let i=0; mappedRooms !== undefined && i<mappedRooms.length; i++){
                io.to(mappedRooms[i]).emit('message', {username: 'bot', room: mappedRooms[i], msg: `${user.name} left the chat`, type: 'room'})
            }
            const mappedUsers = users.userMapping[user.name];
            for(let i=0; mappedUsers !== undefined && i<mappedUsers.length; i++){
                io.to(mappedUsers[i].room).emit('message', {username: 'bot', room: mappedUsers[i].room, msg: `${user.name} left the chat`, type: 'private'})
            }
            users.deleteUser(socket.id);
        }
    })
})


const PORT = process.env.PORT || 3000;

server.listen(PORT, () => console.log(`Server running on port ${PORT}`));

app.use(express.urlencoded({extended: true}));

app.post('/receiver', (req, res) => {
    if(users.getUserByName(req.body.username) === undefined){
        console.log('user does not exist');
        res.send(false);
    }
    else{
        console.log('user exists');
        const targetname = req.body.username;
        const sendername = req.body.sender;
        const targetUser = users.getUserByName(targetname);
        const user = users.getUserByName(sendername);
        const targetSocket = io.sockets.connected[targetUser.id];
        const userSocket = io.sockets.connected[user.id];
        targetSocket.join(user.name + '-' + targetname);
        userSocket.join(user.name + '-' + targetname);
        users.addUserMapping(user.name, targetname, user.name + '-' + targetname);
        const mappedEle = users.areUsersMapped(user.name, targetname);
        //socket.emit('message', {username: user.name, room: '', msg});
        io.to(mappedEle.room).emit('message', {username: 'bot', room: mappedEle.room, msg: 'connection made', type: 'private'});
        res.send(true);
    }
});

app.post('/joinRoom', (req, res) => {
    const username = req.body.username;
    const room = req.body.room;
    console.log(username);
    console.log(room);
    const user = users.getUserByName(username);
    const socket  = io.sockets.connected[user.id];
    socket.join(room);
    users.addRoomMapping(user.name, room);
    io.to(room).emit('message', {username: 'bot', room, msg: `${user.name} has joined the chat`, type: 'room'});
    res.send(true);
});
