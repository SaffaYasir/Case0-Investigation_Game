import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _soundPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _ambiencePlayer = AudioPlayer();

  bool _isInitialized = false;
  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  bool _isVibrationEnabled = true;

  // FIXED: Removed "assets/" prefix since AssetSource automatically adds it
  static const Map<String, String> _soundAssets = {
    'game_start': 'sounds/game_start.mp3',
    'notification': 'sounds/notification.mp3',
    'ambient': 'sounds/ambient.mp3',
    'background': 'sounds/background.mp3',
    'failure': 'sounds/failure.mp3',
    'success': 'sounds/success.mp3',
    'case_complete': 'sounds/case_complete.mp3',
    'click': 'sounds/click.mp3',
  };

  // Initialize sound system
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🚀 Initializing SoundService...');

      // Set global audio context
      try {
        await AudioPlayer.global.setAudioContext(
          const AudioContext(
            android: AudioContextAndroid(
              contentType: AndroidContentType.music,
              usageType: AndroidUsageType.game,
              audioFocus: AndroidAudioFocus.gainTransientMayDuck,
            ),
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.playback,
              options: [AVAudioSessionOptions.mixWithOthers],
            ),
          ),
        );
        debugPrint('✅ Audio context set successfully');
      } catch (e) {
        debugPrint('⚠️ Could not set audio context: $e (continuing anyway)');
      }

      // Configure players
      await _soundPlayer.setReleaseMode(ReleaseMode.stop);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _ambiencePlayer.setReleaseMode(ReleaseMode.loop);

      _isInitialized = true;
      debugPrint('✅ SoundService initialized successfully');

      // Start background music if enabled
      if (_isMusicEnabled) {
        await _startBackgroundMusic();
        await _startAmbientSound();
      }

    } catch (e) {
      debugPrint('❌ SoundService initialization error: $e');
    }
  }

  // Helper method to load and play sound
  Future<void> _playSound(String soundKey) async {
    if (!_isInitialized) await initialize();
    if (!_isSoundEnabled) return;

    try {
      debugPrint('🎵 Playing sound: $soundKey');
      await _soundPlayer.stop();
      await _soundPlayer.setSource(AssetSource(_soundAssets[soundKey]!));
      await _soundPlayer.resume();
    } catch (e) {
      debugPrint('❌ Error playing $soundKey: $e');
      debugPrint('Asset path tried: ${_soundAssets[soundKey]}');
    }
  }

  // Toggle methods
  // In SoundService class, update these methods:

  void enableSound(bool enabled) {
    _isSoundEnabled = enabled;
    if (!enabled) {
      _soundPlayer.stop();
    }
    debugPrint('🔊 Sound ${enabled ? 'enabled' : 'disabled'}');
  }

  void enableMusic(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.stop();
      _ambiencePlayer.stop();
      debugPrint('🎵 Music disabled');
    } else if (_isInitialized) {
      _startBackgroundMusic();
      _startAmbientSound();
      debugPrint('🎵 Music enabled');
    }
  }

  void enableVibration(bool enabled) {
    _isVibrationEnabled = enabled;
    debugPrint('📳 Vibration ${enabled ? 'enabled' : 'disabled'}');
  }

  // Play game start sound
  Future<void> playGameStart() async {
    await _playSound('game_start');
    await _vibrate();
  }

  // Play notification sound
  Future<void> playNotification() async {
    await _playSound('notification');
    await _vibrate();
  }

  // Play success sound
  Future<void> playSuccess() async {
    await _playSound('success');
    await _vibrate();
  }

  // Play failure sound
  Future<void> playFailure() async {
    await _playSound('failure');
    await _vibrate(duration: 500);
  }

  // Play case complete fanfare
  Future<void> playCaseComplete() async {
    await _playSound('case_complete');

    // Celebration vibration pattern
    if (_isVibrationEnabled) {
      await _vibrate(duration: 200);
      await Future.delayed(const Duration(milliseconds: 100));
      await _vibrate(duration: 200);
      await Future.delayed(const Duration(milliseconds: 100));
      await _vibrate(duration: 400);
    }
  }

  // Play UI click
  Future<void> playClick() async {
    await _playSound('click');
    await _vibrate(duration: 50);
  }

  // Start background music
  Future<void> _startBackgroundMusic() async {
    if (!_isMusicEnabled) return;

    try {
      await _musicPlayer.stop();
      await _musicPlayer.setSource(AssetSource(_soundAssets['background']!));
      await _musicPlayer.setVolume(0.3);
      await _musicPlayer.resume();
      debugPrint('🎵 Background music started');
    } catch (e) {
      debugPrint('❌ Error starting background music: $e');
    }
  }

  // Start ambient sound
  Future<void> _startAmbientSound() async {
    if (!_isMusicEnabled) return;

    try {
      await _ambiencePlayer.stop();
      await _ambiencePlayer.setSource(AssetSource(_soundAssets['ambient']!));
      await _ambiencePlayer.setVolume(0.1);
      await _ambiencePlayer.resume();
      debugPrint('🔊 Ambient sound started');
    } catch (e) {
      debugPrint('❌ Error starting ambient sound: $e');
    }
  }

  // Vibration
  Future<void> _vibrate({int duration = 100}) async {
    if (!_isVibrationEnabled) return;

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator ?? false) {
        if (duration > 0) {
          await Vibration.vibrate(duration: duration);
        } else {
          await Vibration.vibrate();
        }
      }
    } catch (e) {
      debugPrint('❌ Error with vibration: $e');
    }
  }

  // ADDED BACK: Stop all sounds
  Future<void> stopAll() async {
    await _soundPlayer.stop();
    await _musicPlayer.stop();
    await _ambiencePlayer.stop();
    debugPrint('⏹️ All sounds stopped');
  }

  // ADDED BACK: Pause when app goes to background
  Future<void> pauseAll() async {
    if (_isMusicEnabled) {
      await _musicPlayer.pause();
      await _ambiencePlayer.pause();
    }
    await _soundPlayer.pause();
    debugPrint('⏸️ All sounds paused');
  }

  // ADDED BACK: Resume when app comes to foreground
  Future<void> resumeAll() async {
    if (_isMusicEnabled) {
      await _musicPlayer.resume();
      await _ambiencePlayer.resume();
    }
    await _soundPlayer.resume();
    debugPrint('▶️ All sounds resumed');
  }

  // Check if sound files exist (TEST METHOD)
  Future<bool> checkSoundAssets() async {
    try {
      debugPrint('🔍 Checking sound assets...');
      bool allAssetsValid = true;

      for (final entry in _soundAssets.entries) {
        final assetName = entry.key;
        final assetPath = entry.value;

        try {
          // Try to load the asset
          final source = AssetSource(assetPath);
          // Try to get duration to verify file exists
          final player = AudioPlayer();
          await player.setSource(source);
          await player.stop(); // Clean up
          player.dispose();

          debugPrint('✅ $assetName: $assetPath');
        } catch (e) {
          debugPrint('❌ $assetName: $assetPath - Error: $e');
          allAssetsValid = false;
        }
      }

      return allAssetsValid;
    } catch (e) {
      debugPrint('❌ Error checking sound assets: $e');
      return false;
    }
  }

  // Test all sounds
  Future<void> testAllSounds() async {
    if (!_isInitialized) await initialize();

    debugPrint('🧪 Starting sound test...');

    // Test click
    debugPrint('1. Testing click sound...');
    await playClick();
    await Future.delayed(const Duration(milliseconds: 800));

    // Test notification
    debugPrint('2. Testing notification sound...');
    await playNotification();
    await Future.delayed(const Duration(milliseconds: 800));

    // Test success
    debugPrint('3. Testing success sound...');
    await playSuccess();
    await Future.delayed(const Duration(milliseconds: 800));

    // Test failure
    debugPrint('4. Testing failure sound...');
    await playFailure();
    await Future.delayed(const Duration(milliseconds: 800));

    // Test game start
    debugPrint('5. Testing game start sound...');
    await playGameStart();
    await Future.delayed(const Duration(milliseconds: 1000));

    // Test case complete
    debugPrint('6. Testing case complete sound...');
    await playCaseComplete();
    await Future.delayed(const Duration(milliseconds: 1000));

    debugPrint('🎊 Sound test completed!');
  }

  // Set music volume
  Future<void> setMusicVolume(double volume) async {
    if (_isInitialized) {
      await _musicPlayer.setVolume(volume);
      debugPrint('🔊 Music volume set to: $volume');
    }
  }

  // Set sound volume
  Future<void> setSoundVolume(double volume) async {
    if (_isInitialized) {
      await _soundPlayer.setVolume(volume);
      debugPrint('🔊 Sound volume set to: $volume');
    }
  }

  // Cleanup
  void dispose() {
    _soundPlayer.dispose();
    _musicPlayer.dispose();
    _ambiencePlayer.dispose();
    _isInitialized = false;
    debugPrint('🗑️ SoundService disposed');
  }

  // Quick debug method to check service status
  void debugStatus() {
    debugPrint('''
🎵 SoundService Status:
   Initialized: $_isInitialized
   Sound Enabled: $_isSoundEnabled
   Music Enabled: $_isMusicEnabled
   Vibration Enabled: $_isVibrationEnabled
''');
  }
}