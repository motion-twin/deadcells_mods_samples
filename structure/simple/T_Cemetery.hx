function buildMainRooms(){
    Struct.createRoomWithType("Entrance").setName("start")
        .chain(Struct.createRoomWithType("Collector"))
        .chain(Struct.createPerkShop(4))
        .chain(Struct.createRoomWithType("Healing"))
        .chain(Struct.createExit("Cemetery"));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("T_Cemetery", _levelInfo); 
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("T_Cemetery", _levelProps);
}

