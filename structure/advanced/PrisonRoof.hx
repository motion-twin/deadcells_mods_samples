var exitInBranch : Bool;
function buildMainRooms(){
    exitInBranch = Random.isBelow(0.7);
    Struct.createSpecificRoom("RoofEntrance").setName("start").addFlag(RoomFlag.Outside);
    if( exitInBranch ){
        var list = [];
        list.push("RoofEndSubRoom");
        list.push("RoofEndBridge");
        list.push("RoofEndNothing");
        Struct.createSpecificRoom(Random.arrayPick(list)).setName("end").addFlag(RoomFlag.Outside).addAfter("start");
    }
    else{
        Struct.createSpecificExit("T_Bridge", "RoofEndExit").setName("end").addFlag(RoomFlag.Outside).addAfter("start");
    }

    if( Random.isBelow(0.4) ){
        Struct.createSpecificRoom("RoofSecret").addBetween("start", "end");
    }

    Struct.createRoomWithType("Treasure").setName("Treasure").branchBetween("start", "end");
    Struct.createShop(MerchantType.Actives).branchBetween("cross_Treasure", "end");

    if( Random.isBelow(0.33) ){
        Struct.createRoomWithType("BreakableGroundGate").branchBetween("cross_Treasure", "end")
            .chain(Struct.createRoomWithType("CursedTreasure"));
    }
    else{
         Struct.createRoomWithType("BreakableGroundGate").branchBetween("cross_Treasure", "end")
            .chain(Struct.createRoomWithType("Treasure"));
    }

    if( exitInBranch ){
        Struct.createSpecificExit("T_Bridge", "RoofInnerExit").setName("innerExit").branchBetween("start", "end", 2);
    }
}

function buildSecondaryRooms(){
    //Branch combat rooms
    var branchEnds = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && !_room.hasFlag(RoomFlag.Outside) && _room.childrenCount == 0);
    for( i in 0...4 ){
        Struct.createRoomWithType("Combat").addBefore(Random.arrayPick(branchEnds).getName());
    }

    //Shortcut to beholder
    Struct.createRunicZDoor(Struct.createExit("T_BeholderPit"), 3, [Random.arrayPick(branchEnds)]);

    //Small useless branches
    for(i in 0...Random.irange(1, 2)){
        Struct.createRoomWithType("Combat").branchBetween("start", "end").setName("n" + i);
        Struct.createRoomWithType("Teleport").addAfter("n" + i);
    }

    //Main outside combat rooms
    var addedRooms = Struct.createAndAddRoomsBetween("Combat", "PrisonRoof", exitInBranch ? 6 : 5, "start", ["end"], 0);
    for( room in addedRooms ){
        room.addFlag(RoomFlag.Outside);
    }

    if( exitInBranch ){
        Struct.createRoomWithType("Combat").addBefore("innerExit");
    }

    //Meta key combat room
    var exit = exitInBranch ? Struct.getRoomByName("innerExit") : null;
    var ends = branchEnds.filter(function(_room) return !_room.isChildOf(exit) && _room != exit);
    Random.arrayPick(ends).chain(Struct.createRoomWithType(Random.isBelow(0.5) ? "TeleportGate" : "WallJumpGate"))
        .chain(Struct.createRoomWithType("Combat"));
}

function buildTriggeredDoors(_allCombatRooms : Array){
    _allCombatRooms = _allCombatRooms.filter(function(_room) return !_room.hasFlag(RoomFlag.Outside) && !_room.hasFlag(RoomFlag.InsideOut));
    if( _allCombatRooms.length > 0 && Random.isBelow(0.4) ){
        Random.arrayPick(_allCombatRooms).setGroup("TriggeredDoor");
    }
}

function buildTimedDoors(){
    var dh = new DecisionHelper(Struct.allRooms);
    dh.remove(function(_room) return !_room.isMainLevel() || _room.hasFlag(RoomFlag.Outside) || _room.parent == null);
    dh.score(function(_room) return _room.spawnDistance <= 2 ? -4 : 0);
    dh.score(function(_room) return -_room.spawnDistance);
    dh.score(function(_room) return Random.irange(0, 1));

    Struct.createTimedBranchBefore(dh.getBest());
}

function addTeleports(){
    var branchEnds = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && !_room.hasFlag(RoomFlag.Outside) && _room.childrenCount == 0);
    for( room in branchEnds){
        if( room.calcTypeDistance("Teleport", true) >= 2 ){
            if( room.type == "Combat" ){
                Struct.createTeleportAfter(room);
            }
            else{
                Struct.createTeleportBefore(room);
            }
        }
    }

    //Before metagates
    var end = Struct.getRoomByName("end");
    var gates = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.isMetaGate());
    for( room in gates ){
        if( room.parent != null && !room.parent.isParentOf(end) && room.parent.calcTypeDistance("Teleport", false) > 2 ){
            Struct.createTeleportBefore(room);
        }
    }

    if( exitInBranch ){
        Struct.createTeleportAfter(Struct.getRoomByName("innerExit"));
    }
}

function finalize(){
    var end = Struct.getRoomByName("end");

    //add outside flags
    for( room in Struct.allRooms ){
        if( room.isParentOf(end) && (room.type == "Corridor" || room.type =="Teleport")){
            room.setGroup("PrisonRoof");
            room.addFlag(RoomFlag.Outside);
            if( room.type == "Corridor" && room.calcTypeDistance("Teleport", false) >= 2 ){
                room.setType("Teleport");
            }
        }
    }

    //Spacers
    var targets = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.hasFlag(RoomFlag.Outside) && _room.parent != null && _room.childrenCount > 1);
    for( room in targets ){
        Struct.createRoomWithTypeFromGroup("Corridor", "PrisonRoofSpacer").addBefore(room.getName()).addFlag(RoomFlag.Outside);
        if( Random.isBelow(0.75) ){
            Struct.createRoomWithTypeFromGroup("Corridor", "PrisonRoofSpacer").addBefore(room.getName()).addFlag(RoomFlag.Outside);
        }
    }

    //Runic doors
    var branchRooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.parent != null && _room.hasFlag(RoomFlag.Outside) && !_room.parent.hasFlag(RoomFlag.Outside) && !_room.hasParentType("TimedDoor"));
    Struct.createRunicZDoor(Struct.createShop(MerchantType.Heals), 2, branchRooms);
    Struct.createRunicZDoor(Struct.createRoomWithType("CursedTreasure"), 3, branchRooms);
    Struct.createRunicZDoor(Struct.createRoomWithType("CursedTreasure"), 4, branchRooms);

    //Secret courtyard key converter
    var sRooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.parent != null && _room.spawnDistance >= 4 && !_room.hasFlag(RoomFlag.Outside) && !_room.parent.hasFlag(RoomFlag.Outside));    
    var sn = Struct.createSpecificRoom("RoseKeyConverterRoof").addBefore(Random.arrayPick(sRooms).getName());

    //Init constraints & prio
    for( room in Struct.allRooms ){
        if( room.isMainLevel() && room.parent != null ){
            if( room.hasFlag(RoomFlag.Outside) ){
                room.setChildPriority(1);
                room.setConstraint(LinkConstraint.HorizontalSameDirOnly);
            }
            else if( room.parent.hasFlag(RoomFlag.Outside) ){
                room.setConstraint(LinkConstraint.VerticalOnly);
            }
        }
    }
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("PrisonRoof", _levelProps);
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("PrisonRoof", _levelInfo);
}

function buildMobRoster(_mobList){
    addMobRosterFrom("PrisonRoof", _mobList);
}