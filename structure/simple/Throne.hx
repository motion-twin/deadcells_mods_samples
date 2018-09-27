function buildMainRooms(){
    Struct.createSpecificRoom("BossKingsHandEntrance").addFlag(RoomFlag.Outside).setName("start")
        .chain(Struct.createSpecificRoom("BossKingsHandArena").addFlag(RoomFlag.Outside).setName("boss"))
        .chain(Struct.createSpecificRoom("BossKingsHandThrone").addFlag(RoomFlag.Outside));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("Throne", _levelInfo); 
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("Throne", _levelProps);
}
