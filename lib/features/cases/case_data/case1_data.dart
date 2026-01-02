import 'package:flutter/material.dart';
import 'package:case_zero_detective/core/models/story_model.dart';
import 'package:case_zero_detective/core/constants/app_images.dart';

class Case1Data {
static final StoryCaseData vanishedNecklace = StoryCaseData(
caseNumber: 1,
id: 'vanished_necklace',
title: 'The Vanished Necklace',
difficulty: 'Medium',
thumbnail: AppImages.case1Thumbnail,
description: 'A priceless necklace disappears during a high-society ball.',
startSceneId: 'scene1',
scenes: {
'scene1': StoryScene(
id: 'scene1',
backgroundImage: AppImages.case1MansionScene,
dialogue: 'VICTORIA MONTGOMERY: "My diamond necklace has been stolen! It was worth millions! Please, you must find it before word gets out."',
characters: [
StoryCharacter(
id: 'victoria',
name: 'Victoria Montgomery',
imagePath: AppImages.victoria,
position: Alignment.centerRight,
isHighlighted: true,
emotion: 'Distraught',
),
],
choices: [
DialogueChoice(text: 'INVESTIGATE THE BALLROOM', nextSceneId: 'scene2'),
],
),
'scene2': StoryScene(
id: 'scene2',
backgroundImage: AppImages.case1Ballroom,
dialogue: 'The ballroom is grand but empty now. Glasses are left on tables, some broken. A torn piece of fabric lies near the window.',
characters: [],
choices: [
DialogueChoice(text: 'EXAMINE THE TORN FABRIC', nextSceneId: 'scene3'),
DialogueChoice(text: 'QUESTION THE BUTLER', nextSceneId: 'scene4'),
],
),
'scene3': StoryScene(
id: 'scene3',
backgroundImage: AppImages.case1Ballroom,
dialogue: 'The fabric matches the butler\'s uniform. It\'s caught on the window latch. Someone climbed out this way.',
characters: [],
choices: [
DialogueChoice(
text: 'SEARCH THE GARDEN',
nextSceneId: 'scene5',
cluesToAdd: ['torn_fabric'],
),
],
cluesFound: ['torn_fabric'],
),
'scene4': StoryScene(
id: 'scene4',
backgroundImage: AppImages.case1Study,
dialogue: 'HENRY BUTLER: "I saw nothing! I was in the kitchen... But I did hear arguing earlier between Victoria and her sister Chloe."',
characters: [
StoryCharacter(
id: 'henry',
name: 'Henry Butler',
imagePath: AppImages.henryButler,
position: Alignment.centerRight,
isHighlighted: true,
emotion: 'Nervous',
),
],
choices: [
DialogueChoice(text: 'FIND CHLOE', nextSceneId: 'scene6'),
],
),
'scene5': StoryScene(
id: 'scene5',
backgroundImage: AppImages.case1Garden,
dialogue: 'In the garden, you find footprints leading to a hidden door. A note is wedged in the door: "Midnight. Bring it." Signed with a "J".',
characters: [],
choices: [
DialogueChoice(
text: 'FOLLOW THE FOOTPRINTS',
nextSceneId: 'scene7',
cluesToAdd: ['garden_note'],
),
],
cluesFound: ['garden_note'],
),
'scene6': StoryScene(
id: 'scene6',
backgroundImage: AppImages.case1Garden,
dialogue: 'CHLOE MONTGOMERY: "Victoria always flaunts that necklace. She deserves to lose it! But I didn\'t take it... ask James, he was acting strange."',
characters: [
StoryCharacter(
id: 'chloe',
name: 'Chloe Montgomery',
imagePath: AppImages.chloe,
position: Alignment.centerRight,
isHighlighted: true,
emotion: 'Bitter',
),
],
choices: [
DialogueChoice(text: 'LOCATE JAMES', nextSceneId: 'scene8'),
],
),
'scene7': StoryScene(
id: 'scene7',
backgroundImage: AppImages.case1Study,
dialogue: 'The footprints lead to a locked study. You find a safe and a notebook with alibis. Let\'s check their stories.',
characters: [],
choices: [
DialogueChoice(
text: 'MATCH ALIBIS TO SUSPECTS',
nextSceneId: 'scene_memory_game',
triggersGame: true,
gameId: 'memory_game',
),
],
),
'scene8': StoryScene(
id: 'scene8',
backgroundImage: AppImages.case1Hallway,
dialogue: 'JAMES MONTGOMERY: "I have gambling debts... I needed money. But I couldn\'t go through with it. Someone else took the necklace first!"',
characters: [
StoryCharacter(
id: 'james',
name: 'James Montgomery',
imagePath: AppImages.james,
position: Alignment.centerRight,
isHighlighted: true,
emotion: 'Guilty',
),
],
choices: [
DialogueChoice(
text: 'CONFRONT ALL SUSPECTS',
nextSceneId: 'scene_final_accusation',
),
],
),
'scene_memory_game': StoryScene(
id: 'scene_memory_game',
backgroundImage: AppImages.case1Study,
dialogue: 'Good work! You found that Henry\'s alibi doesn\'t match. Now you find a safe with a note: "Safe code: Year our family business was founded. Check the plaque."',
characters: [],
choices: [
DialogueChoice(
text: 'CRACK THE SAFE CODE',
nextSceneId: 'scene_safe_game',
triggersGame: true,
gameId: 'safe_game',
),
],
),
'scene_safe_game': StoryScene(
id: 'scene_safe_game',
backgroundImage: AppImages.case1Study,
dialogue: 'The safe opens! Inside, you find bank statements showing huge withdrawals... and a letter: "I know your secret. -H". The necklace is gone.',
characters: [],
choices: [
DialogueChoice(
text: 'CONFRONT ALL SUSPECTS',
nextSceneId: 'scene_final_accusation',
cluesToAdd: ['safe_contents'],
),
],
cluesFound: ['safe_contents'],
),
'scene_final_accusation': StoryScene(
id: 'scene_final_accusation',
backgroundImage: AppImages.case1Ballroom,
dialogue: 'All suspects are gathered. Who stole the necklace?\n\nVICTORIA: "It\'s priceless to me!"\nHENRY: "I\'ve served this family for 30 years!"\nCHLOE: "I hated it but didn\'t steal it!"\nJAMES: "I wanted to but someone beat me to it!"',
characters: [],
choices: [
DialogueChoice(
text: 'MAKE YOUR ACCUSATION',
nextSceneId: 'scene_accuse',
triggersGame: true,
gameId: 'suspect_selection_case1',
),
],
),
'scene_accuse': StoryScene(
id: 'scene_accuse',
backgroundImage: AppImages.case1Ballroom,
dialogue: 'Placeholder for suspect selection result',
characters: [],
choices: [
DialogueChoice(
text: 'CONTINUE',
nextSceneId: 'end',
),
],
),
'scene_correct_accusation': StoryScene(
id: 'scene_correct_accusation',
backgroundImage: AppImages.case1Ballroom,
dialogue: 'DETECTIVE: "Henry Butler! You stole the necklace to pay for your wife\'s medical bills. The torn fabric, the safe knowledge - it all points to you!"\n\nHENRY: "You\'re right... I needed the money desperately. Forgive me, Victoria."\n\nVICTORIA: "Henry... why didn\'t you just ask? The necklace is returned. Case closed."',
characters: [
StoryCharacter(
id: 'henry',
name: 'Henry Butler',
imagePath: AppImages.henryButler,
position: Alignment.centerRight,
isHighlighted: true,
emotion: 'Ashamed',
),
],
choices: [
DialogueChoice(
text: 'CASE SOLVED! RETURN TO DASHBOARD',
nextSceneId: 'end',
),
],
),
'scene_wrong_accusation': StoryScene(
id: 'scene_wrong_accusation',
backgroundImage: AppImages.case1Ballroom,
dialogue: 'WRONG ACCUSATION! The real thief escapes and sells the necklace. The case remains unsolved.',
characters: [],
choices: [
DialogueChoice(
text: 'TRY AGAIN',
nextSceneId: 'scene_final_accusation',
),
],
),
},
miniGames: {
'memory_game': MiniGame.memoryMatch(
id: 'memory_game',
pairs: [
{'suspect': 'Victoria Montgomery', 'alibi': 'Hosting guests all night'},
{'suspect': 'Henry Butler', 'alibi': 'Checking wine cellar'},
{'suspect': 'Chloe Montgomery', 'alibi': 'Arguing with Victoria'},
{'suspect': 'James Montgomery', 'alibi': 'In garden smoking'},
],
timeLimit: 90,
),

// FIXED: Remove config parameter since MiniGame.safeCrack doesn't support it
'safe_game': MiniGame.safeCrack(
id: 'safe_game',
correctCode: '1980', // Montgomery family business founding year
hints: [
'The Montgomery family business was founded in 1980',
'Check the plaque in the study hallway',
'A year that ends with 0'
],
timeLimit: 120,
),

'suspect_selection_case1': MiniGame.suspectSelection(
id: 'suspect_selection_case1',
suspects: ['Victoria Montgomery', 'Henry Butler', 'Chloe Montgomery', 'James Montgomery'],
correctSuspect: 'Henry Butler',
onSuccessNextSceneId: 'scene_correct_accusation',
onFailureNextSceneId: 'scene_wrong_accusation',
hints: ['Who had access to everything?', 'Check the torn fabric clue'],
),
},
clues: {
'torn_fabric': Clue.fromScene(
id: 'torn_fabric',
name: 'Torn Butler Uniform Fabric',
description: 'Blue fabric matching the butler\'s uniform, caught on window.',
foundInScene: 'scene3',
type: ClueType.EVIDENCE,
relatedSuspectId: 'henry_butler',
),
'garden_note': Clue.fromScene(
id: 'garden_note',
name: 'Mysterious Note',
description: 'Note saying "Midnight. Bring it." Signed with "J".',
foundInScene: 'scene5',
type: ClueType.DOCUMENT,
relatedSuspectId: 'james',
),
'safe_contents': Clue.fromScene(
id: 'safe_contents',
name: 'Safe Contents',
description: 'Bank statements and threatening letter signed "H".',
foundInScene: 'scene_safe_game',
isImportant: true,
type: ClueType.DOCUMENT,
),
},
suspects: {
'victoria': Suspect(
id: 'victoria',
name: 'Victoria Montgomery',
description: 'Wealthy socialite and owner of the necklace.',
motive: 'Insurance fraud? Wanted attention?',
imagePath: AppImages.victoria,
isGuilty: false,
occupation: 'Socialite',
age: 45,
relationshipToVictim: 'Owner',
),
'henry_butler': Suspect(
id: 'henry_butler',
name: 'Henry Butler',
description: 'Family butler for 30 years.',
motive: 'Desperate for money for wife\'s medical bills.',
imagePath: AppImages.henryButler,
isGuilty: true,
occupation: 'Butler',
age: 58,
relationshipToVictim: 'Employee',
),
'chloe': Suspect(
id: 'chloe',
name: 'Chloe Montgomery',
description: 'Victoria\'s jealous younger sister.',
motive: 'Jealousy and resentment.',
imagePath: AppImages.chloe,
isGuilty: false,
occupation: 'Socialite',
age: 38,
relationshipToVictim: 'Sister',
),
'james': Suspect(
id: 'james',
name: 'James Montgomery',
description: 'Victoria\'s brother with gambling debts.',
motive: 'Desperate for money to pay debts.',
imagePath: AppImages.james,
isGuilty: false,
occupation: 'Businessman',
age: 42,
relationshipToVictim: 'Brother',
),
},
);
}
