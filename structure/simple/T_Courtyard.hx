function buildMainRooms(){
    Struct.createSpecificRoom("BasicEntrance_R").setName("start")
        .chain(Struct.createRoomWithType("Collector"))
        .chain(Struct.createPerkShop(1))
        .chain(Struct.createRoomWithType("Healing"))
        .chain(Struct.createSpecificExit("Courtyard", "Exit_LR"));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}


function setLevelInfo(_levelInfo){
    setLevelInfoFrom("T_Courtyard", _levelInfo); 
}


function SetLevelProps(_levelProps){
    setLevelPropsFrom("T_Courtyard", _levelProps);
}

