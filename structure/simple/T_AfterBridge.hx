function buildMainRooms(){
    Struct.createRoomWithType("Entrance").setName("start")
        .chain(Struct.createRoomWithType("Collector"))
        .chain(Struct.createPerkShop(4))
        .chain(Struct.createRoomWithType("Healing"))
        .chain(Struct.createRoomWithTypeFromGroup("Corridor", "Transition").setName("exitCross"))
        .chain(Struct.createExit("StiltVillage"));
    var gateRoom = Struct.createRoomWithType("WallJumpGate").setName("gate");
    Struct.getRoomByName("exitCross").addChild(gateRoom);
    gateRoom.chain(Struct.createExit("AncientTemple"));
}

function buildTimeDoors(){
    Struct.createTimedBranchBefore(Struct.getRoomByName("Collector"));
}

function buildMobRoster(_mobList){
}

function addTeleports(){
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("T_AfterBridge", _levelInfo); 
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("T_AfterBridge", _levelProps);
}

