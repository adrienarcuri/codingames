import 'dart:io';

/// ENUMS
enum MoleculeType { A, B, C, D, E }

enum ModuleType { DIAGNOSIS, MOLECULES, LABORATORY, SAMPLES, CENTER }

enum StateType { CHOOSE, ANALYSE, COLLECT, PRODUCE }

/// DEBUG
void debug(e) => stderr.writeln(e);

/// UTILS
class Util {
  static File chooseFile(List<File> files) {
    var _files = [...files];

    // Retains only files in the cloud
    _files.retainWhere((element) => element.carriedBy == 0);
    // Sort files by gain
    _files.sort((f1, f2) => f1.ratio.compareTo(f2.ratio));
    // Choose the file with the maximal gain

    return _files.last;
  }

  static List<File> playerCarriedFiles(List<File> files, [int playerId = 0]) {
    var _files = [...files];
    _files.retainWhere((element) => element.carriedBy == playerId);
    return _files;
  }

  static toShortString(dynamic T) {
    return T.toString().split('.').last;
  }

  static ModuleType toModuleType(String s) {
    if (s == Util.toShortString(ModuleType.DIAGNOSIS)) {
      return ModuleType.DIAGNOSIS;
    }
    if (s == Util.toShortString(ModuleType.LABORATORY)) {
      return ModuleType.LABORATORY;
    }
    if (s == Util.toShortString(ModuleType.MOLECULES)) {
      return ModuleType.MOLECULES;
    }
    return ModuleType.SAMPLES;
  }
}

/// PLAYER
class Player {
  Player({
    this.id,
    this.score,
    this.robot,
    this.expertiseA,
    this.expertiseB,
    this.expertiseC,
    this.expertiseD,
    this.expertiseE,
  });

  /// Player id, 0 = me, 1 = ennemy
  int id;

  /// Score of the player
  int score;

  /// Expertise for each molecule type
  int expertiseA;
  int expertiseB;
  int expertiseC;
  int expertiseD;
  int expertiseE;

  /// Robot of the player
  Robot robot;

  @override
  String toString() {
    return 'PLAYER- '
        'id: $id '
        'id: $score '
        'expertiseA: $expertiseA '
        'expertiseB: $expertiseB '
        'expertiseC: $expertiseC '
        'expertiseD: $expertiseD '
        'expertiseE: $expertiseE '
        'robot: $robot ';
  }
}

/// PROJECT
class Project {
  Project(this.expertiseA, this.expertiseB, this.expertiseC, this.expertiseD,
      this.expertiseE);

  /// Number of scientific projects
  static int count;

  /// Required expertise for A molecule
  int expertiseA;

  /// Required expertise for B molecule
  int expertiseB;

  /// Required expertise for C molecule
  int expertiseC;

  /// Required expertise for D molecule
  int expertiseD;

  /// Required expertise for E molecule
  int expertiseE;

  @override
  String toString() {
    var s = 'PROJECT:'
        '\n ';
    var props = [
      'expertiseA:$expertiseA',
      'expertiseB:$expertiseB',
      'expertiseC:$expertiseC',
      'expertiseD:$expertiseD',
      'expertiseE:$expertiseE',
    ].join(' ');
    s += props;
    return s;
  }
}

/// ROBOT
class Robot {
  static const int maxFile = 3;
  static const int maxMolecules = 10;

  Robot({
    this.target,
    this.eta,
    this.files,
    this.storageA,
    this.storageB,
    this.storageC,
    this.storageD,
    this.storageE,
  });

  /// Module where the robot is
  ModuleType target;

  /// Number of turns before the robot reach the module (O if on the module)
  int eta;

  /// Files carried by the robot
  List<File> files;

  /// Number of molecules carried by the robot
  int storageA;
  int storageB;
  int storageC;
  int storageD;
  int storageE;

  bool get hasCarriedFile => files.isNotEmpty;

  bool get hasDiagFile {
    var file =
        files.firstWhere((file) => file.health != -1, orElse: () => null);

    if (file != null) {
      return true;
    }
    return false;
  }

  List<File> getDiagFiles() =>
      files.where((file) => file.health != -1).toList();

  List<File> getNonDiagFiles() =>
      files.where((file) => file.health == -1).toList();

  bool canProduce(File f) {
    if (f == null) {
      return false;
    }

    if (f.costA == -1 ||
        f.costB == -1 ||
        f.costC == -1 ||
        f.costD == -1 ||
        f.costE == -1) {
      return false;
    }

    if (storageA < f.costA) {
      return false;
    }
    if (storageB < f.costB) {
      return false;
    }
    if (storageC < f.costC) {
      return false;
    }
    if (storageD < f.costD) {
      return false;
    }
    if (storageE < f.costE) {
      return false;
    }
    return true;
  }

  MoleculeType whichMoleculeToCollect(File f) {
    if (storageA < f.costA) {
      return MoleculeType.A;
    }
    if (storageB < f.costB) {
      return MoleculeType.B;
    }
    if (storageC < f.costC) {
      return MoleculeType.C;
    }
    if (storageD < f.costD) {
      return MoleculeType.D;
    }
    if (storageE < f.costE) {
      return MoleculeType.E;
    }
    return MoleculeType.A;
  }

  @override
  String toString() {
    return 'ROBOT- '
        'target: ${Util.toShortString(target)} '
        'eta: $eta '
        'storageA: $storageA '
        'storageB: $storageB '
        'storageC: $storageC '
        'storageD: $storageD '
        'storageE: $storageE '
        'files: $files';
  }
}

// FILE
class File {
  File({
    this.id,
    this.carriedBy,
    this.health,
    this.rank,
    this.gain,
    this.costA,
    this.costB,
    this.costC,
    this.costD,
    this.costE,
  });

  /// id of the file
  int id;

  /// indicates if the file is carried by a player (not carried:-1, player0: 0, player1: 1)
  int carriedBy;

  /// health of the file
  int health;

  /// Rank of the file
  int rank;

  /// Expertise gain of the file in A, B, C, D E
  String gain;

  int costA;
  int costB;
  int costC;
  int costD;
  int costE;

  /// Return the total cost in molecule
  int get totalCost => costA + costB + costC + costD + costE;

  /// Return the ratio of earned health by total cost in molecule
  double get ratio => health / totalCost;

  @override
  String toString() {
    var s = 'FILE:';
    var props = [
      'id:$id',
      'carriedBy:$carriedBy',
      'health:$health',
      'rank:$rank',
      'gain:$gain',
      'costA:$costA',
      'costB:$costB',
      'costC:$costC',
      'costD:$costD',
      'costE:$costE',
    ].join(' ');
    s += props;
    return s;
  }
}

/// COMMANDS
class Commands {
  ///  Make the robot go the specific module [moduleType]
  static void goTo(ModuleType moduleType) {
    String moduleName = Util.toShortString(moduleType);
    print('GOTO $moduleName');
  }

  /// Make the robot get a sample file of a specific [rank]
  static void connectSamples(int rank) {
    _connect(rank.toString());
  }

  /// Make the robot connect to the Diagnosis Module to diagnose the file [fileId]
  ///
  /// The robot must care the file of id [fileId]
  static void connectDiagnosis(String fileId) {
    _connect(fileId);
  }

  /// Make the robot connect the Molecules Module to create a molecule of type [moleculeType]
  static void connectMolecules(MoleculeType moleculeType) {
    String moleculeName = Util.toShortString(moleculeType);
    _connect(moleculeName);
  }

  /// Make the robot connect to the Laboratory Module to create medecines for the file [fileId]
  ///
  /// The robot should care the file of id [fileId]
  static void connectLaboratory(String fileId) {
    _connect(fileId);
  }

  static void _connect(String e) {
    print('CONNECT $e');
  }
}

/// STATE MACHINE
class State {
  StateType _state;
  File _chosenFile;
  bool hasSample = false;

  bool get hasFile => _chosenFile != null;
  bool get hasMolecules => Game.player0.robot.hasDiagFile
      ? Game.player0.robot.canProduce(Game.player0.robot.getDiagFiles().first)
      : false;
  File get chosenFile => _chosenFile;
  StateType get state => _state;

  evalState() {
    if (!hasSample && !hasFile && !hasMolecules) {
      _state = StateType.CHOOSE;
    } else if (hasSample && !hasFile && !hasMolecules) {
      _state = StateType.ANALYSE;
    } else if (hasSample && hasFile && !hasMolecules) {
      _state = StateType.COLLECT;
    } else if (hasSample && hasFile && hasMolecules) {
      _state = StateType.PRODUCE;
    }
  }

  actions() {
    switch (_state) {
      case StateType.CHOOSE:
        // If Robot is not in DIAGNOSIS Module, go there
        if (ModuleType.SAMPLES != Game.player0.robot.target) {
          Commands.goTo(ModuleType.SAMPLES);
        }
        // Else choose a file
        else {
          var rank = 1;
          hasSample = true;
          Commands.connectSamples(rank);
        }
        break;
      case StateType.ANALYSE:
        // If Robot is not in DIAGNOSIS Module, go there
        if (ModuleType.DIAGNOSIS != Game.player0.robot.target) {
          Commands.goTo(ModuleType.DIAGNOSIS);
        }
        // Else choose a file
        else {
          _chosenFile = Game.player0.robot.getNonDiagFiles().first;
          Commands.connectDiagnosis(_chosenFile.id.toString());
        }
        break;
      case StateType.COLLECT:
        // If Robot is not in MOLECULES Module, go there
        if (ModuleType.MOLECULES != Game.player0.robot.target) {
          Commands.goTo(ModuleType.MOLECULES);
        }
        // Else collect molecules
        else {
          var moleculeType = Game.player0.robot
              .whichMoleculeToCollect(Game.player0.robot.getDiagFiles().first);
          Commands.connectMolecules(moleculeType);
        }
        break;
      case StateType.PRODUCE:
        // If Robot is not in LABORATORY Module, go there
        if (ModuleType.LABORATORY != Game.player0.robot.target) {
          Commands.goTo(ModuleType.LABORATORY);
        }
        // Else produce
        else {
          var fileId = _chosenFile.id;
          hasSample = false;
          _chosenFile = null;
          Commands.connectLaboratory(fileId.toString());
        }
        break;
      default:
    }
  }

  @override
  String toString() {
    return 'State:\n state: ${Util.toShortString(state)}, chosenFile: $chosenFile, hasFile: $hasFile, hasDiagFile: $hasSample, hasMolecules: $hasMolecules';
  }
}

/// The GAME
class Game {
  /// List of scientific projects
  static List<Project> projects = [];

  /// List of files
  static List<File> files = [];

  /// The players
  static Player player0;
  static Player player1;

  /// Available molecules for each molecule type
  static int availableA;
  static int availableB;
  static int availableC;
  static int availableD;
  static int availableE;

  /// Get the number of scientific projects
  int get projectCount => projects.length;

  /// Get the number of files
  int get filesCount => files.length;

  /// Update the carried files for all players
  static updateCariedFilesForAllPlayers() {
    player0.robot.files = _getPlayerCarriedFiles(0);
    player1.robot.files = _getPlayerCarriedFiles(1);
  }

  /// Get the files carried by [playerId]
  static List<File> _getPlayerCarriedFiles(playerId) {
    if (files.isEmpty) {
      return [];
    }
    var _files = [...files];
    _files.retainWhere((element) => element.carriedBy == playerId);
    return _files;
  }

  static void show() {
    String s = 'GAME:' '\n ';

    var props = [
      'availables: A:$availableA B:$availableB C:$availableC D:$availableD E:$availableE',
      'projects: \n[\n  ${projects.join('\n  ')}\n]',
      'files: \n${files.join('\n')}',
      'player0:$player0',
      'player1:$player1',
    ].join('\n ');
    s += props;
    debug(s);
  }
}

/**
 * Bring data on patient samples from the diagnosis machine to the laboratory with enough molecules to produce medicine!
 **/
void main() {
  List inputs;
  int projectCount = int.parse(stdin.readLineSync());
  // PROVIDE PROJECTS
  for (int i = 0; i < projectCount; i++) {
    inputs = stdin.readLineSync().split(' ');
    int a = int.parse(inputs[0]);
    int b = int.parse(inputs[1]);
    int c = int.parse(inputs[2]);
    int d = int.parse(inputs[3]);
    int e = int.parse(inputs[4]);

    Game.projects.add(Project(a, b, c, d, e));
  }

  State state = State();

  bool isFirstTurn = true;

  // GAME LOOP
  while (true) {
    /// PROVIDE PLAYERS, ROBOTS
    for (int i = 0; i < 2; i++) {
      inputs = stdin.readLineSync().split(' ');
      String target = inputs[0];
      int eta = int.parse(inputs[1]);
      int score = int.parse(inputs[2]);
      int storageA = int.parse(inputs[3]);
      int storageB = int.parse(inputs[4]);
      int storageC = int.parse(inputs[5]);
      int storageD = int.parse(inputs[6]);
      int storageE = int.parse(inputs[7]);
      int expertiseA = int.parse(inputs[8]);
      int expertiseB = int.parse(inputs[9]);
      int expertiseC = int.parse(inputs[10]);
      int expertiseD = int.parse(inputs[11]);
      int expertiseE = int.parse(inputs[12]);

      var robot = Robot(
        target: isFirstTurn ? ModuleType.CENTER : Util.toModuleType(target),
        eta: eta,
        storageA: storageA,
        storageB: storageB,
        storageC: storageC,
        storageD: storageD,
        storageE: storageE,
      );

      var player = Player(
        id: i,
        robot: robot,
        score: score,
        expertiseA: expertiseA,
        expertiseB: expertiseB,
        expertiseC: expertiseC,
        expertiseD: expertiseD,
        expertiseE: expertiseE,
      );

      if (i == 0) {
        Game.player0 = player;
      } else if (i == 1) {
        Game.player1 = player;
      }
    }

    isFirstTurn ? isFirstTurn = false : '';

    inputs = stdin.readLineSync().split(' ');
    int availableA = int.parse(inputs[0]);
    int availableB = int.parse(inputs[1]);
    int availableC = int.parse(inputs[2]);
    int availableD = int.parse(inputs[3]);
    int availableE = int.parse(inputs[4]);

    Game.availableA = availableA;
    Game.availableB = availableB;
    Game.availableC = availableC;
    Game.availableD = availableD;
    Game.availableE = availableE;

    int sampleCount = int.parse(stdin.readLineSync());

    /// PROVIDE FILES
    for (int i = 0; i < sampleCount; i++) {
      inputs = stdin.readLineSync().split(' ');
      int sampleId = int.parse(inputs[0]);
      int carriedBy = int.parse(inputs[1]);
      int rank = int.parse(inputs[2]);
      String expertiseGain = inputs[3];
      int health = int.parse(inputs[4]);
      int costA = int.parse(inputs[5]);
      int costB = int.parse(inputs[6]);
      int costC = int.parse(inputs[7]);
      int costD = int.parse(inputs[8]);
      int costE = int.parse(inputs[9]);

      var file = File(
        id: sampleId,
        carriedBy: carriedBy,
        health: health,
        gain: expertiseGain,
        rank: rank,
        costA: costA,
        costB: costB,
        costC: costC,
        costD: costD,
        costE: costE,
      );

      Game.files.add(file);
    }

    Game.updateCariedFilesForAllPlayers();

    /**
     * GAME LOGIC
     */

    Game.show();

    state.evalState();

    //debug(state);

    state.actions();
  }
}
