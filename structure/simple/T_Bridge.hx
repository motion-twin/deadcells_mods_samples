function buildMainRooms(){
    Struct.createSpecificRoom("BasicEntrance_R").setName("start")
        .chain(Struct.createRoomWithType("Collector"))
        .chain(Struct.createPerkShop(3))
        .chain(Struct.createRoomWithType("Healing"))
        .chain(Struct.createExit("Bridge"));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}


function setLevelInfo(_levelInfo){
    setLevelInfoFrom("T_Bridge", _levelInfo); 
}


function SetLevelProps(_levelProps){
    setLevelPropsFrom("T_Bridge", _levelProps);
}

