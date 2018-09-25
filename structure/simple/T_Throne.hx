function buildMainRooms(){
    Struct.createSpecificRoom("EntranceDown").setName("start")
        .chain(Struct.createRoomWithType("Collector"))
        .chain(Struct.createPerkShop(8))
        .chain(Struct.createRoomWithType("Healing"))
        .chain(Struct.createSpecificExit("Throne", "Exit_LR"));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("T_Throne", _levelInfo); 
}

function SetLevelProps(_levelProps){
    setLevelPropsFrom("T_Throne", _levelProps);
}
