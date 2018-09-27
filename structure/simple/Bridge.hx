function buildMainRooms(){
    Struct.createSpecificRoom("BridgeEntrance").setName("start").addFlag(RoomFlag.Outside)
        .chain(Struct.createSpecificRoom("BridgeMiddle").addFlag(RoomFlag.Outside))
        .chain(Struct.createSpecificExit("T_Bridge", "BridgeExit").addFlag(RoomFlag.Outside));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}


function setLevelInfo(_levelInfo){
    setLevelInfoFrom("Bridge", _levelInfo); 
}


function setLevelProps(_levelProps){
    setLevelPropsFrom("Bridge", _levelProps);
}
