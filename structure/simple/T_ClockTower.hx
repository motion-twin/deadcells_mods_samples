function buildMainRooms(){
    Struct.createSpecificRoom("EntranceDown").setName("start")
        .chain(Struct.createRoomWithType("Collector"))
        .chain(Struct.createPerkShop(5))
        .chain(Struct.createRoomWithType("Healing"))
        .chain(Struct.createSpecificExit("ClockTower", "Exit_LR"));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("T_ClockTower", _levelInfo); 
}

function SetLevelProps(_levelProps){
    setLevelPropsFrom("T_ClockTower", _levelProps);
}

