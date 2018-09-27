function buildMainRooms(){
    Struct.createSpecificRoom("EntranceDown").setName("start")
        .chain(Struct.createRoomWithType("Collector"))
        .chain(Struct.createPerkShop(2))
        .chain(Struct.createRoomWithType("Healing"))
        .chain(Struct.createSpecificExit("SewerDepths", "ExitLiftDown"));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("T_SewerDepths", _levelInfo); 
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("T_SewerDepths", _levelProps);
}

