function buildMainRooms(){
    Struct.createSpecificRoom("BasicEntrance_R").setName("start")
        .chain(Struct.createRoomWithType("Collector"))
        .chain(Struct.createPerkShop(4))
        .chain(Struct.createRoomWithType("Healing"))
        .chain(Struct.createSpecificExit("AncientTemple", "ExitLiftDown"));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("T_AncientTemple", _levelInfo); 
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("T_AncientTemple", _levelProps);
}

