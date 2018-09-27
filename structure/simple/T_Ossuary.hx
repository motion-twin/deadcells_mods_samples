function buildMainRooms(){
    Struct.createSpecificRoom("EntranceOssuaryDown").setName("start")
        .chain(Struct.createRoomWithType("Collector"))
        .chain(Struct.createPerkShop(2))
        .chain(Struct.createRoomWithType("Healing"))
        .chain(Struct.createSpecificExit("Ossuary", "Exit_LR"));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("T_Ossuary", _levelInfo); 
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("T_Ossuary", _levelProps);
}

