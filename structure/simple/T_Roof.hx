function buildMainRooms(){
    Struct.createSpecificRoom("BasicEntrance_R").setName("start")
        .chain(Struct.createRoomWithType("Collector"))
        .chain(Struct.createPerkShop(2))
        .chain(Struct.createRoomWithType("Healing"))
        .chain(Struct.createSpecificExit("PrisonRoof", "ExitLiftUp"));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}


function setLevelInfo(_levelInfo){
    setLevelInfoFrom("T_Roof", _levelInfo); 
}


function setLevelProps(_levelProps){
    setLevelPropsFrom("T_Roof", _levelProps);
}

