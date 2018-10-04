function buildMainRooms(){
    Struct.createSpecificRoom("SewerDepthsEntrance").setName("start")
            .chain(Struct.createSpecificExit("T_BeholderPit", "ExitLiftUp").setName("exit"));

    var shopTypes = [MerchantType.Weapons, MerchantType.Actives];
    Struct.createShopWithType(Random.arraySplice(shopTypes)).setName("shop1").branchBetween("start", "exit", 0);
    Struct.createShopWithType(Random.arraySplice(shopTypes)).setName("shop2").branchBetween("start", "exit", 0);

    Struct.createRoomWithType("WallJumpGate").branchBetween("start", "exit", 0).chain(Struct.createRoomWithType("BuyableCells"));

    if( Random.isBelow(0.5) ){
        Struct.createRoomWithType("HealPotion").addBetween("start", "exit", 0);
    }

    Struct.createRoomWithType("Treasure").setName("mainTreasure").branchOrAddBetween("start", ["exit"], 2);
    if( Random.isBelow(0.33) ){
        Struct.createRoomWithType("CursedTreasure").addBetween("start", "exit");
    }

    if( Random.isBelow(0.3) ){
        Struct.createRoomWithType("BuyableTreasure").branchOrAddBetween("start", ["exit"], 0);
    }

}

function buildSecondaryRooms(){
    var ends = ["shop1", "shop2", "mainTreasure", "exit"];

    Struct.createRoomWithTypeFromGroup("Combat", "SewerLabyrinth").branchBetweenMultipleEnds("start", ends, 0);
    Struct.createAndAddRoomsBetween("Combat", "SewerCorridor", Random.irange(2, 3), "start", ends, 0);
    Struct.createAndAddRoomsBetween("Combat", "SewerLabyrinth", 3, "start", ["exit"], 0);

    Struct.createAndAddRoomsBetween("Combat", "NeedWallJump", 1, "start", ["exit"], 0);
    Struct.createAndAddRoomsBetween("Combat", "NeedStomp", 1, "start", ["exit"], 0);


    Struct.createAndAddRoomsBetween("Trap_1", "CommonTraps", Random.irange(0, 2), "start", ends, 0);
    Struct.createAndAddRoomsBetween("Trap_2", "CommonTraps", 3, "start", ["exit"], 0);

    Struct.createAndAddRoomsBetween("Combat", "NeedLadder", 1, "start", ends, 0);
    if( Random.isBelow(0.5) ){
        Struct.createAndAddRoomsBetween("Combat", "NeedLadder", 1, "start", ends, 0);
    }

    if( Random.isBelow(0.6) ){
        Struct.createAndAddRoomsBetween("Combat", "NeedTeleport", 1, "start", ends, 0);
    }

    Struct.createAndAddRoomsBetween("Combat", "MinorSecret", 1, "start", ends, 0);

    //Z doors
    var rooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.spawnDistance > 2 && _room.parent != null);
    Struct.createRunicZDoor(Struct.createRoomWithType("CursedTreasure"), 2, rooms);
    Struct.createRunicZDoor(Struct.createRoomWithType("CursedTreasure"), 4, rooms);

}

function addTeleports(){
    var rooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel());

    //Turn crosses into teleports
    for( room in rooms ){
        if( room.type == "Corridor" && room.childrenCount > 1 && room.calcTypeDistance("Teleport", true) > 1 ){
            room.setType("Teleport");
        }
    }

    for( room in rooms.filter(function(_room) return _room.type == "CellTreasure")){
        Struct.createTeleportAfter(room);
    }

    //Add extra
    rooms.sort( function(a, b) return compare(a.spawnDistance, b.spawnDistance));
    for( room in rooms ){
        if( room.parent == null || room.spawnDistance <= 1 ){
            continue;
        }

        if( room.hasParentType("TimedDoor") ){
            continue;
        }

        if( room.calcTypeDistance("Teleport", true) > 2 || (room.type == "Combat" && room.parent.type != "Teleport") ){
            Struct.createRoomWithType("Teleport").addBefore(room.getName());
        }
    }
}

function finalize(){
    //Sewer secret
    var targets = Struct.allRooms.filter(function(_room) return _room.spawnDistance >= 4 && _room.isMainLevel() && _room.parent != null);
    var target = Random.arrayPick(targets);
    Struct.createSpecificRoom("SewerSecret").addBefore(target.getName());
    Struct.createRoomWithType("Corridor").addBefore(target.getName());

    //Corridor filers after some rooms
    for( room in Struct.allRooms ){
        if( room.group == "CommonTraps" ){
            Struct.createRoomWithType("Corridor").addAfter(room.getName());
        }
    }

    //Turn corridors into long ones
    var i = 0;
    for( room in Struct.allRooms ){
        if( i % 3 == 0 && (room.type == "Corridor" || room.type == "Teleport") && room.group == "Common" ){
            room.setGroup("Long");
        }
        i++;
    }
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("SewerDepths", _levelProps);
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("SewerDepths", _levelInfo);
}

function buildMobRoster(_mobList){
    addMobRosterFrom("SewerDepths", _mobList);
}