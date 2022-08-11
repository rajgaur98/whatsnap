const users = [];
const userMapping = {};
const roomMapping = {};

const createUser = (id, name) => {
    users.push({id, name});
    console.log(users);
    return {id, name};
}

const getUser = (id) => {
    return users.find((user, index) => user.id === id);
}

const getUserByName = (name) => {
    console.log(users);
    return users.find((user, index) => user.name === name);
}

const deleteUser = (id) => {
    //console.log(users);
    let index = users.findIndex((user, index) => user.id === id);
    if(index === -1) return null;
    let user = users[index];
    for(let i=0; userMapping[user.name] !== undefined && i<userMapping[user.name].length; i++){
        let targetname = userMapping[user.name][i].name;
        if(userMapping[targetname] !== undefined){
            let ind = userMapping[targetname].findIndex((ele, ind) => ele.name === user.name);
            userMapping[targetname].splice(ind, 1);
        }
    }
    if(userMapping[user.name] !== undefined) delete userMapping[user.name];
    if(roomMapping[user.name] !== undefined) delete roomMapping[user.name];
    console.log(userMapping);
    return users.splice(index, 1)[0];
}

const addUserMapping = (username, targetname, room) => {
    console.log('mapping users!');
    if(userMapping[username] === undefined){
        userMapping[username] = [];
    }
    if(userMapping[targetname] === undefined){
        userMapping[targetname] = [];
    }
    userMapping[username].push({name: targetname, room});
    userMapping[targetname].push({name: username, room});
}

const areUsersMapped = (username, targetname) => {
    if(userMapping[username] === undefined) return undefined;
    return userMapping[username].find((ele, ind) => ele.name === targetname);
}

const addRoomMapping = (username, room) => {
    if(roomMapping[username] === undefined){
        roomMapping[username] = [];
    }
    roomMapping[username].push(room);
}

module.exports = {
    createUser,
    getUser,
    deleteUser,
    getUserByName,
    addUserMapping,
    areUsersMapped,
    addRoomMapping,
    userMapping,
    roomMapping,
}
