function buildMainRooms(){
    Struct.createSpecificRoom("OssEntrance").setName("start")
            .chain(Struct.createExit("T_Bridge").setName("mainExit"));

    Struct.createRoomWithType("Treasure").branchBetween("start", "mainExit", 0).setName("mainTreasure");
    Struct.createRoomWithType("BuyableTreasure").addBetween("start", "mainExit");
    Struct.createShopWithType(MerchantType.Weapons).branchBetweenMultipleEnds("start", ["mainExit", "mainTreasure"], 0).setName("shop1");
    Struct.createShopWithType(MerchantType.Actives).branchBetweenMultipleEnds("start", ["mainExit", "mainTreasure"], 0).setName("shop2");

    if( Random.isBelow(0.6) ){
        Struct.createRoomWithType("BuyableCells").branchBetweenMultipleEnds("start", ["mainExit", "mainTreasure"]);
    }

    if( Random.isBelow(0.3) ){
        Struct.createRoomWithType("Treasure").addBetweenMultipleEnds("start", ["mainExit", "mainTreasure"]);
    }

    if( Random.isBelow(0.33) ){
        Struct.createRoomWithType("CursedTreasure").branchOrAddBetween("start", ["mainExit"], 0);
    }

    if( !Meta.hasMetaRune("BreakableGroundKey") ){
        Struct.createSpecificRoom("OssBoss").branchBetween("start", "mainExit", 0);
    }
}

function buildSecondaryRooms(){
    var ends = ["mainExit", "mainTreasure", "shop1", "shop2"];
    if( !Meta.hasMetaRune("BreakableGroundKey") ){
        ends.push("ossBoss");
    }

    Struct.createRoomWithTypeFromGroup("Combat", "Ossuary").branchBetweenMultipleEnds("start", ends, 0);
    Struct.createRoomWithTypeFromGroup("Combat", "Ossuary").branchBetweenMultipleEnds("start", ends, 0);
    Struct.createAndAddRoomsBetween("Combat", "NeedTeleport", 1, "start", ends, 0);

    if( Random.isBelow(0.5) ){
        Struct.createAndAddRoomsBetween("Combat", "NeedWallJump", 1, "start", ends, 0);
    }
    else{
        Struct.createAndAddRoomsBetween("Combat", "NeedStomp", 1, "start", ends, 0);
    }

    Struct.createRoomWithTypeFromGroup("Combat", "Ossuary").addBefore("mainExit");
    Struct.createAndAddRoomsBetween("Combat", "Ossuary", 3, "start", ["mainExit"], 0);
    Struct.createRoomWithTypeFromGroup("Combat", "Ossuary").branchBetween("start", "mainExit");

    for( i in 0...Random.irange(5, 6) ){
        Struct.createRoomWithTypeFromGroup("Corridor", "OssuaryElevator").addBetweenMultipleEnds("start", ends, 0);
    }

    Struct.createRoomWithTypeFromGroup("Combat", "Ossuary").addAfter("start"); //forced for new mobs introduction
    Struct.createAndAddRoomsBetween("Combat", "MinorSecret", 1, "start", ["mainExit"], 0);

    var rooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.parent != null);
    Struct.createRunicZDoor(Struct.createShopWithType(MerchantType.Heals), 1, rooms);
    Struct.createRunicZDoorWithCombatCount(Struct.createRoomWithType("CursedTreasure"), 2, 0, rooms);
    Struct.createRunicZDoor(Struct.createRoomWithType("CursedTreasure"), 4, rooms);

    //Ossuary secret
    var secretRooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.parent != null && _room.spawnDistance >= 4);
    var secret = Struct.createSpecificRoom("OssSecret").addBefore(Random.arrayPick(secretRooms).getName());
    Struct.createRoomWithTypeFromGroup("Corridor", "Long").addBefore(secret.getName());
}

function buildTimedDoors(){
    var dh = new DecisionHelper(Struct.allRooms);
    dh.remove(function(_room) return !_room.isMainLevel() || _room.parent == null);
    dh.score(function(_room) return _room.spawnDistance <= 1 ? 10 : _room.spawnDistance <= 3 ? 5 : 0);
    dh.score(function(_room) return -_room.spawnDistance * 0.5);
    dh.score(function(_room) return Random.irange(0, 2));

    Struct.createTimedBranchBefore(dh.getBest());
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("Ossuary", _levelProps);
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("Ossuary", _levelInfo);
}

function buildMobRoster(_mobList){
    addMobRosterFrom("Ossuary", _mobList);
}