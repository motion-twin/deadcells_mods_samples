function buildMainRooms(){
    Struct.createSpecificRoom("CEntrance").addFlag(RoomFlag.Outside).setName("start")
            .chain( Struct.createSpecificExit("MySecondLevel", "CEndExit").addFlag(RoomFlag.Outside).setName("MySecondLevel") )
			.chain( Struct.createSpecificRoom("CTeleportGate") )
			.chain( Struct.createSpecificExit("MyThirdLevel", "COssuaryExit").setName("MyThirdLevel") );

    Struct.createShop(MerchantType.Weapons).branchBetween("start", "MySecondLevel");
	Struct.createShop(MerchantType.Actives).setName("shop2").branchBetween("start", "MyThirdLevel");
    Struct.createRoomWithType("TeleportGate").addBefore("shop2");

    Struct.createRoomWithTypeFromGroup("DualTreasure", "DualTreasureOutside").addFlag(RoomFlag.Outside).addBetween("start", "MySecondLevel", 2);

    if( Random.isBelow(0.3) ){
        Struct.createRoomWithTypeFromGroup("HealPotion", "Courtyard").addFlag(RoomFlag.Outside).addBetween("start", "MySecondLevel");
    }

    if( Random.isBelow(0.1) ){
        Struct.createRoomWithTypeFromGroup("CursedTreasure", "Courtyard").addFlag(RoomFlag.Outside).addBetween("start", "MySecondLevel");
    }

    if( Random.isBelow(0.2) ){
        Struct.createRoomWithType("Treasure").branchBetween("start", "MySecondLevel");
    }

    Struct.createSpecificRoom("CLadderGate").setName("cliff")
        .addBetween("start", "MySecondLevel", 2)
        .addZChild(Struct.createSpecificRoom("CLadderGateKey") );

    Struct.createExit("MyFourthLevel").branchBetween("cliff", "MySecondLevel").setName("MyFourthLevel");
    Struct.createRoomWithType("WallJumpGate").addBefore("MyFourthLevel");

    var exit = Struct.getRoomByName("MySecondLevel");
    var undergrounds = Struct.allRooms.filter(function(_room) return _room != exit && _room.isMainLevel() && !_room.isParentOf(exit) && !_room.isChildOf(exit));
    Struct.createRunicZDoor(Struct.createShop(), 1, undergrounds);
    Struct.createRunicZDoor(Struct.createRoomWithType("CellTreasure"), 2, undergrounds);
    Struct.createRunicZDoor(Struct.createRoomWithType("Treasure"), 3, undergrounds);
    Struct.createRunicZDoor(Struct.createRoomWithType("Treasure"), 4, undergrounds);
}

function buildSecondaryRooms(){
    trace("buildSecondaryRooms");
    var exit = Struct.getRoomByName("MySecondLevel");
    var mains = Struct.allRooms.filter(function(_room) return _room.parent != null && _room != exit && _room.isMainLevel() && _room.isParentOf(exit) && _room.childrenCount > 1);
    var mainsCopy = mains.copy();
    for(i in 0...4){
        if( mainsCopy.length == 0 ){
            mainsCopy = mains.copy();
        }
        Struct.createRoomWithTypeFromGroup("Combat", "Courtyard").addFlag(RoomFlag.Outside).addBefore(Random.arraySplice(mainsCopy).getName());
    }

    Struct.createRoomWithTypeFromGroup("Combat", "Courtyard").addFlag(RoomFlag.Outside).addBefore("MySecondLevel");
    Struct.createRoomWithTypeFromGroup("Combat", "NeedStompOutside").addFlag(RoomFlag.Outside).addBefore(Random.arrayPick(mains).getName());

    //Outside traps
    var rooms = Struct.allRooms.filter(function(_room) return _room.type == "Combat" && _room.hasFlag(RoomFlag.Outside));
    for( i in 0...Random.irange(2, 3) ){
        Struct.createRoomWithTypeFromGroup("Trap_1", "Courtyard").addFlag(RoomFlag.Outside).addBefore(Random.arraySplice(rooms).getName());
    }

    //Underground combat
    var branches = Struct.allRooms.filter(function(_room) return _room != exit && _room.isMainLevel() && !_room.isParentOf(exit) && !_room.isChildOf(exit));
    for( i in 0...2){
        Struct.createRoomWithType("Combat").addBefore(Random.arrayPick(branches).getName());
    }
    Struct.createRoomWithTypeFromGroup("Combat", "MinorSecret").addBefore(Random.arrayPick(branches).getName());

    //Underground traps
    for( i in 0...Random.irange(2, 3) ){
        Struct.createRoomWithTypeFromGroup("Trap_1", "CommonTraps").addBefore(Random.arrayPick(branches).getName());
    }
}

function addTeleports(){
    var exit = Struct.getRoomByName("MySecondLevel");
    var rooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() );

    //Turn crosses into teleports
    for( room in rooms ){
        if( room.type == "Corridor" && room.isParentOf(exit) && room.childrenCount > 1 && room.calcTypeDistance("Teleport", true) > 1 ){
            room.setType("Teleport");
        }
    }

    //Secrets
    var outRooms = Struct.allRooms.filter(function(_room) return _room.isMainLevel() && _room.parent != null && _room.isParentOf(exit) );
    Struct.createSpecificRoom("CSecretStomp").addFlag(RoomFlag.Outside).addBefore(Random.arraySplice(outRooms).getName());
    Struct.createSpecificRoom("CSecretWallJump").addFlag(RoomFlag.Outside).addBefore(Random.arraySplice(outRooms).getName());
    Struct.createSpecificRoom("CSecretHouse").addFlag(RoomFlag.Outside).addBefore(Random.arraySplice(outRooms).getName());
    Struct.createSpecificRoom("CSecretFlower").addFlag(RoomFlag.Outside).addBefore(Random.arraySplice(outRooms).getName());

    //Meta gates teleport
    for( room in rooms.filter(function(_room) return !_room.hasFlag(RoomFlag.Outside) && (_room.type == "WallJumpGate" || _room.type == "LadderGate" || _room.type == "TeleportGate" || _room.type == "BreakableGroundGate")) ){
        if( room.calcTypeDistance("Teleport", false) > 1 ){
            Struct.createTeleportBefore(room);
        }
    }

    //Dead Ends
    var secondExit = Struct.getRoomByName("MyThirdLevel");
    for( room in rooms ){
        if( room.childrenCount == 0 && room != secondExit && room.calcTypeDistance("Teleport", true) > 1 ){
            Struct.createRoomWithType("Teleport").addBefore(room.getName());
        }
    }

    if( exit.parent.type != "Teleport" ){
        Struct.createRoomWithTypeFromGroup("Teleport", "Courtyard").addFlag(RoomFlag.Outside).addBefore(exit.getName());
    }

    //Add extra
    var nodes = rooms.filter(function(_room) return _room.isMainLevel() && _room.hasFlag(RoomFlag.Outside));
    nodes.sort(function(a, b) return compare(a.spawnDistance, b.spawnDistance));
    for( n in nodes ){
        if( n.spawnDistance > 1 && n.prent != null && n.calcTypeDistance("Teleport", true) > 2 ){
            if( n.hasFlag(RoomFlag.Outside) ){
                Struct.createRoomWithTypeFromGroup("Teleport", "Courtyard").addFlag(RoomFlag.Outside).addBefore(n.getName());
            }
            else{
                Struct.createRoomWithType("Teleport").addBefore(n.getName());
            }
        }
    }
}

function buildTimedDoors(){
    var cliff = Struct.getRoomByName("cliff");
    var dh = new DecisionHelper(Struct.allRooms);
    dh.remove(function(_room) return !_room.isMainLevel() || !_room.hasFlag(RoomFlag.Outside) || _room.isParentOf(cliff) || _room.parent == null);
    dh.score(function(_room) return _room.spawnDistance <= 1 ? - 4 : _room.spawnDistance >= 3 ? -10 : 0);
    dh.score(function(_room) return Random.irange(0, 1));

    Struct.createTimedBranchBefore(dh.getBest());
}

function finalize(){
    var exit = Struct.getRoomByName("MySecondLevel");

    //Update outside corridors
    for( room in Struct.allRooms ){
        if( (room.type == "Corridor" || room.type == "Teleport") && room.isParentOf(exit) ){
            room.setGroup("Courtyard");
            room.addFlag(RoomFlag.Outside);
        }
    }

    //Add vertical elevator spacers
    for( room in Struct.allRooms.copy() ){
        if( room != exit && room.isMainLevel() && ! room.isParentOf(exit) && room.parent != null && room.parent.isParentOf(exit) ){
            Struct.createRoomWithTypeFromGroup("Corridor", "CourtyardVerticalCorridor").addBefore(room.getName());
        }
    }

    //Switch useless corridors to Combat corridors
    for( room in Struct.allRooms ){
        if( room.type == "Corridor" && room.hasFlag(RoomFlag.Outside) && room.childrenCount > 1 ){
            room.setType("Combat");
            room.setGroup("CourtyardCombatCorridor");
        }
    }

    //Buyable cells
    if( Random.isBelow(0.15) ){
        var branches = Struct.allRooms.filter(function(_room) return _room != exit && _room.isMainLevel() && !_room.isParentOf(exit) && !_room.isChildOf(exit) );
        if( branches.length > 0 ){
            Struct.createRoomWithType("BuyableCells").addBefore(Random.arrayPick(branches).getName());
        }
    }

    for( room in Struct.allRooms ){
        if( room.parent != null && room.hasFlag(RoomFlag.Outside) ){
            room.setConstraint(LinkConstraint.HorizontalSameDirOnly);
            room.setChildPriority(1);
        }
    }
}

function setLevelProps(_levelProps){
    setLevelPropsFrom("PrisonCourtyard", _levelProps);
}

function setLevelInfo(_levelInfo){
    setLevelInfoFrom("PrisonCourtyard", _levelInfo);
    _levelInfo.baseMobTier = 1;
    _levelInfo.extraMobTier = 0;
}

function buildMobRoster(_mobList){
    addMobRosterFrom("PrisonCourtyard", _mobList);
}