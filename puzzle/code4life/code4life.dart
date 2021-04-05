import 'dart:io';

enum MoleculeType { A, B, C, D, E }

enum ModuleType { DIAGNOSIS, MOLECULES, LABORATORY, SAMPLES }

enum StateType { CHOOSE, ANALYSE, COLLECT, PRODUCE }

toShortString(dynamic T) {
  return T.toString().split('.').last;
}

ModuleType toModuleType(String s) {
  if (s == toShortString(ModuleType.DIAGNOSIS)) {
    return ModuleType.DIAGNOSIS;
  }
  if (s == toShortString(ModuleType.LABORATORY)) {
    return ModuleType.LABORATORY;
  }
  if (s == toShortString(ModuleType.MOLECULES)) {
    return ModuleType.MOLECULES;
  }
  return ModuleType.SAMPLES;
}

void debug(e) => stderr.writeln(e);

class Util {
  static File chooseFile(List<File> files) {
    var _files = [...files];

    // Retains only files in the cloud
    _files.retainWhere((element) => element.carriedBy == 0);
    // Sort files by gain
    _files.sort((f1, f2) => f1.gain.compareTo(f2.gain));
    // Choose the file with the maximal gain

    return _files.last;
  }

  static List<File> playerCarriedFiles(List<File> files, [int playerId = 0]) {
    var _files = [...files];
    _files.retainWhere((element) => element.carriedBy == playerId);
    return _files;
  }
}

class State {
  State();

  Robot robot;
  List<File> files;

  StateType _state;
  File _chosenFile;
  bool hasSample = false;

  bool get hasFile => _chosenFile != null;
  bool get hasMolecules =>
      robot.hasDiagFile ? robot.canProduce(robot.getDiagFiles().first) : false;
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
        if (ModuleType.SAMPLES != robot.target) {
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
        if (ModuleType.DIAGNOSIS != robot.target) {
          Commands.goTo(ModuleType.DIAGNOSIS);
        }
        // Else choose a file
        else {
          _chosenFile = robot.getNonDiagFiles().first;
          Commands.connectDiagnosis(_chosenFile.id.toString());
        }
        break;
      case StateType.COLLECT:
        // If Robot is not in MOLECULES Module, go there
        if (ModuleType.MOLECULES != robot.target) {
          Commands.goTo(ModuleType.MOLECULES);
        }
        // Else collect molecules
        else {
          var moleculeType =
              robot.whichMoleculeToCollect(robot.getDiagFiles().first);
          Commands.connectMolecules(moleculeType);
        }
        break;
      case StateType.PRODUCE:
        // If Robot is not in LABORATORY Module, go there
        if (ModuleType.LABORATORY != robot.target) {
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
    return 'State:\n state: ${toShortString(state)}, chosenFile: $chosenFile, hasFile: $hasFile, hasDiagFile: $hasSample, hasMolecules: $hasMolecules';
  }
}

class Player {
  Player({this.id, this.score, this.robot});
  int id;
  int score;
  Robot robot;

  @override
  String toString() {
    return 'Player $id\n score: $score,\n robot: $robot';
  }
}

class Robot {
  static const int maxFile = 3;
  static const int maxMolecules = 10;

  Robot(
      {this.target,
      this.carriedFiles,
      this.storageA,
      this.storageB,
      this.storageC,
      this.storageD,
      this.storageE});

  ModuleType target;
  List<File> carriedFiles;

  int storageA;
  int storageB;
  int storageC;
  int storageD;
  int storageE;

  bool get hasCarriedFile => carriedFiles.isNotEmpty;

  bool get hasDiagFile {
    var file = carriedFiles.firstWhere((file) => file.health != -1,
        orElse: () => null);

    if (file != null) {
      return true;
    }
    return false;
  }

  List<File> getDiagFiles() =>
      carriedFiles.where((file) => file.health != -1).toList();

  List<File> getNonDiagFiles() =>
      carriedFiles.where((file) => file.health == -1).toList();

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
    return 'Robot\n target: ${toShortString(target)}, storageA: $storageA, storageB: $storageB, storageC: $storageC, storageD: $storageD, storageE: $storageE';
  }
}

class File {
  static int count;

  File({
    this.id,
    this.carriedBy,
    this.health,
    this.costA,
    this.costB,
    this.costC,
    this.costD,
    this.costE,
    this.rank,
  });

  int id;
  int carriedBy;
  int health;
  int rank;

  int costA;
  int costB;
  int costC;
  int costD;
  int costE;

  int get totalCost => costA + costB + costC + costD + costE;

  double get gain => health / totalCost;

  @override
  String toString() {
    return 'File\n id: $id, carriedBy: $carriedBy, health: $health, rank: $rank, costA: $costA, costB: $costB, costC: $costC, costD: $costD, costE: $costE,';
  }
}

class Commands {
  static void goTo(ModuleType moduleType) {
    String moduleName = toShortString(moduleType);
    print('GOTO $moduleName');
  }

  static void _connect(String e) {
    print('CONNECT $e');
  }

  static void connectDiagnosis(String fileId) {
    _connect(fileId);
  }

  static void connectLaboratory(String fileId) {
    _connect(fileId);
  }

  static void connectSamples(int rank) {
    _connect(rank.toString());
  }

  static void connectMolecules(MoleculeType moleculeType) {
    String moleculeName = toShortString(moleculeType);
    _connect(moleculeName);
  }
}

/**
 * Bring data on patient samples from the diagnosis machine to the laboratory with enough molecules to produce medicine!
 **/
void main() {
  List inputs;
  int projectCount = int.parse(stdin.readLineSync());
  for (int i = 0; i < projectCount; i++) {
    inputs = stdin.readLineSync().split(' ');
    int a = int.parse(inputs[0]);
    int b = int.parse(inputs[1]);
    int c = int.parse(inputs[2]);
    int d = int.parse(inputs[3]);
    int e = int.parse(inputs[4]);
  }

  State state = State();

  bool isFirstTurn = true;

  // game loop
  while (true) {
    List<Player> players = [];
    List<File> files = [];

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
          target: isFirstTurn ? null : toModuleType(target),
          storageA: storageA,
          storageB: storageB,
          storageC: storageC,
          storageD: storageD,
          storageE: storageE);
      isFirstTurn = false;

      var player = Player(id: i, robot: robot, score: score);

      debug(player);

      players.add(player);
    }
    inputs = stdin.readLineSync().split(' ');
    int availableA = int.parse(inputs[0]);
    int availableB = int.parse(inputs[1]);
    int availableC = int.parse(inputs[2]);
    int availableD = int.parse(inputs[3]);
    int availableE = int.parse(inputs[4]);
    int sampleCount = int.parse(stdin.readLineSync());

    File.count = sampleCount;

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
        costA: costA,
        costB: costB,
        costC: costC,
        costD: costD,
        costE: costE,
      );

      debug(file);
      files.add(file);
    }
    players[0].robot.carriedFiles = Util.playerCarriedFiles(files);
    state.robot = players.first.robot;
    state.files = files;

    state.evalState();

    debug(state);

    state.actions();
  }
}
