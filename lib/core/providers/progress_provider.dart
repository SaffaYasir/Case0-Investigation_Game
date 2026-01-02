import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaseProgress {
final int caseNumber;
final bool isCompleted;
final int score;
final DateTime? completedAt;
final int cluesFound;
final double timeSpent; // in minutes
final double accuracy; // percentage

CaseProgress({
required this.caseNumber,
this.isCompleted = false,
this.score = 0,
this.completedAt,
this.cluesFound = 0,
this.timeSpent = 0,
this.accuracy = 0,
});

// Convert to map for JSON storage
Map<String, dynamic> toMap() {
return {
'caseNumber': caseNumber,
'isCompleted': isCompleted,
'score': score,
'completedAt': completedAt?.toIso8601String(),
'cluesFound': cluesFound,
'timeSpent': timeSpent,
'accuracy': accuracy,
};
}

// Create from map
factory CaseProgress.fromMap(Map<String, dynamic> map) {
return CaseProgress(
caseNumber: map['caseNumber'] ?? 0,
isCompleted: map['isCompleted'] ?? false,
score: map['score'] ?? 0,
completedAt: map['completedAt'] != null && map['completedAt'] != 'null'
? DateTime.parse(map['completedAt'])
    : null,
cluesFound: map['cluesFound'] ?? 0,
timeSpent: (map['timeSpent'] ?? 0).toDouble(),
accuracy: (map['accuracy'] ?? 0).toDouble(),
);
}

// Helper method for formatted time
String getFormattedTime() {
final minutes = timeSpent.floor();
final seconds = ((timeSpent - minutes) * 60).round();
return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
}

class ProgressService {
static const String _firebaseCollection = 'user_progress';
static const String _localStorageKey = 'case_progress_v2_backup';

// Get current user ID
static String? get _userId {
return FirebaseAuth.instance.currentUser?.uid;
}

// Load progress from Firebase (with local fallback)
static Future<List<CaseProgress>> loadProgress() async {
final userId = _userId;

// If no user is logged in, return default progress
if (userId == null) {
return _getDefaultProgress();
}

try {
// Try to load from Firebase first
final docRef = FirebaseFirestore.instance
    .collection(_firebaseCollection)
    .doc(userId);

final doc = await docRef.get();

if (doc.exists && doc.data() != null) {
final data = doc.data()!;
final progressList = _parseFirebaseData(data);

// Migrate any local progress to Firebase
await _migrateLocalToFirebase(userId, progressList);

return _ensureAllCases(progressList);
} else {
// No Firebase data, check local storage
final localProgress = await _loadLocalProgress();

// Save local progress to Firebase for future sync
if (localProgress.isNotEmpty) {
await _saveToFirebase(userId, localProgress);
}

return _ensureAllCases(localProgress);
}
} catch (e) {
print('Error loading progress from Firebase: $e');
// Fallback to local storage
return _ensureAllCases(await _loadLocalProgress());
}
}

// Save progress to Firebase (and locally as backup)
static Future<void> saveProgress(List<CaseProgress> progressList) async {
final userId = _userId;

// Save locally as backup
await _saveLocalProgress(progressList);

// Save to Firebase if user is logged in
if (userId != null) {
try {
await _saveToFirebase(userId, progressList);
} catch (e) {
print('Error saving to Firebase: $e');
// Continue anyway - at least we have local backup
}
}
}

// Update specific case progress
static Future<void> updateCaseProgress(CaseProgress updatedProgress) async {
final progressList = await loadProgress();
final index = progressList.indexWhere((p) => p.caseNumber == updatedProgress.caseNumber);

if (index >= 0) {
progressList[index] = updatedProgress;
} else {
progressList.add(updatedProgress);
}

await saveProgress(progressList);
}

// Mark case as completed
static Future<void> markCaseCompleted({
required int caseNumber,
required int score,
required int cluesFound,
required double timeSpent,
required double accuracy,
}) async {
final progress = CaseProgress(
caseNumber: caseNumber,
isCompleted: true,
score: score,
completedAt: DateTime.now(),
cluesFound: cluesFound,
timeSpent: timeSpent,
accuracy: accuracy,
);

await updateCaseProgress(progress);

// Update user rank in profile
await _updateUserRank();
}

// Add clue found to case
static Future<void> addClueFound(int caseNumber) async {
final progressList = await loadProgress();
final progress = progressList.firstWhere(
(p) => p.caseNumber == caseNumber,
orElse: () => CaseProgress(caseNumber: caseNumber),
);

final updated = CaseProgress(
caseNumber: caseNumber,
isCompleted: progress.isCompleted,
score: progress.score + 100,
completedAt: progress.completedAt,
cluesFound: progress.cluesFound + 1,
timeSpent: progress.timeSpent,
accuracy: progress.accuracy,
);

await updateCaseProgress(updated);
}

// Get rank based on completed cases
static String getRank(List<CaseProgress> progressList) {
final completedCases = progressList.where((p) => p.isCompleted).length;
final totalScore = progressList.fold(0, (sum, p) => sum + p.score);

if (completedCases >= 10 && totalScore >= 10000) return 'MASTER DETECTIVE';
if (completedCases >= 5 && totalScore >= 5000) return 'CHIEF INSPECTOR';
if (completedCases >= 3 && totalScore >= 2000) return 'DETECTIVE';
if (completedCases >= 1 && totalScore >= 500) return 'ROOKIE DETECTIVE';
return 'NOVICE';
}

// Update user rank in Firebase profile
static Future<void> _updateUserRank() async {
final userId = _userId;
if (userId == null) return;

try {
final progressList = await loadProgress();
final rank = getRank(progressList);

await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .update({
'rank': rank,
'updatedAt': FieldValue.serverTimestamp(),
});
} catch (e) {
print('Error updating user rank: $e');
}
}

// Get statistics
static Map<String, dynamic> getStatistics(List<CaseProgress> progressList) {
final completed = progressList.where((p) => p.isCompleted);
final completedCount = completed.length;
final totalClues = progressList.fold(0, (sum, p) => sum + p.cluesFound);
final totalScore = progressList.fold(0, (sum, p) => sum + p.score);

double avgTime = 0;
double avgAccuracy = 0;

if (completedCount > 0) {
avgTime = completed.fold(0.0, (sum, p) => sum + p.timeSpent) / completedCount;
avgAccuracy = completed.fold(0.0, (sum, p) => sum + p.accuracy) / completedCount;
}

final fastestCase = completed.isEmpty ? null :
completed.reduce((a, b) => a.timeSpent < b.timeSpent ? a : b);

final slowestCase = completed.isEmpty ? null :
completed.reduce((a, b) => a.timeSpent > b.timeSpent ? a : b);

return {
'completedCases': completedCount,
'totalClues': totalClues,
'totalScore': totalScore,
'avgTime': avgTime,
'avgAccuracy': avgAccuracy,
'fastestCase': fastestCase,
'slowestCase': slowestCase,
};
}

// Helper methods
static List<CaseProgress> _getDefaultProgress() {
return List.generate(5, (index) => CaseProgress(
caseNumber: index + 1,
isCompleted: false,
score: 0,
cluesFound: 0,
timeSpent: 0,
accuracy: 0,
));
}

static List<CaseProgress> _ensureAllCases(List<CaseProgress> existing) {
final List<CaseProgress> result = [];

for (int i = 1; i <= 5; i++) {
final existingCase = existing.firstWhere(
(p) => p.caseNumber == i,
orElse: () => CaseProgress(caseNumber: i),
);
result.add(existingCase);
}

return result;
}

// Local storage methods (backup)
static Future<List<CaseProgress>> _loadLocalProgress() async {
final prefs = await SharedPreferences.getInstance();
final progressString = prefs.getString(_localStorageKey);

if (progressString == null || progressString.isEmpty) {
return _getDefaultProgress();
}

try {
final progressList = <CaseProgress>[];
final items = progressString.split('|');

for (final item in items) {
if (item.isNotEmpty) {
progressList.add(_parseLocalProgress(item));
}
}

return progressList;
} catch (e) {
print('Error loading local progress: $e');
return _getDefaultProgress();
}
}

static Future<void> _saveLocalProgress(List<CaseProgress> progressList) async {
final prefs = await SharedPreferences.getInstance();
final progressString = progressList
    .map((progress) => _serializeLocalProgress(progress))
    .join('|');

await prefs.setString(_localStorageKey, progressString);
}

// Firebase methods
static Future<void> _saveToFirebase(String userId, List<CaseProgress> progressList) async {
final progressMap = <String, dynamic>{};

for (final progress in progressList) {
progressMap['case_${progress.caseNumber}'] = progress.toMap();
}

// Also store aggregated stats for quick access
final stats = getStatistics(progressList);
final rank = getRank(progressList);

progressMap['lastSynced'] = FieldValue.serverTimestamp();
progressMap['totalCompleted'] = stats['completedCases'];
progressMap['totalScore'] = stats['totalScore'];
progressMap['userRank'] = rank;

await FirebaseFirestore.instance
    .collection(_firebaseCollection)
    .doc(userId)
    .set(progressMap, SetOptions(merge: true));
}

static List<CaseProgress> _parseFirebaseData(Map<String, dynamic> data) {
final progressList = <CaseProgress>[];

for (final key in data.keys) {
if (key.startsWith('case_')) {
final caseData = data[key];
if (caseData is Map<String, dynamic>) {
progressList.add(CaseProgress.fromMap(caseData));
}
}
}

return progressList;
}

// Migration: Move local progress to Firebase
static Future<void> _migrateLocalToFirebase(String userId, List<CaseProgress> firebaseProgress) async {
final localProgress = await _loadLocalProgress();

// Check if local has more progress than Firebase
final localCompleted = localProgress.where((p) => p.isCompleted).length;
final firebaseCompleted = firebaseProgress.where((p) => p.isCompleted).length;

if (localCompleted > firebaseCompleted) {
// Local has more progress, migrate it
await _saveToFirebase(userId, localProgress);
print('Migrated local progress to Firebase');
}
}

// Local storage serialization/deserialization
static String _serializeLocalProgress(CaseProgress progress) {
return [
'caseNumber:${progress.caseNumber}',
'isCompleted:${progress.isCompleted}',
'score:${progress.score}',
'completedAt:${progress.completedAt?.toIso8601String() ?? ''}',
'cluesFound:${progress.cluesFound}',
'timeSpent:${progress.timeSpent}',
'accuracy:${progress.accuracy}',
].join(',');
}

static CaseProgress _parseLocalProgress(String str) {
final map = <String, dynamic>{};
final pairs = str.split(',');

for (final pair in pairs) {
final parts = pair.split(':');
if (parts.length == 2) {
final key = parts[0];
final value = parts[1];

switch (key) {
case 'caseNumber':
case 'score':
case 'cluesFound':
map[key] = int.tryParse(value) ?? 0;
break;
case 'isCompleted':
map[key] = value.toLowerCase() == 'true';
break;
case 'timeSpent':
case 'accuracy':
map[key] = double.tryParse(value) ?? 0.0;
break;
case 'completedAt':
if (value.isNotEmpty) {
map[key] = value;
}
break;
}
}
}

return CaseProgress.fromMap(map);
}
}

// Riverpod Providers
final progressProvider = FutureProvider<List<CaseProgress>>((ref) async {
return await ProgressService.loadProgress();
});

final progressStatsProvider = Provider<Map<String, dynamic>>((ref) {
final progressList = ref.watch(progressProvider).value ?? [];
return ProgressService.getStatistics(progressList);
});

final userRankProvider = Provider<String>((ref) {
final progressList = ref.watch(progressProvider).value ?? [];
return ProgressService.getRank(progressList);
});
