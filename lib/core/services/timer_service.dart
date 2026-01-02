import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerService {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  DateTime? _startTime;
  bool _isRunning = false;

  // Stream for time updates
  final StreamController<Duration> _timeController = StreamController<Duration>.broadcast();
  Stream<Duration> get timeStream => _timeController.stream;

  // Start timer
  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    _startTime = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        _elapsedTime = DateTime.now().difference(_startTime!);
        _timeController.add(_elapsedTime);
      }
    });

    debugPrint('⏱️ Timer started');
  }

  // Pause timer
  void pauseTimer() {
    if (!_isRunning) return;

    _timer?.cancel();
    _isRunning = false;
    debugPrint('⏸️ Timer paused at $_elapsedTime');
  }

  // Resume timer
  void resumeTimer() {
    if (_isRunning) return;

    _isRunning = true;
    _startTime = DateTime.now().subtract(_elapsedTime);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        _elapsedTime = DateTime.now().difference(_startTime!);
        _timeController.add(_elapsedTime);
      }
    });

    debugPrint('▶️ Timer resumed');
  }

  // Stop and reset timer
  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    _elapsedTime = Duration.zero;
    _startTime = null;
    _timeController.add(_elapsedTime);
    debugPrint('⏹️ Timer stopped and reset');
  }

  // Get current time
  Duration getCurrentTime() => _elapsedTime;

  // Format time as MM:SS
  String formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Format time with hours
  String formatTimeWithHours(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  // Check if timer is running
  bool isRunning() => _isRunning;

  // Dispose
  void dispose() {
    _timer?.cancel();
    _timeController.close();
  }
}