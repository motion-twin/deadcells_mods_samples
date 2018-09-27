function buildMainRooms(){
    Struct.createSpecificRoom("BasicEntrance_R").setName("start")
        .chain(Struct.createRoomWithType("Collector"))
        .chain(Struct.createPerkShop(5))
        .chain(Struct.createRoomWithType("Healing"))
        .chain(Struct.createSpecificExit("Crypt", "Exit_LR"));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("T_Crypt", _levelInfo); 
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("T_Crypt", _levelProps);
}

