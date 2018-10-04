var exits : Array<String>;
function buildMainRooms(){
    Struct.createSpecificRoom("SewerShortEntrance").setName("start")
        .chain(Struct.createCross("exitCross"))
        .chain(Struct.createExit("T_Roof").setName("eRoof"));

    Struct.getRoomByName("exitCross").chain(Struct.createExit("T_SewerDepths").setName("eDepths"));
    Struct.createRoomWithType("BreakableGroundGate").addBefore("eDepths").setName("gDepths");
    
    Struct.createRoomWithType("Treasure").branchBetweenMultipleEnds("exitCross", ["gDepths", "eRoof"], 0);
    Struct.createRoomWithType("DualTreasure").addBetween("start", "eRoof", 2);
    Struct.createRoomWithType("BuyableTreasure").branchOrAddBetween("exitCross", ["gDepths", "eRoof"], 3);
    if( Random.isBelow(0.1) ){
        Struct.createRoomWithType("CursedTreasure").branchOrAddBetween("exitCross", ["gDepths", "eRoof"], 3);
    }
    Struct.createShop().branchOrAddBetween("exitCross", ["gDepths", "eRoof"], 2);
}

function buildTimedDoors(){
    var dh = new DecisionHelper(Struct.allRooms);
    dh.remove(function(_room) return !_room.isMainLevel() || _room.parent == null);
    dh.score(function(_room) return _room.spawnDistance <= 1 ? 2 : _room.spawnDistance >= 3 ? -10 : 0);
    dh.score(function(_room) return Random.irange(0, 1));
    Struct.createTimedBranchBefore(dh.getBest());
}

function buildSecondaryRooms(){
    var exits = ["eRoof", "eDepths"];

    Struct.createAndAddRoomsBetween("Combat", "SewerLabyrinth", 2, "start", ["exitCross"], 0);
    Struct.createAndAddRoomsBetween("Combat", "SewerCorridor", 1, "start", ["exitCross"], 0);
    Struct.createAndAddRoomsBetween("Combat", "SewerCorridor", 2, "exitCross", exits, 0);
    Struct.createAndAddRoomsBetween("Combat", "SewerLabyrinth", 1, "exitCross", exits, 0);
    Struct.createAndAddRoomsBetween("Combat", "NeedLadder", 1, "start", exits, 0);
    Struct.createAndAddRoomsBetween("Combat", "NeedTeleport", 1, "start", exits, 0);
    Struct.createAndAddRoomsBetween("Combat", "NeedWallJump", 1, "start", exits, 0);

    Struct.createAndAddRoomsBetween("Combat", "MinorSecret", 1, "start", ["exitCross"], 0);

    //Meta boss
    if( !Meta.hasMetaRune("TeleportKey") ){
        var exit = Struct.getRoomByName("eRoof");
        var rooms = Struct.allRooms.filter(function(_room) return _room.isParentOf(exit) && _room.spawnDistance > 2);
        var room =  Struct.createSpecificRoom("TeleportGateKey")
            .branchBetween(Random.arrayPick(rooms).getName(), "eRoof");
    }

    var rooms = Struct.allRooms.filter(function(_room) _room.isMainLevel() && _room.spawnDistance > 2 && _room.parent != null);
    Struct.createRunicZDoor(Struct.createRoomWithType("Treasure"), 1, rooms);
    Struct.createRunicZDoor(Struct.createRoomWithType("CursedTreasure"), 2, rooms);
    Struct.createRunicZDoor(Struct.createRoomWithType("Treasure"), 4, rooms);
}

function addTeleports(){
    var rooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel());

    //Turn crosses into teleports
    for( room in rooms ){
        if( room.type == "Corridor" && room.childrenCount > 1 && room.calcTypeDistance("Teleport", true) > 1 ){
            room.setType("Teleport");
        }
    }

    for (room in rooms.filter(function(_room) return _room.type == "CellTreasure")){
        Struct.createTeleportAfter(room);
    }

    //Add extra
    rooms.sort(function(a, b) return compare(a.spawnDistance, b.spawnDistance));
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

function setLevelProps(_levelProps){
    setLevelPropsFrom("SewerShort", _levelProps);
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("SewerShort", _levelInfo);
}

function buildMobRoster(_mobList){
    addMobRosterFrom("SewerShort", _mobList);
}