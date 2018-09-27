function buildMainRooms(){
    Struct.createSpecificRoom("BasicEntrance_R").setName("start")
        .chain(Struct.createRoomWithType("Collector"))
        .chain(Struct.createPerkShop(2))
        .chain(Struct.createRoomWithType("Healing"))
        .chain(Struct.createSpecificExit("PrisonDepths", "Exit_LR"));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("T_PrisonDepths", _levelInfo); 
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("T_PrisonDepths", _levelProps);
}

