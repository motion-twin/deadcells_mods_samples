function buildMainRooms(){
    Struct.createSpecificRoom("BridgeEntrance").setName("start").addFlag(RoomFlag.Outside)
        .chain(Struct.createSpecificRoom("BridgeBoatDock").addFlag(RoomFlag.Outside));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}


function setLevelInfo(_levelInfo){
    setLevelInfoFrom("BoatDock", _levelInfo); 
}


function setLevelProps(_levelProps){
    setLevelPropsFrom("BoatDock", _levelProps);
}

