function buildMainRooms(){
    Struct.createSpecificRoom("EntranceSewerDown").setName("start")
        .chain(Struct.createRoomWithType("Collector"))
        .chain(Struct.createPerkShop(1))
        .chain(Struct.createRoomWithType("Healing"))
        .chain(Struct.createExit("SewerShort"));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("T_SewerShort", _levelInfo); 
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("T_SewerShort", _levelProps);
}

