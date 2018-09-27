function buildMainRooms(){
    Struct.createRoomWithType("Entrance").setName("start")
        .chain(Struct.createRoomWithType("Collector"))
        .chain(Struct.createPerkShop(3))
        .chain(Struct.createRoomWithType("Healing"))
        .chain(Struct.createExit("BeholderPit"));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("T_BeholderPit", _levelInfo); 
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("T_BeholderPit", _levelProps);
}

