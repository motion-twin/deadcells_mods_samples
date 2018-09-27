function buildMainRooms(){
    //Main elements
    Struct.createSpecificRoom("CemEntrance").setName("start").addFlag(RoomFlag.Outside)
            .chain(Struct.createSpecificRoom("CemBigCrypt").setName("bigCrypt").addFlag(RoomFlag.Outside))
            .chain(Struct.createSpecificRoom("CemEnd").addFlag(RoomFlag.Outside).setName("end"));

    //Create base crypts
    var room = Struct.createRoomWithTypeFromGroup("Combat", "CemeteryCryptOutside").addFlag(RoomFlag.Outside);
    if( Random.isBelow(0.5) ){
        room.addBefore("end");
    }
    else{
        room.addAfter("start");
    }

    room = Struct.createRoomWithTypeFromGroup("Combat", "CemeteryCryptOutsideShort").addFlag(RoomFlag.Outside);
    if( Random.isBelow(0.5) ){
        room.addBefore("end");
    }
    else{
        room.addAfter("start");
    }

    var allCrypts = Struct.allRooms.filter(function(_room){ trace("_room.group = " + _room.group); return _room.type == "Combat" && (_room.group == "CemeteryCryptOutside" || _room.group == "CemeteryCryptOutsideShort");});

    //Build the crypt with the key
    var crypt = Random.arraySplice(allCrypts);
    var room = Struct.createSpecificRoom("CemBigCryptKey");
    addCryptContent(crypt, 2, room, ZDoorContentClue.CKey);

    //Random crypt Contents
    var contents = [ { room : Struct.createRoomWithType("Treasure"), clue : ZDoorContentClue.CTreasure} ];
    while( contents.length > 0 && allCrypts.length > 0 ){
        var crypt = Random.arraySplice(allCrypts);
        var content = Random.arraySplice(contents);
        addCryptContent(crypt, Random.irange(0, 1), content.room, content.clue);
    }

    //Remaining crypts have small rewards
    while( allCrypts.length > 0 ){
        var crypt = Random.arraySplice(allCrypts);
        var content = switch( Random.irange(0, 2)){
            case 0 : Struct.createRoomWithTypeFromGroup("Combat", "NeedWallJump");
            case 1 : Struct.createRoomWithTypeFromGroup("Combat", "NeedStomp");
            default : Struct.createRoomWithTypeFromGroup("Combat", "NeedTeleport");
        }
        addCryptContent(crypt, Random.irange(0, 1), content, ZDoorContentClue.None);
    }

    //Dungeon under the crypt
    Struct.getRoomByName("bigCrypt").chain(Struct.createExit("T_Crypt").setName("exit"));

    var treasure = Random.isBelow(0.8) ? Struct.createRoomWithType("CursedTreasure") : Struct.createRoomWithType("Treasure");
    treasure.branchBetween("bigCrypt", "exit", 0);
    Struct.createRoomWithType("CursedTreasure").addBetween("bigCrypt", "exit", 0);
    if( Random.isBelow(0.5) ){
        Struct.createRoomWithType("CursedTreasure").branchBetween("bigCrypt", "exit", 0);
    }
    Struct.createShop().branchBetween("bigCrypt", "exit");
    Struct.createRoomWithType("BuyableCells").addBetween("bigCrypt", "exit");

    if( Random.isBelow(0.1) ){
        Struct.createRoomWithType("Treasure").branchOrAddBetween("bigCrypt", ["exit"], 4);
    }

    //Block all treasures behind ground gates
    var treasures = Struct.allRooms.filter(function(_room) return _room.type == "CursedTreasure" || _room.type == "Treasure");
    for( room in treasures ){
        Struct.createRoomWithType("BreakableGroundGate").addBefore(room.getName());
    }
}

function addCryptContent(_entrance : RoomNode, _combatRoomCount: Int, _content : RoomNode, _clue : ZDoorContentClue){
    var room = Struct.createRoomWithTypeFromGroup("Corridor", "CemeteryCryptDoor");
    room.forceBiome("CemeteryInt");
    for( i in 0..._combatRoomCount ){
        room = room.chain(Random.isBelow(0.9) ? Struct.createRoomWithType("Combat") : Struct.createRoomWithTypeFromGroup("Trap_1", "CommonTraps"));
    }

    if( Random.isBelow(0.4) ){
        room = room.chain(Struct.createRoomWithTypeFromGroup("Trap_1", "CommonTraps"));
    }

    if( _content != null ){
        room.chain(_content);
        while( room.childrenCount > 0 ){
            room = room.firstChild; // position on the end of the content (if it has multiple rooms)
        }
    }

    if( room.parent != null ){
        room = room.chain(Struct.createRoomWithType("EntranceTeleport"));
    }

    _entrance.addZChildWithClue(room.root, _clue);
}

function buildSecondaryRooms(){
    var entrance = Struct.getRoomByName("bigCrypt");
    var exit = Struct.getRoomByName("exit");
    var dungeon = Struct.allRooms.filter(function(_room) return !_room.hasFlag(RoomFlag.Outside) && _room.isMainLevel() && _room.isChildOf(entrance));
    var brancheEnds = dungeon.filter(function(_room) return _room != exit && !_room.isParentOf(exit));

    //Combat rooms in dungeon
    for( i in 0...1 ){
        Struct.createRoomWithType("Combat").addBefore(Random.arrayPick(brancheEnds).getName());
    }

    for( i in 0...2 ){
        Struct.createRoomWithType("Combat").addBetween("bigCrypt", "exit", 0);
    }
    Struct.createRoomWithTypeFromGroup("Combat", "MinorSecret").addBetween("bigCrypt", "exit", 0);

    //Combats with sub meta gates
    if( Random.isBelow(0.33) ){
        Struct.createRoomWithTypeFromGroup("Combat", "NeedWallJump").addBefore(Random.arrayPick(brancheEnds).getName());
    }

    if( Random.isBelow(0.25) ){
        Struct.createRoomWithTypeFromGroup("Combat", "NeedStomp").addBefore(Random.arrayPick(brancheEnds).getName());
    }

    //Traps in dungeon
    for( i in 0...3 ){
        Struct.createRoomWithTypeFromGroup("Trap_2", "CommonTraps").addBefore(Random.arrayPick(dungeon).getName());
    }

    //Meta room outside
    var end = Struct.getRoomByName("end");
    var outs = Struct.allRooms.filter(function(_room) return _room.isParentOf(end) && _room.parent != null);
    Struct.createRoomWithTypeFromGroup("Combat", "NeedStompOutside").addFlag(RoomFlag.Outside).addBefore(Random.arrayPick(outs).getName());
    if( Random.isBelow(0.75) ){
        Struct.createRoomWithTypeFromGroup("Combat", "NeedStompOutside").addFlag(RoomFlag.Outside).addBefore(Random.arrayPick(outs).getName());
    }
    if( Random.isBelow(0.15) ){
        Struct.createRoomWithTypeFromGroup("Combat", "NeedStompOutside").addFlag(RoomFlag.Outside).addBefore(Random.arrayPick(outs).getName());
    }

    //Z doors
    Struct.createRunicZDoor(Struct.createRoomWithType("DualTreasure"), 1, dungeon);
    Struct.createRunicZDoorWithCombatCount(Struct.createRoomWithType("CellTreasure"), 2, 0, dungeon);
    Struct.createRunicZDoor(Struct.createRoomWithType("CellTreasure"), 3, dungeon);
    Struct.createRunicZDoorWithCombatCount(Struct.createRoomWithType("DualTreasure"), 4, 0, dungeon);

    //Secret Courtyard key converter
    var rooms = dungeon.filter(function(_room) return _room.parent != null && _room.spawnDistance >= 4);
    var secretRoom = Struct.createSpecificRoom("RoseKeyConverter").addBefore(Random.arrayPick(rooms).getName());
}

function buildTimedDoors(){
    var room = Struct.createRoomWithTypeFromGroup("Combat", "CemeteryCryptOutsideShort").addFlag(RoomFlag.Outside).addAfter("start");
    addCryptContent(room, 0, Struct.createTimedBranch(), ZDoorContentClue.CTimedDoor);
}

function finalize(){
    for( room in Struct.allRooms ){
        if( room.parent != null && room.hasFlag(RoomFlag.Outside) ){
            room.setConstraint(LinkConstraint.HorizontalSameDirOnly);
        }
    }

    //Add secret architect key
    var bigCrypt = Struct.getRoomByName("bigCrypt");
    var dungeon = Struct.allRooms.filter(function(_room) return _room.type == "Combat" && !_room.hasFlag(RoomFlag.Outside) && _room.isMainLevel() && _room.isChildOf(bigCrypt));
    var keyRoom = Random.arrayPick(dungeon);
    keyRoom.setItemInWall("CemSecretKey");
}

function addTeleports(){
    var rooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel());
    rooms.sort(function(a, b) return compare(a.spawnDistance, b.spawnDistance));

    //turn most dungeon crosses into teleport
    for( room in rooms ){
        if( !room.hasFlag(RoomFlag.Outside) && room.type == "Corridor" && room.calcTypeDistance("Teleport", false) > 1 ){
            room.setType("Teleport");
        }
    }

    //Add to dead ends
    for( room in rooms ){
        if( !room.hasFlag(RoomFlag.Outside) && room.childrenCount == 0 && room.calcTypeDistance("Teleport", false) > 1 ){
            Struct.createTeleportAfter(room);
        }
    }

    //Add extra missing teleports in dungeon
    for( room in rooms ){
        if( !room.hasFlag(RoomFlag.Outside) && room.spawnDistance > 1 && room.parent != null && room.calcTypeDistance("Teleport", true) > 3 ){
            Struct.createTeleportBefore(room);
        }
    }

    //Add important teleporters
    Struct.createRoomWithTypeFromGroup("Teleport", "Cemetery").addFlag(RoomFlag.Outside).addBefore("end");
    Struct.createRoomWithTypeFromGroup("Teleport", "Cemetery").addFlag(RoomFlag.Outside).addBefore("bigCrypt");

    //Add outside teleports
    for( room in rooms ){
        if( room.hasFlag(RoomFlag.Outside) && room.parent != null && room.calcTypeDistance("Teleport", true) > 2 ){
            Struct.createRoomWithTypeFromGroup("Teleport", "Cemetery").addFlag(RoomFlag.Outside).addBefore(room.getName());
        }
    }
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("Cemetery", _levelProps);
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("Cemetery", _levelInfo);
}

function buildMobRoster(_mobList){
    addMobRosterFrom("Cemetery", _mobList);
}