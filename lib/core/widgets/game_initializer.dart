import 'package:flutter/material.dart';
import 'package:case_zero_detective/core/services/sound_service.dart';
import 'package:case_zero_detective/core/services/notification_service.dart';
import 'package:case_zero_detective/core/services/analytics_service.dart'; // ADD THIS

class GameInitializer extends StatefulWidget {
  final Widget child;

  const GameInitializer({
    super.key,
    required this.child,
  });

  @override
  State<GameInitializer> createState() => _GameInitializerState();
}

class _GameInitializerState extends State<GameInitializer> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      print('GameInitializer: Starting service initialization...');

      // Initialize analytics service
      await AnalyticsService().logAppOpened();
      print('GameInitializer: Analytics service initialized');

      // Initialize notification service
      await NotificationService().initialize();
      print('GameInitializer: Notification service initialized');

      // Initialize sound service
      final soundService = SoundService();
      await soundService.initialize();
      print('GameInitializer: Sound service initialized');

      // Play game start sound after a short delay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          soundService.playGameStart();
          print('GameInitializer: Game start sound played');
        });
      });

      print('GameInitializer: All services initialized successfully');
    } catch (e) {
      print('GameInitializer: Error initializing services: $e');
      AnalyticsService().logError('service_initialization', e.toString());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final soundService = SoundService();
    final analytics = AnalyticsService();

    try {
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.detached:
        case AppLifecycleState.hidden:
          soundService.pauseAll();
          analytics.logAppBackgrounded();
          break;
        case AppLifecycleState.resumed:
          soundService.resumeAll();
          analytics.logEvent(name: 'app_resumed');
          break;
        case AppLifecycleState.inactive:
        // Do nothing
          break;
      }
    } catch (e) {
      print('GameInitializer: Error in lifecycle state change: $e');
      analytics.logError('lifecycle_error', e.toString());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      SoundService().dispose();
    } catch (e) {
      print('GameInitializer: Error disposing sound service: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}