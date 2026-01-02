import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/story_model.dart';
import '../../../../core/constants/app_colors.dart';
import './case_data/case1_data.dart';
import './case_data/case2_data.dart';
import './gameplay/story_screen.dart';
import './gameplay/minigame_handler.dart';
import '../../../../core/providers/progress_provider.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/services/timer_service.dart';
import '../../../../core/services/analytics_service.dart'; // ADD THIS

class CasePlayScreen extends ConsumerStatefulWidget {
  final int caseNumber;
  const CasePlayScreen({super.key, required this.caseNumber});

  @override
  ConsumerState<CasePlayScreen> createState() => _CasePlayScreenState();
}

class _CasePlayScreenState extends ConsumerState<CasePlayScreen> with WidgetsBindingObserver {
  late StoryCaseData _currentCase;
  String _currentSceneId = '';
  final Set<String> _collectedClueIds = {};
  bool _isLoading = true;
  String? _activeGameId;
  bool _gameInProgress = false;
  bool _caseCompleted = false;

  final TimerService _timerService = TimerService();
  StreamSubscription<Duration>? _timeSubscription;
  Duration _elapsedTime = Duration.zero;
  bool _timerRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Track case start in analytics
    AnalyticsService().logCaseStarted(widget.caseNumber);
    AnalyticsService().logScreenView(
      screenName: 'CasePlayScreen',
      parameters: {'case_number': widget.caseNumber},
    );

    _loadCaseData();
    _startTimerTracking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timeSubscription?.cancel();
    _timerService.stopTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        if (_timerRunning) {
          _timerService.pauseTimer();
          _timerRunning = false;
          AnalyticsService().logEvent(name: 'case_timer_paused');
        }
        break;
      case AppLifecycleState.resumed:
        if (!_timerRunning && !_caseCompleted) {
          _timerService.resumeTimer();
          _timerRunning = true;
          AnalyticsService().logEvent(name: 'case_timer_resumed');
        }
        break;
      default:
        break;
    }
  }

  void _startTimerTracking() {
    if (!_timerRunning) {
      _timerService.startTimer();
      _timerRunning = true;

      _timeSubscription = _timerService.timeStream.listen((time) {
        if (mounted) {
          setState(() {
            _elapsedTime = time;
          });
        }
      });
    }
  }

  void _loadCaseData() {
    setState(() {
      _isLoading = true;
      _caseCompleted = false;
      _timerRunning = false;

      try {
        if (widget.caseNumber == 1) {
          _currentCase = Case1Data.vanishedNecklace;
        } else if (widget.caseNumber == 2) {
          _currentCase = Case2Data.murderAlley;
        } else {
          _currentCase = Case1Data.vanishedNecklace;
        }

        _currentSceneId = _currentCase.startSceneId;
        _collectedClueIds.clear();
        _activeGameId = null;
        _gameInProgress = false;

        AnalyticsService().logEvent(
          name: 'case_loaded',
          parameters: {
            'case_number': widget.caseNumber,
            'scene_id': _currentSceneId,
          },
        );

      } catch (e) {
        debugPrint('Error loading case data: $e');
        _currentCase = Case1Data.vanishedNecklace;
        _currentSceneId = _currentCase.startSceneId;

        AnalyticsService().logError('case_load_error', e.toString());
      }

      _isLoading = false;
    });
  }

  void _onGameComplete(bool success) {
    AnalyticsService().logEvent(
      name: 'mini_game_completed',
      parameters: {
        'game_id': _activeGameId,
        'success': success,
        'case_number': widget.caseNumber,
        'scene_id': _currentSceneId,
      },
    );

    setState(() {
      _gameInProgress = false;
      final game = _currentCase.miniGames[_activeGameId];

      if (game != null) {
        if (game.type == GameType.SUSPECT_SELECTION) {
          // For suspect selection
          if (success) {
            _caseCompleted = true;
            _markCaseCompleted();

            final nextScene = game.config['onSuccessNextSceneId'];
            if (nextScene != null) {
              _handleChoiceSelected(nextScene);
            }
          } else {
            final nextScene = game.config['onFailureNextSceneId'];
            if (nextScene != null) {
              _handleChoiceSelected(nextScene);
            }
          }
        }
        // Handle all other games (memory match, safe code)
        else {
          if (success) {
            // Game successful
            SoundService().playSuccess();
            AnalyticsService().logEvent(name: 'mini_game_success');

            // Find the scene choice that triggered this game
            final currentScene = _currentCase.scenes[_currentSceneId];
            if (currentScene != null) {
              // Find the choice that has this gameId
              for (final choice in currentScene.choices) {
                if (choice.gameId == _activeGameId && choice.nextSceneId.isNotEmpty) {
                  _handleChoiceSelected(choice.nextSceneId);

                  // Add any clues from this choice
                  if (choice.cluesToAdd.isNotEmpty) {
                    _collectedClueIds.addAll(choice.cluesToAdd);
                    // Track clue found
                    for (final clueId in choice.cluesToAdd) {
                      AnalyticsService().logClueFound(widget.caseNumber, clueId);
                    }
                  }
                  return;
                }
              }

              // SPECIAL HANDLING FOR SAFE CODE GAME
              if (game.type == GameType.CRACK_CODE) {
                // After safe code success, go to scene_final_accusation
                _handleChoiceSelected('scene_final_accusation');

                // Also add safe_contents clue if in safe game scene
                if (_currentSceneId == 'scene_safe_game') {
                  _collectedClueIds.add('safe_contents');
                  AnalyticsService().logClueFound(widget.caseNumber, 'safe_contents');
                }
                return;
              }
            }
          } else {
            // Game failed
            SoundService().playFailure();
            AnalyticsService().logEvent(name: 'mini_game_failed');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Try again!'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }

      _activeGameId = null;
    });
  }

  Future<void> _markCaseCompleted() async {
    if (!_timerRunning) return; // Prevent multiple calls

    _timerService.stopTimer();
    _timerRunning = false;

    final totalTimeInMinutes = _elapsedTime.inSeconds / 60.0;
    final totalClues = _currentCase.clues.length;
    final cluesFound = _collectedClueIds.length;
    final accuracy = totalClues > 0 ? (cluesFound / totalClues) * 100 : 0.0;
    final score = 100 + (cluesFound * 50);

    // Track case completion in analytics
    AnalyticsService().logCaseCompleted(
      caseNumber: widget.caseNumber,
      score: score,
      cluesFound: cluesFound,
      timeSpent: totalTimeInMinutes,
      accuracy: accuracy,
    );

    // Save to Firebase
    try {
      await ProgressService.markCaseCompleted(
        caseNumber: widget.caseNumber,
        score: score,
        cluesFound: cluesFound,
        timeSpent: totalTimeInMinutes,
        accuracy: accuracy,
      );

      // Update local progress list for UI
      final progressList = await ProgressService.loadProgress();
      final index = progressList.indexWhere((p) => p.caseNumber == widget.caseNumber);

      if (index >= 0) {
        progressList[index] = CaseProgress(
          caseNumber: widget.caseNumber,
          isCompleted: true,
          score: score,
          completedAt: DateTime.now(),
          cluesFound: cluesFound,
          timeSpent: totalTimeInMinutes,
          accuracy: accuracy,
        );
      }

      ref.invalidate(progressProvider);
    } catch (e) {
      debugPrint('Error updating progress UI: $e');
      AnalyticsService().logError('case_completion_error', e.toString());
    }

    SoundService().playCaseComplete();
  }

  void _handleChoiceSelected(String nextSceneId) {
    AnalyticsService().logEvent(
      name: 'scene_choice_selected',
      parameters: {
        'from_scene': _currentSceneId,
        'to_scene': nextSceneId,
        'case_number': widget.caseNumber,
      },
    );

    if (nextSceneId == 'end' || nextSceneId == 'case_end' || _caseCompleted) {
      _showCaseCompleteDialog();
      return;
    }

    if (nextSceneId == 'game_over') {
      _timerService.stopTimer();
      _timerRunning = false;
      _showGameOverDialog();
      return;
    }

    setState(() {
      final currentScene = _currentCase.scenes[_currentSceneId];
      if (currentScene?.cluesFound != null && currentScene!.cluesFound.isNotEmpty) {
        _collectedClueIds.addAll(currentScene.cluesFound);
        // Track clues found
        for (final clueId in currentScene.cluesFound) {
          AnalyticsService().logClueFound(widget.caseNumber, clueId);
        }
      }
      _currentSceneId = nextSceneId;
    });
  }

  void _showCaseCompleteDialog() {
    if (!_caseCompleted) {
      _markCaseCompleted();
      _caseCompleted = true;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neonGreen, width: 2),
        ),
        title: Text(
          'CASE SOLVED!',
          style: TextStyle(
            color: AppColors.neonGreen,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        content: Text(
          'Congratulations! You have successfully solved Case #${widget.caseNumber}.\n\n'
              'Clues Found: ${_collectedClueIds.length}\n'
              'Score: ${100 + (_collectedClueIds.length * 50)}\n'
              'Time: ${_getFormattedTime()}\n\n'
              'Returning to dashboard...',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AnalyticsService().logEvent(name: 'case_complete_continue');
              Navigator.pop(context);
              context.go('/dashboard');
            },
            child: Text(
              'CONTINUE',
              style: TextStyle(
                color: AppColors.neonGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedTime() {
    final minutes = _elapsedTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _elapsedTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showGameOverDialog() {
    AnalyticsService().logEvent(
      name: 'case_game_over',
      parameters: {'case_number': widget.caseNumber},
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neonRed, width: 2),
        ),
        title: Text(
          'INVESTIGATION FAILED',
          style: TextStyle(
            color: AppColors.neonRed,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        content: Text(
          'The trail went cold. You were unable to solve the case.\n\nTry again?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AnalyticsService().logEvent(name: 'case_retry');
              Navigator.pop(context);
              _loadCaseData();
              _startTimerTracking();
            },
            child: Text(
              'RETRY',
              style: TextStyle(
                color: AppColors.neonRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              AnalyticsService().logEvent(name: 'case_return_to_cases');
              Navigator.pop(context);
              context.go('/cases');
            },
            child: Text(
              'RETURN TO CASES',
              style: TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.darkestGray,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.neonRed),
              const SizedBox(height: 20),
              Text(
                'LOADING CASE #${widget.caseNumber}...',
                style: TextStyle(
                  color: AppColors.neonRed,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_gameInProgress && _activeGameId != null) {
      final game = _currentCase.miniGames[_activeGameId];
      if (game != null) {
        return MiniGameHandler.getGameWidget(
          game: game,
          onGameComplete: _onGameComplete,
          context: context,
        );
      }
    }

    final currentScene = _currentCase.scenes[_currentSceneId];

    if (currentScene == null) {
      return Scaffold(
        backgroundColor: AppColors.darkestGray,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: AppColors.neonRed, size: 64),
              const SizedBox(height: 20),
              Text(
                'SCENE NOT FOUND',
                style: TextStyle(
                  color: AppColors.neonRed,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Scene ID: $_currentSceneId',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _timerService.stopTimer();
                  AnalyticsService().logEvent(name: 'case_error_return_to_cases');
                  context.go('/cases');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonRed,
                ),
                child: const Text('RETURN TO CASES'),
              ),
            ],
          ),
        ),
      );
    }

    final List<Clue> clues = _collectedClueIds
        .map((id) => _currentCase.clues[id])
        .whereType<Clue>()
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          StorySceneWidget(
            scene: currentScene,
            onChoiceSelected: _handleChoiceSelected,
            onGameTriggered: (gameId) => setState(() {
              _activeGameId = gameId;
              _gameInProgress = true;
              AnalyticsService().logEvent(
                name: 'mini_game_started',
                parameters: {'game_id': gameId, 'case_number': widget.caseNumber},
              );
            }),
            collectedClues: clues,
            caseNumber: widget.caseNumber,
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.neonBlue),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, color: AppColors.neonBlue, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _getFormattedTime(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}