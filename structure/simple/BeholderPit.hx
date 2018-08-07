function buildMainRooms(){
    Struct.createRoomWithType("Entrance").setName("start")
        .chain(Struct.createSpecificRoom("BossBeholder")).setName("end")
        .chain(Struct.createSpecificExit("T_AncientTemple", "BossBeholderExit"))
        .chain(Struct.createExit("T_Cemetery"));

}

function addTeleports(){
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("BeholderPit", _levelProps);
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("BeholderPit", _levelInfo);
}

function buildMobRoster(_mobList){
    addMobRosterFrom("BeholderPit", _mobList);
}