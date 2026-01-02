import 'package:flutter/material.dart';

enum GameType {
CRACK_CODE,
EVIDENCE_MATCH,
SUSPECT_SELECTION,
HIDDEN_OBJECT,
PASSWORD
}

// --- StoryModel and StoryDialogue ---
class StoryDialogue {
final String speaker;
final String text;
final String? characterImage;
final String? audioFile;
final Duration? delay;

const StoryDialogue({
required this.speaker,
required this.text,
this.characterImage,
this.audioFile,
this.delay,
});
}

class StoryModel {
final String id;
final String title;
final String description;
final String backgroundImage;
final List<StoryDialogue> dialogues;
final bool isCompleted;

const StoryModel({
required this.id,
required this.title,
required this.description,
required this.backgroundImage,
required this.dialogues,
this.isCompleted = false,
});
}
// --- End of StoryModel and StoryDialogue ---

// --- Story Character ---
class StoryCharacter {
final String id;
final String name;
final String imagePath;
final Alignment position;
final bool isHighlighted;
final String? emotion;
final double scale;

const StoryCharacter({
required this.id,
required this.name,
required this.imagePath,
this.position = Alignment.center,
this.isHighlighted = false,
this.emotion,
this.scale = 1.0,
});
}

// --- Dialogue Choice ---
class DialogueChoice {
final String id;
final String text;
final String nextSceneId;
final List<String> cluesToAdd;
final bool triggersGame;
final String? gameId;
final bool requiresClue;
final String? requiredClueId;
final IconData? icon;

DialogueChoice({
required this.text,
required this.nextSceneId,
String id = '',
this.cluesToAdd = const [],
this.triggersGame = false,
this.gameId,
this.requiresClue = false,
this.requiredClueId,
this.icon,
}) : id = id.isEmpty ? 'choice_${text.hashCode}' : id;
}

// --- Story Scene ---
class StoryScene {
final String id;
final String backgroundImage;
final String dialogue;
final List<StoryCharacter> characters;
final List<DialogueChoice> choices;
final List<String> cluesFound;

const StoryScene({
required this.id,
required this.backgroundImage,
required this.dialogue,
this.characters = const [],
this.choices = const [],
this.cluesFound = const [],
});
}

// --- Mini Game ---
class MiniGame {
final String id;
final String title;
final String description;
final GameType type;
final Map<String, dynamic> config;
final int timeLimit;

const MiniGame({
required this.id,
required this.title,
required this.description,
required this.type,
required this.config,
this.timeLimit = 0,
});

factory MiniGame.safeCrack({
required String id,
required String correctCode,
required List<String> hints,
int timeLimit = 0,
}) => MiniGame(
id: id,
title: 'Safe Crack',
description: 'Unlock the safe',
type: GameType.CRACK_CODE,
timeLimit: timeLimit,
config: {'correctCode': correctCode, 'hints': hints},
);

factory MiniGame.memoryMatch({
required String id,
required List<Map<String, String>> pairs,
int timeLimit = 0,
}) => MiniGame(
id: id,
title: 'Memory Match',
description: 'Match suspects to alibis',
type: GameType.EVIDENCE_MATCH,
timeLimit: timeLimit,
config: {'pairs': pairs},
);

factory MiniGame.suspectSelection({
required String id,
required List<String> suspects,
required String correctSuspect,
required String onSuccessNextSceneId,
required String onFailureNextSceneId,
List<String> hints = const [],
}) => MiniGame(
id: id,
title: 'Final Accusation',
description: 'Choose the killer',
type: GameType.SUSPECT_SELECTION,
config: {
'suspects': suspects,
'correctSuspect': correctSuspect,
'onSuccessNextSceneId': onSuccessNextSceneId,
'onFailureNextSceneId': onFailureNextSceneId,
'hints': hints,
},
);

factory MiniGame.hiddenObject({
required String id,
required String backgroundImage,
required List<HiddenObject> objects,
}) => MiniGame(
id: id,
title: 'Search the Scene',
description: 'Find the hidden objects',
type: GameType.HIDDEN_OBJECT,
config: {'backgroundImage': backgroundImage, 'objects': objects},
);

factory MiniGame.password({
required String id,
required String correctPassword,
required String hint,
required String onSuccessNextSceneId,
}) => MiniGame(
id: id,
title: 'Enter Password',
description: 'Crack the code to proceed',
type: GameType.PASSWORD,
config: {'correctPassword': correctPassword, 'hint': hint, 'onSuccessNextSceneId': onSuccessNextSceneId},
);
}

class HiddenObject {
final String id;
final Rect position;
final String imagePath;
final String onFoundNextSceneId;

const HiddenObject({
required this.id,
required this.position,
required this.imagePath,
required this.onFoundNextSceneId,
});
}

// --- Clue ---
enum ClueType { EVIDENCE, DOCUMENT, WEAPON, TESTIMONY, ALIBI, LOCATION, MOTIVE, OTHER }

class Clue {
final String id;
final String name;
final String description;
final String foundInScene;
final ClueType type;
final bool isImportant;
final String? relatedSuspectId;

Clue({
required this.id,
required this.name,
required this.description,
required this.foundInScene,
this.type = ClueType.EVIDENCE,
this.isImportant = false,
this.relatedSuspectId,
});

factory Clue.fromScene({
required String id,
required String name,
required String description,
required String foundInScene,
ClueType type = ClueType.EVIDENCE,
bool isImportant = false,
String? relatedSuspectId,
}) => Clue(
id: id,
name: name,
description: description,
foundInScene: foundInScene,
type: type,
isImportant: isImportant,
relatedSuspectId: relatedSuspectId,
);
}

// --- Suspect ---
class Suspect {
final String id;
final String name;
final String description;
final String motive;
final String imagePath;
final bool isGuilty;
final String? occupation;
final int age;
final String? relationshipToVictim;
final List<String> knownClues;

const Suspect({
required this.id,
required this.name,
required this.description,
required this.motive,
required this.imagePath,
required this.isGuilty,
this.occupation,
this.age = 30,
this.relationshipToVictim,
this.knownClues = const [],
});
}

// --- Case Data ---
class StoryCaseData {
final int caseNumber;
final String id;
final String title;
final String difficulty;
final String thumbnail;
final String description;
final String startSceneId;
final Map<String, StoryScene> scenes;
final Map<String, MiniGame> miniGames;
final Map<String, Clue> clues;
final Map<String, Suspect> suspects;

const StoryCaseData({
required this.caseNumber,
required this.id,
required this.title,
required this.difficulty,
required this.thumbnail,
required this.description,
required this.startSceneId,
required this.scenes,
required this.miniGames,
required this.clues,
required this.suspects,
});
}
