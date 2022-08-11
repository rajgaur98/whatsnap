const rooms = [];

const exists = (room) => {
    return rooms.includes(room);
}

const addRoom = (room) => {
    rooms.push(room);
}

const deleteRoom = (room) => {
    let index = rooms.findIndex(room);
    if(index === -1) return false;
    rooms.splice(index, 1);
    return true;
}

module.exports = {
    exists,
    addRoom,
    deleteRoom
}
