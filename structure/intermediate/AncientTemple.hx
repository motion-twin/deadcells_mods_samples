var branches : Array<String> = [];
var mainCombats : Array<RoomNode> = [];

function buildMainRooms(){
    var switchRoom = Struct.createRoomWithTypeFromGroup("AncientTempleSwitch", "AncientTemple");
    Struct.createSpecificRoom("AncientEntrance").setName("start")
        .chain(switchRoom.setName("end"));

    branches.push(switchRoom.getName());
    for( room in Struct.createAndAddRoomsBetween("Combat", "AncientTemple", 1, "start", ["end"], 0)){ mainCombats.push(room); }
    for( room in Struct.createAndAddRoomsBetween("Combat", "", 2, "start", ["end"], 0)){ mainCombats.push(room); }

    createBranch(Struct.createExit("T_Crypt").setName("eCrypt"));
    createBranch(Struct.createExit("T_ClockTower").setName("eClock"));

    Struct.createShopWithType(MerchantType.Weapons).branchOrAddBetween("start", branches, 2);
    Struct.createShopWithType(MerchantType.Actives).branchOrAddBetween("start", branches, 2);
    Struct.createRoomWithTypeFromGroup("Treasure", "AncientTemple").branchOrAddBetween("start", branches, 2);
    Struct.createRoomWithType("CursedTreasure").branchOrAddBetween("start", branches, 2);
}

function createBranch(_roomNode : RoomNode){
    var start = Random.arraySplice(mainCombats);

    if( Random.isBelow(0.6) ){
        start.addChild(Struct.createSpecificRoom("AncientCells"));
    }

    start = Struct.createCross("").addAfter(start.getName());
    var interRoom = Struct.createSpecificRoom("InterRoom").setName("inter_" + _roomNode.getName());
    start.addChild(interRoom);
    _roomNode.addAfter(interRoom.getName());
    branches.push(_roomNode.getName());
    Struct.createAndAddRoomsBetween("Combat", "ATCombatBack", 2, interRoom.getName(), [_roomNode.getName()], 0);
}

function buildSecondaryRooms(){
    if( !Meta.hasMetaRune("WallJumpKey") ){
        Struct.createRoomWithTypeFromGroup("MetaWallJumpKey", "AncientTempl").addBefore("end");
    }

    //Z doors
    var rooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.spawnDistance > 2 && _room.parent != null);
    Struct.createRunicZDoor(Struct.createRoomWithType("CursedTreasure"), 1, rooms);
    Struct.createRunicZDoor(Struct.createShopWithType(MerchantType.Heals), 2, rooms);
    Struct.createRunicZDoor(Struct.createRoomWithType("Treasure"), 3, rooms);
}

function buildMobRoster(_mobList){
    addMobRosterFrom("AncientTemple", _mobList);
}

function addTeleports(){
    for( b in branches ){
        Struct.createTeleportAfter(Struct.getRoomByName(b));
    }
    
    Struct.createTeleportAfter(Struct.getRoomByName("start"));

    for( room in Struct.allRooms.filter(function(_room) return _room.type == "ATInterRoom") ){
        Struct.createTeleportAfter(room);
    }

    var targets = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.parent != null && _room.hasParentType("ATInterRoom"));
    targets.sort(function(a, b) return compare(a.spawnDistance, b.spawnDistance));
    for( room in targets ){
        if( room.calcTypeDistance("Teleport", true) >= 3 ){
            Struct.createTeleportBefore(room);
        }
    }
}

function finalize(){
    var targets = Struct.allRooms.filter(function(_room) return _room.parent != null && _room.childrenCount > 0 && _room.spawnDistance >= 3 && _room.type == "Teleport" && _room.hasParentType("Teleport"));
    var room = Struct.createSpecificRoom("AncientPit").addBefore(Random.arrayPick(targets).getName());
    Struct.createTeleportBefore(room);
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("AncientTemple", _levelInfo); 
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("AncientTemple", _levelProps);
}
