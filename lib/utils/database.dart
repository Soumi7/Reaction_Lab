import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reaction_lab/res/strings.dart';
import 'dart:math';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _usersCollection = _firestore.collection('users');
final CollectionReference _problemsCollection =
    _firestore.collection('problems');
final CollectionReference _roomsCollection = _firestore.collection('rooms');

class Database {
  static late User user;

  static List<String> _levels = [
    'easy',
    'medium',
    'hard',
  ];

  // TODO: Add more problems here
  static Map<String, List<Set<dynamic>>> _problemMap = {
    'easy': [
      {
        '#Fe + #Cl2 -> #FeCl3', // formula
        [2, 3, 2], // correct options
        [2, 5, 4, 3, 6, 2, 1], // options to choose from
        '2Fe + 3Cl2 -> 2FeCl3', // solved formula
      },
      {
        '#Fe + #O2 -> #Fe2O3',
        [4, 3, 2],
        [1, 2, 4, 4, 6, 1, 3],
        '4Fe + 3O2 -> 2Fe2O3',
      },
      {
        '#Al + #O2 -> #Al2O3',
        [4, 3, 2],
        [3, 5, 4, 3, 6, 2, 5],
        '4Al + 3O2 -> 2Al2O3',
      },
      {
        '#N2 + #H2 -> #NH3',
        [1, 3, 2],
        [5, 3, 2, 1, 4, 2, 9],
        '1N2 + 3H2 -> 2NH3',
      },
      {
        '#AgI +  #Na2S -> #Ag2S + #NaI',
        [2, 1, 1, 2],
        [3, 2, 5, 2, 1, 3, 1],
        '2AgI +  1Na2S -> 1Ag2S + 2NaI',
      },
      {
        '#NaBr +  #Cl2 -> #NaCl + #Br2',
        [2, 1, 2, 1],
        [2, 4, 2, 1, 3, 1, 2],
        '2NaBr +  1Cl2 -> 2NaCl + 1Br2',
      },
      {
        '#TiCl4 + #H2O -> #TiO2 + #HCL',
        [1, 2, 1, 4],
        [2, 3, 1, 1, 2, 5, 4],
        '1TiCl4 + 2H2O -> 1TiO2 + 4HCL',
      },
      {
        '#FeS + #O2 -> #Fe2O3 + #SO2',
        [4, 7, 2, 4],
        [3, 4, 2, 7, 1, 2, 4],
        '4FeS + 7O2 -> 2Fe2O3 + 4SO2',
      },
      {
        '#PCl5 + #H2O -> #H3PO4 + #HCl',
        [1, 4, 1, 5],
        [3, 4, 2, 5, 1, 1, 4],
        '1PCl5 + 4H2O -> 1H3PO4 + 5HCl',
      },
      {
        '#SiO2 + #HF -> #SiF4 + #H2O',
        [1, 4, 1, 2],
        [3, 4, 2, 5, 1, 1, 4],
        '1SiO2 + 4HF -> 1SiF4 + 2H2O',
      },
      {
        '#N2 + #O2 + #H2O -> #HNO3 ',
        [2, 5, 2, 4],
        [3, 4, 2, 5, 1, 2, 4],
        '2N2 + 5O2 + 2H2O -> 4HNO3',
      },
      {
        '#FeS + #O2 -> #Fe2O3 + #SO2',
        [4, 7, 2, 4],
        [1, 4, 2, 6, 7, 2, 4],
        '4FeS + 7O2 -> 2Fe2O3 + 4SO2',
      },
      {
        '#C3H8 + #O2 -> #CO2 + #H2O',
        [1, 5, 3, 4],
        [2, 4, 5, 3, 1, 6, 1],
        '1C3H8 + 5O2 -> 3CO2 + 4H2O',
      },
    ],
  };

  static uploadUserData({required String userName}) async {
    DocumentReference documentReferencer = _usersCollection.doc(user.uid);

    Map<String, dynamic> userData = <String, dynamic>{
      "uid": user.uid,
      "imageUrl": user.photoURL,
      "userName": userName,
      "email": user.email,
      "token": 0,
      "solved": 0,
      "accuracy": 0.0,
    };
    print('USER DATA:\n$userData');

    await documentReferencer.set(userData).whenComplete(() {
      print('User data stored successfully!');
    }).catchError((e) => print(e));
  }

  static Future<void> uploadProblemData() async {
    _problemMap.forEach((level, levelDataList) {
      int index = -1;

      levelDataList.forEach((data) async {
        index++;
        DocumentReference problemReference = _problemsCollection
            .doc(level)
            .collection('statements')
            .doc('$index');

        Map<String, dynamic> problemInfo = {
          'formula': data.elementAt(0),
          'correct_options': data.elementAt(1),
          'options': data.elementAt(2),
          'solvedFormula': data.elementAt(3),
        };

        await problemReference.set(problemInfo).whenComplete(() {
          print('Data added -> $level - $index');
        }).catchError((_) => print('Failed to added -> $level - $index'));
      });
    });
  }

  static Future<Map<String, dynamic>> retrieveUserData() async {
    DocumentReference documentReferencer = _usersCollection.doc(user.uid);
    DocumentSnapshot userSnapshot = await documentReferencer.get();

    return userSnapshot.data()!;
  }

  static scanForAvialablePlayers({required Difficulty difficulty}) {
    String difficultyLevel = difficulty.parseToString();
  }

  static Future<String?> createNewRoom(
      {required Difficulty difficulty, required String userName}) async {
    String? roomId;
    DocumentReference documentReference = _roomsCollection
        .doc(difficulty.parseToString())
        .collection('breakouts')
        .doc();

    int currentDateTimeEpoch = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> roomInfo = {
      'id': documentReference.id,
      'epoch': currentDateTimeEpoch,
      'type': '2 players',
      'difficulty': difficulty.parseToString(),
      'canGenerateNextQ': false,
      'uid1': user.uid,
      'username1': userName,
      'score1': 0,
      'isSolved1': false,
      'isAvailable': true,
      'done': false,
    };

    await documentReference.set(roomInfo).whenComplete(() {
      print('Created a new room, ID: ${documentReference.id}');
      roomId = documentReference.id;
    }).catchError((e) => print(e));

    return roomId;
  }

  static Stream<QuerySnapshot> retrieveRoomData({
    required Difficulty difficulty,
  }) {
    Stream<QuerySnapshot> roomsQuery = _roomsCollection
        .doc(difficulty.parseToString())
        .collection('breakouts')
        .where('isAvailable', isEqualTo: true)
        .snapshots();

    return roomsQuery;
  }

  static Stream<DocumentSnapshot> retrieveSingleRoomData({
    required Difficulty difficulty,
    required String roomId,
  }) {
    Stream<DocumentSnapshot> singleRoomSnapshot = _roomsCollection
        .doc(difficulty.parseToString())
        .collection('breakouts')
        .doc(roomId)
        .snapshots();

    return singleRoomSnapshot;
  }

  static joinRoom({
    required Difficulty difficulty,
    required String roomDocumentId,
    required String userName,
  }) {
    DocumentReference documentReference = _roomsCollection
        .doc(difficulty.parseToString())
        .collection('breakouts')
        .doc(roomDocumentId);

    Map<String, dynamic> secondUserInfo = {
      'canGenerateNextQ': true,
      'uid2': user.uid,
      'username2': userName,
      'score2': 0,
      'isSolved2': false,
      'isAvailable': false,
      'roundNumber': 0,
    };

    documentReference.update(secondUserInfo).whenComplete(() {
      print('Room joining successful, ID: ${documentReference.id}');
    }).catchError((e) => print(e));
  }

  // update isSolves to false
  static generateProblem({
    // required String uid1,
    // required String uid2,
    required Difficulty difficulty,
    required String roomDocumentId,
    // required String questionIndex,
  }) async {
    DocumentSnapshot roomSnapshot = await _roomsCollection
        .doc(difficulty.parseToString())
        .collection('breakouts')
        .doc(roomDocumentId)
        .get();

    Map<String, dynamic> roomData = roomSnapshot.data()!;

    bool canGenerateNextQ = roomData['canGenerateNextQ'];
    String roomCreatorUid = roomData['uid1'];
    int roundNumber = roomData['roundNumber'];

    if (roundNumber < 3) {
      if (canGenerateNextQ && roomCreatorUid == user.uid) {
        QuerySnapshot statementsSnapshot = await _problemsCollection
            .doc(difficulty.parseToString())
            .collection('statements')
            .get();

        int totalNumberOfProblems = statementsSnapshot.docs.length;

        Random random = Random();
        int randomNumber = random.nextInt(totalNumberOfProblems);

        DocumentReference roomReference = _roomsCollection
            .doc(difficulty.parseToString())
            .collection('breakouts')
            .doc(roomDocumentId);

        Map<String, dynamic> questionNumberData = {
          'question_number': randomNumber,
          'roundNumber': FieldValue.increment(1),
          'canGenerateNextQ': false,
          'isSolved1': false,
          'isSolved2': false,
        };

        await roomReference.update(questionNumberData).whenComplete(() {
          print('Updated question number to: $randomNumber');
        }).catchError((e) => print(e));
      }
    } else {
      DocumentReference roomReference = _roomsCollection
          .doc(difficulty.parseToString())
          .collection('breakouts')
          .doc(roomDocumentId);

      Map<String, dynamic> questionNumberData = {
        'done': true,
      };

      await roomReference.update(questionNumberData).whenComplete(() {
        print('Game complete!');
      }).catchError((e) => print(e));
    }
  }

  static Future<Map<String, dynamic>> retrieveProblem({
    required Difficulty difficulty,
    required String roomDocumentId,
  }) async {
    DocumentSnapshot roomSnapshot = await _roomsCollection
        .doc(difficulty.parseToString())
        .collection('breakouts')
        .doc(roomDocumentId)
        .get();

    int? questionNumber = roomSnapshot.data()!['question_number'];

    DocumentSnapshot statementSnapshot = await _problemsCollection
        .doc(difficulty.parseToString())
        .collection('statements')
        .doc('${questionNumber ?? 0}')
        .get();

    Map<String, dynamic> statementData = statementSnapshot.data()!;

    // String formula = statementData['formula'];
    // List<int> correctOptions = statementData['correct_options'];
    // List<int> options = statementData['options'];

    return statementData;
  }

  static Future<Map<String, dynamic>> retrieveNextProblem({
    required Difficulty difficulty,
    required String roomDocumentId,
    required String questionNumber,
  }) async {
    DocumentSnapshot statementSnapshot = await _problemsCollection
        .doc(difficulty.parseToString())
        .collection('statements')
        .doc('$questionNumber')
        .get();

    Map<String, dynamic> statementData = statementSnapshot.data()!;

    return statementData;
  }

  // set score, update isSolved to true
  static Future<void> uploadScore({
    required int score,
    required Difficulty difficulty,
    required String roomDocumentId,
  }) async {
    DocumentReference roomReference = _roomsCollection
        .doc(difficulty.parseToString())
        .collection('breakouts')
        .doc(roomDocumentId);

    DocumentSnapshot roomSnapshot = await _roomsCollection
        .doc(difficulty.parseToString())
        .collection('breakouts')
        .doc(roomDocumentId)
        .get();

    Map<String, dynamic> roomData = roomSnapshot.data()!;
    String uid1 = roomData['uid1'];
    String uid2 = roomData['uid2'];

    Map<String, dynamic> solvedData;

    print('current uid: ${user.uid}, uid1: $uid1, uid2: $uid2');

    if (uid1 == user.uid) {
      solvedData = {
        // 'question_number': null,
        'isSolved1': true,
        'canGenerateNextQ': true,
        'score1': score,
      };
    } else {
      solvedData = {
        // 'question_number': null,
        'isSolved2': true,
        'canGenerateNextQ': true,
        'score2': score,
      };
    }

    await roomReference.update(solvedData).whenComplete(() {
      print('Uploaded solved data!');
    }).catchError((e) => print(e));
  }

  static checkIfAccountExists() {}

  static updateUserScore({required int token}) async {
    DocumentReference documentReferencer = _usersCollection.doc(user.uid);

    int solved = token > 0 ? token ~/ 10 : 0;

    Map<String, dynamic> userData = <String, dynamic>{
      "token": token,
      "solved": solved,
      "accuracy": double.parse(((solved / 3) * 100).toStringAsFixed(2)),
    };
    print('USER DATA:\n$userData');

    await documentReferencer.update(userData).whenComplete(() {
      print('User data score updated successfully!');
    }).catchError((e) => print(e));
  }
}

/// The person who creates the room, manages the random number generation,
/// and new question selection, checks for if a question is solved
/// and move on to the next.
