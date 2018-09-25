function buildMainRooms(){
    Struct.createSpecificRoom("EntranceDown").setName("start")
        .chain(Struct.createRoomWithType("Collector"))
        .chain(Struct.createPerkShop(7))
        .chain(Struct.createRoomWithType("Healing"))
        .chain(Struct.createExit("Castle"));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("T_Castle", _levelInfo); 
}

function SetLevelProps(_levelProps){
    setLevelPropsFrom("T_Castle", _levelProps);
}
