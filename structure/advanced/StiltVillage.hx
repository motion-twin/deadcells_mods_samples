function buildMainRooms(){
    Struct.createSpecificRoom("SVEntrance").setName("start")
        .chain(Struct.createSpecificRoom("SVMidGate").setName("mid"))
        .chain(Struct.createSpecificExit("T_ClockTower", "SVEnd").setName("end"));

    //Large buildings
    var pos = [Struct.getRoomByName("mid"), Struct.getRoomByName("end")];
    shuffleArray(pos);
    createLargeBuildingBefore(Random.arraySplice(pos), 1, Struct.createRoomWithTypeFromGroup("Combat", "SVLargeTop"));
    createLargeBuildingBefore(Random.arraySplice(pos), 0, Struct.createRoomWithTypeFromGroup("Treasure", "SVLargeTop"));

    //Small buildings
    var targets = Struct.allRooms.filter(function(_room) return _room.group == "SVLargeLeft" || _room.getName() == "end");
    Struct.createRoomWithTypeFromGroup("Combat", "SVSmallBuilding").addBefore(Random.arrayPick(targets).getName());

    var allZDoors = Struct.allRooms.filter(function(_room) return _room.type == "Combat" && (_room.group == "SVLargeLeft" || _room.group == "SVLargeRight" || _room.group == "SVLargeMid" || _room.group == "SVLargeTop" || _room.group == "SVSmallBuilding"));

    //First key
    var mid = Struct.getRoomByName("mid");
    var before = allZDoors.filter(function(_room) return _room.spawnDistance <= mid.spawnDistance);
    var room = Random.arrayPick(before);
    allZDoors.remove(room);
    addBuildingContent(room, 1, Struct.createSpecificRoom("SVInteriorKey1"), ZDoorContentClue.CKey);

    //Second key
    var after = allZDoors.filter(function(_room) return _room.spawnDistance > mid.spawnDistance);
    room = Random.arraySplice(after);
    allZDoors.remove(room);
    addBuildingContent(room, 1, Struct.createSpecificRoom("SVInteriorKey2"), ZDoorContentClue.CKey);

    //Crypt exit
    room = Random.arraySplice(after);
    allZDoors.remove(room);
    var teleport = Struct.createRoomWithTypeFromGroup("TeleportGate", "SVInterior");
    teleport.chain(Struct.createSpecificExit("T_Crypt", "SVInteriorExit"));
    addBuildingContent(room, 0, teleport, ZDoorContentClue.CExit);

    //Misc building contents
    addBuildingContent(Random.arraySplice(allZDoors), 2, Struct.createRoomWithType("DualTreasure"), ZDoorContentClue.CTreasure);
    addBuildingContent(Random.arraySplice(allZDoors), 1, Struct.createRoomWithType("CursedTreasure"), ZDoorContentClue.CTreasure);
    addBuildingContent(Random.arraySplice(allZDoors), 0, Struct.createShop(), ZDoorContentClue.CShop);
    addBuildingContent(Random.arraySplice(allZDoors), 0, Struct.createShopWithType(MerchantType.Heals), ZDoorContentClue.CShop);
}

function createLargeBuildingBefore(_room : RoomNode, _innerSize : Int, _topContent : RoomNode){
    var parts = [];
    parts.push(Struct.createRoomWithTypeFromGroup("Combat", "SVLargeLeft").addBefore(_room.getName()));
    for( i in 0..._innerSize ){
        parts.push(Struct.createRoomWithTypeFromGroup("Combat", "SVLargeMid").addBefore(_room.getName()));
    }
    parts.push(Struct.createRoomWithTypeFromGroup("Combat", "SVLargeRight").addBefore(_room.getName()));

    //Top
    if( _topContent != null ){
        Random.arraySplice(parts).addChild(_topContent.setConstraint(LinkConstraint.UpOnly));
    }

    //Teleport
    Random.arraySplice(parts).addChild(Struct.createRoomWithTypeFromGroup("Teleport", "SVLargeTop").setConstraint(LinkConstraint.UpOnly));
    if( parts.length >= 2 ){
        Random.arraySplice(parts).addChild(Struct.createRoomWithTypeFromGroup("Teleport", "SVLargeTop").setConstraint(LinkConstraint.UpOnly));
    }
}

function addBuildingContent(_room : RoomNode, _combatRoomCount : Int, _content : RoomNode, _clue : ZDoorContentClue){
    //Parse content
    var content = [_content];
    var room = _content;
    while( room.childrenCount > 0 ){
        room = room.firstChild;
        content.push(room);
    }

    var goingUp = _room.group != "SVSmallBuilding" && Random.isBelow(0.5);
    if( _content != null && content[content.length - 1].type == "Exit" ){
        goingUp = false;
    }

    //Z-entrance
    room = Struct.createRoomWithTypeFromGroup("Corridor", goingUp ? "SVInsideBottomDoor" : "SVInsideTopDoor").forceBiome("StiltVillageInt");
    _room.addZChildWithClue(room, _clue);

    //Combat
    while( _combatRoomCount > 0 ){
        room = room.chain(Struct.createRoomWithTypeFromGroup("Combat", "SVInterior"));
        _combatRoomCount--;
    }

    //End content
    if( _content != null ){
        room.chain(_content);
        while( room.childrenCount > 0 ) room = room.firstChild; // position on the end of the content (if it has multiple rooms)
    }

    //End teleporter
    if( room.parentCount > 2 ){
        room = room.chain(Struct.createRoomWithType("EntranceTeleport"));
    }

}

function addTeleports(){
    Struct.createSpecificRoom("SVTeleportSkyBridge").addBefore("mid");

    var exit = Struct.getRoomByName("end");
    var groundRooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && (_room.group == "SVSmallBuilding" && _room.type == "Combat" || _room.group == "SVLargeLeft" || _room.type == "Exit"));
    for( room in groundRooms ){
        Struct.createRoomWithTypeFromGroup("Teleport", "SVSmallBuilding").addBefore(room.getName());
    }
}


function buildTimedDoors(){
    var room = Struct.createRoomWithTypeFromGroup("Combat", "SVSmallBuilding").addAfter("start");
    addBuildingContent(room, 0, Struct.createTimedBranch(), ZDoorContentClue.CTimedDoor);
}

function finalize(){
    for( room in Struct.allRooms ){
        if( room.isMainLevel() ){
            room.addFlag(RoomFlag.Outside);
        }
    }
}

function buildSecondaryRooms(){
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("StiltVillage", _levelProps);
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("StiltVillage", _levelInfo);
}

function buildMobRoster(_mobList){
    addMobRosterFrom("StiltVillage", _mobList);
}