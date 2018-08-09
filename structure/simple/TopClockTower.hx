function buildMainRooms(){
    Struct.createRoomWithType("Entrance").setName("start")
        .chain(Struct.createSpecificRoom("BossBerserk")).setName("end")
        .chain(Struct.createExit("T_Castle"));
}

function addTeleports(){
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("TopClockTower", _levelProps);
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("TopClockTower", _levelInfo);
}

function buildMobRoster(_mobList){
    addMobRosterFrom("TopClockTower", _mobList);
}