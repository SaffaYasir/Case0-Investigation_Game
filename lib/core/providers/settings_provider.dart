import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:case_zero_detective/core/services/sound_service.dart';

class AppSettings {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final String theme;
  final double fontSize;
  final String language; // ADD THIS LINE

  const AppSettings({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
    this.theme = 'dark',
    this.fontSize = 1.0,
    this.language = 'en', // ADD THIS LINE - 'en' for English, 'zh' for Chinese
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    String? theme,
    double? fontSize,
    String? language, // ADD THIS LINE
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      language: language ?? this.language, // ADD THIS LINE
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
      soundEnabled: prefs.getBool('soundEnabled') ?? true,
      musicEnabled: prefs.getBool('musicEnabled') ?? true,
      vibrationEnabled: prefs.getBool('vibrationEnabled') ?? true,
      theme: prefs.getString('theme') ?? 'dark',
      fontSize: prefs.getDouble('fontSize') ?? 1.0,
      language: prefs.getString('language') ?? 'en', // ADD THIS LINE
    );

    // Apply initial settings to SoundService
    _applySoundSettings();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', state.notificationsEnabled);
    await prefs.setBool('soundEnabled', state.soundEnabled);
    await prefs.setBool('musicEnabled', state.musicEnabled);
    await prefs.setBool('vibrationEnabled', state.vibrationEnabled);
    await prefs.setString('theme', state.theme);
    await prefs.setDouble('fontSize', state.fontSize);
    await prefs.setString('language', state.language); // ADD THIS LINE
  }

  void _applySoundSettings() {
    final soundService = SoundService();
    soundService.enableSound(state.soundEnabled);
    soundService.enableMusic(state.musicEnabled);
    soundService.enableVibration(state.vibrationEnabled);
  }

  void setNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
    _save();
  }

  void setSound(bool value) {
    state = state.copyWith(soundEnabled: value);
    _save();
    // Immediately apply to SoundService
    SoundService().enableSound(value);
  }

  void setMusic(bool value) {
    state = state.copyWith(musicEnabled: value);
    _save();
    // Immediately apply to SoundService
    SoundService().enableMusic(value);
  }

  void setVibration(bool value) {
    state = state.copyWith(vibrationEnabled: value);
    _save();
    // Immediately apply to SoundService
    SoundService().enableVibration(value);
  }

  void setTheme(String value) {
    state = state.copyWith(theme: value);
    _save();
  }

  void setFontSize(double value) {
    state = state.copyWith(fontSize: value.clamp(0.8, 1.5));
    _save();
  }

  // ADD THIS METHOD for language setting
  void setLanguage(String value) {
    state = state.copyWith(language: value);
    _save();
  }

  void resetToDefaults() {
    state = const AppSettings();
    _save();
    _applySoundSettings();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});