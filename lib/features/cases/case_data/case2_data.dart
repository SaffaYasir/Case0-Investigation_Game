import 'package:flutter/material.dart';
import 'package:case_zero_detective/core/models/story_model.dart';
import 'package:case_zero_detective/core/constants/app_images.dart';

class Case2Data {
static final StoryCaseData murderAlley = StoryCaseData(
caseNumber: 2,
id: 'murder_at_alley_17',
title: 'Murder at Alley 17',
difficulty: 'Medium',
thumbnail: AppImages.case2Cover,
description: 'A journalist is found dead. Investigate the city\'s corruption.',
startSceneId: 'scene_intro',
scenes: {
'scene_intro': StoryScene(
id: 'scene_intro',
backgroundImage: AppImages.case2Alley,
dialogue: 'POLICE CHIEF: "Journalist Emma Stone was found dead in Alley 17. This was no robbery - she was investigating city hall corruption. Watch your back detective."',
characters: [
StoryCharacter(
id: 'chief',
name: 'Police Chief',
imagePath: AppImages.officerMiller,
position: Alignment.centerRight,
isHighlighted: true,
emotion: 'Serious',
),
],
choices: [
DialogueChoice(text: 'EXAMINE THE CRIME SCENE', nextSceneId: 'scene_crime_scene'),
],
),
'scene_crime_scene': StoryScene(
id: 'scene_crime_scene',
backgroundImage: AppImages.case2CrimeScene,
dialogue: 'The alley is dark and damp. Emma\'s body lies near a dumpster. You find her laptop bag torn open, but her phone is missing. Blood stains suggest a struggle.',
characters: [],
choices: [
DialogueChoice(
text: 'SEARCH THE VICTIM\'S BAG',
nextSceneId: 'scene_evidence',
),
DialogueChoice(
text: 'QUESTION THE WITNESS',
nextSceneId: 'scene_witness',
),
],
),
'scene_evidence': StoryScene(
id: 'scene_evidence',
backgroundImage: AppImages.case2CrimeScene,
dialogue: 'You find Emma\'s notebook with names: "Alex Carter - Generalist", "Officer Miller - Suspicious payments", "Shadow - Anonymous informant", "Mayor\'s Assistant - Meeting scheduled". Also find a hidden phone.',
characters: [],
choices: [
DialogueChoice(
text: 'INSPECT THE HIDDEN PHONE',
nextSceneId: 'scene_phone',
cluesToAdd: ['notebook'],
),
],
cluesFound: ['notebook', 'hidden_phone'],
),
'scene_witness': StoryScene(
id: 'scene_witness',
backgroundImage: AppImages.case2Alley,
dialogue: 'OFFICER MILLER: "I saw nothing! Just doing my rounds. The mayor\'s office warned us about her... wait, I shouldn\'t have said that."',
characters: [
StoryCharacter(
id: 'miller',
name: 'Officer Miller',
imagePath: AppImages.officerMiller,
position: Alignment.centerRight,
isHighlighted: true,
emotion: 'Nervous',
),
],
choices: [
DialogueChoice(
text: 'PRESS HIM FOR MORE INFO',
nextSceneId: 'scene_miller_confession',
),
DialogueChoice(
text: 'CHECK THE PHONE FIRST',
nextSceneId: 'scene_phone',
),
],
),
'scene_phone': StoryScene(
id: 'scene_phone',
backgroundImage: AppImages.phoneLocked,
dialogue: 'The phone is locked with a 4-digit code. A sticky note says "City Hall file number".',
characters: [],
choices: [
DialogueChoice(
text: 'CRACK THE PHONE PASSCODE',
nextSceneId: 'scene_phone_game',
triggersGame: true,
gameId: 'password_game',
),
],
),
'scene_phone_game': StoryScene(
id: 'scene_phone_game',
backgroundImage: AppImages.phoneUnlocked,
dialogue: 'SUCCESS! Phone unlocked. You discover: \n\n1. Text to "Shadow": "Have evidence on mayor."\n2. Voice memo: "Miller took bribe."\n3. Photo: Mayor\'s assistant at crime scene.\n\nThis was a cover-up!',
characters: [],
choices: [
DialogueChoice(
text: 'CONFRONT THE SUSPECTS',
nextSceneId: 'scene_interrogation',
cluesToAdd: ['phone_evidence'],
),
],
cluesFound: ['phone_evidence'],
),
'scene_miller_confession': StoryScene(
id: 'scene_miller_confession',
backgroundImage: AppImages.case2Alley,
dialogue: 'OFFICER MILLER: "Alright! I was paid to look away. The mayor\'s assistant, David Chen, hired me. Emma found proof of embezzlement. But I didn\'t kill her!"',
characters: [
StoryCharacter(
id: 'miller',
name: 'Officer Miller',
imagePath: AppImages.officerMiller,
position: Alignment.centerRight,
isHighlighted: true,
emotion: 'Guilty',
),
],
choices: [
DialogueChoice(
text: 'WHO IS THE REAL KILLER?',
nextSceneId: 'scene_accuse',
triggersGame: true,
gameId: 'suspect_selection_case2',
),
],
),
'scene_interrogation': StoryScene(
id: 'scene_interrogation',
backgroundImage: AppImages.case2CrimeScene,
dialogue: 'You gather all suspects at the crime scene. Who killed Emma Stone?\n\nALEX CARTER: "I\'m just a generalist, I fix problems!"\nOFFICER MILLER: "I was bribed but not a killer!"\nMAYOR\'S ASSISTANT: "The mayor is innocent!"\nSHADOW: "I warned her it was dangerous..."',
characters: [],
choices: [
DialogueChoice(
text: 'ACCUSE THE KILLER',
nextSceneId: 'scene_accuse',
triggersGame: true,
gameId: 'suspect_selection_case2',
),
],
),
'scene_accuse': StoryScene(
id: 'scene_accuse',
backgroundImage: AppImages.case2Alley,
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
backgroundImage: AppImages.case2Alley,
dialogue: 'DETECTIVE: "The evidence doesn\'t lie! The Mayor\'s Assistant, David Chen, you killed Emma to protect the mayor\'s corruption scheme!"\n\nDAVID CHEN: "She was going to ruin everything! The mayor... the city... I had to silence her!"\n\nPOLICE CHIEF: "Excellent work detective. Case closed."',
characters: [
StoryCharacter(
id: 'assistant',
name: 'David Chen',
imagePath: AppImages.mayorAssistant,
position: Alignment.centerRight,
isHighlighted: true,
emotion: 'Exposed',
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
backgroundImage: AppImages.case2Alley,
dialogue: 'WRONG! You accused the wrong person. The real killer escapes justice. The case goes cold.',
characters: [],
choices: [
DialogueChoice(
text: 'TRY AGAIN',
nextSceneId: 'scene_interrogation',
),
],
),
},
miniGames: {
'password_game': MiniGame.password(
id: 'password_game',
correctPassword: '0426', // City hall file number
hint: 'City Hall file number (e.g., 0426)',
onSuccessNextSceneId: 'scene_phone_game',
),
'suspect_selection_case2': MiniGame.suspectSelection(
id: 'suspect_selection_case2',
suspects: ['Alex Carter', 'Officer Miller', 'Shadow', 'Mayor\'s Assistant'],
correctSuspect: 'Mayor\'s Assistant',
onSuccessNextSceneId: 'scene_correct_accusation',
onFailureNextSceneId: 'scene_wrong_accusation',
hints: ['Who had the most to lose?', 'Check the phone evidence'],
),
},
clues: {
'notebook': Clue.fromScene(
id: 'notebook',
name: 'Emma\'s Notebook',
description: 'Contains names of suspects involved in city hall corruption.',
foundInScene: 'scene_evidence',
type: ClueType.DOCUMENT,
),
'hidden_phone': Clue.fromScene(
id: 'hidden_phone',
name: 'Hidden Smartphone',
description: 'Emma\'s backup phone with encrypted evidence.',
foundInScene: 'scene_evidence',
type: ClueType.EVIDENCE,
),
'phone_evidence': Clue.fromScene(
id: 'phone_evidence',
name: 'Digital Evidence',
description: 'Photos, texts, and voice memos proving corruption.',
foundInScene: 'scene_phone_game',
isImportant: true,
type: ClueType.EVIDENCE,
),
'miller_confession': Clue.fromScene(
id: 'miller_confession',
name: 'Miller\'s Confession',
description: 'Officer Miller admits to taking bribes from mayor\'s office.',
foundInScene: 'scene_miller_confession',
type: ClueType.TESTIMONY,
),
},
suspects: {
'alex_carter': Suspect(
id: 'alex_carter',
name: 'Alex Carter',
description: 'Generalist known for fixing political problems.',
motive: 'Wanted to protect his political connections.',
imagePath: AppImages.alexCarter,
isGuilty: false,
occupation: 'Political Fixer',
age: 45,
relationshipToVictim: 'Subject of investigation',
),
'officer_miller': Suspect(
id: 'officer_miller',
name: 'Officer Miller',
description: 'Corrupt police officer on mayor\'s payroll.',
motive: 'Bribed to look away, but not the killer.',
imagePath: AppImages.officerMiller,
isGuilty: false,
occupation: 'Police Officer',
age: 42,
relationshipToVictim: 'Was being investigated',
),
'shadow': Suspect(
id: 'shadow',
name: 'Shadow',
description: 'Anonymous informant helping Emma.',
motive: 'Wanted to expose corruption, not kill.',
imagePath: AppImages.shadow,
isGuilty: false,
occupation: 'Informant',
age: 35,
relationshipToVictim: 'Source/Informant',
),
'mayors_assistant': Suspect(
id: 'mayors_assistant',
name: 'David Chen',
description: 'Mayor\'s personal assistant and right-hand man.',
motive: 'Killed Emma to protect mayor\'s corruption scheme.',
imagePath: AppImages.mayorAssistant,
isGuilty: true,
occupation: 'Mayor\'s Assistant',
age: 38,
relationshipToVictim: 'Primary target of investigation',
),
},
);
}
