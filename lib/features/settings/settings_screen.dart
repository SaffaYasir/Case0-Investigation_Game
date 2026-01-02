import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:case_zero_detective/core/constants/app_colors.dart';
import 'package:case_zero_detective/core/providers/settings_provider.dart';
import 'package:case_zero_detective/core/services/sound_service.dart';
import 'package:case_zero_detective/core/services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final fontSize = settings.fontSize;

    return Scaffold(
      backgroundColor: AppColors.darkestGray,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.neonRed.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      SoundService().playClick();
                      context.pop();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.neonRed,
                      size: 28.0 * fontSize,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'SETTINGS',
                    style: TextStyle(
                      fontSize: 20.0 * fontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neonRed,
                      fontFamily: 'Courier New',
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AUDIO & VIBRATION
                    Text(
                      'AUDIO & VIBRATION',
                      style: TextStyle(
                        color: AppColors.neonRed,
                        fontSize: 16.0 * fontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildSettingItem(
                      'Sound Effects',
                      Icons.volume_up,
                      settings.soundEnabled,
                          (value) {
                        SoundService().playClick();
                        notifier.setSound(value);
                      },
                      fontSize,
                    ),
                    _buildSettingItem(
                      'Background Music',
                      Icons.music_note,
                      settings.musicEnabled,
                          (value) {
                        SoundService().playClick();
                        notifier.setMusic(value);
                      },
                      fontSize,
                    ),
                    _buildSettingItem(
                      'Vibration',
                      Icons.vibration,
                      settings.vibrationEnabled,
                          (value) {
                        SoundService().playClick();
                        notifier.setVibration(value);
                      },
                      fontSize,
                    ),

                    const SizedBox(height: 30),

                    // NOTIFICATIONS
                    Text(
                      'NOTIFICATIONS',
                      style: TextStyle(
                        color: AppColors.neonRed,
                        fontSize: 16.0 * fontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildSettingItem(
                      'Game Notifications',
                      Icons.notifications,
                      settings.notificationsEnabled, // Ensure this matches the class above
                          (value) {
                        SoundService().playClick();
                        notifier.setNotifications(value);
                      },
                      fontSize,
                    ),

                    const SizedBox(height: 30),

                    // DISPLAY SETTINGS
                    Text(
                      'DISPLAY SETTINGS',
                      style: TextStyle(
                        color: AppColors.neonRed,
                        fontSize: 16.0 * fontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Theme Selection
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neonRed.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.0 * fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildThemeOption(
                                'Dark',
                                settings.theme == 'dark',
                                    () {
                                  SoundService().playClick();
                                  notifier.setTheme('dark');
                                },
                                fontSize,
                              ),
                              const SizedBox(width: 10),
                              _buildThemeOption(
                                'Light',
                                settings.theme == 'light',
                                    () {
                                  SoundService().playClick();
                                  notifier.setTheme('light');
                                },
                                fontSize,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Font Size Slider
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neonRed.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Font Size',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.0 * fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Slider(
                            value: settings.fontSize,
                            min: 0.8,
                            max: 1.5,
                            divisions: 7,
                            onChanged: (value) {
                              notifier.setFontSize(value);
                            },
                            activeColor: AppColors.neonRed,
                            inactiveColor: AppColors.darkGray,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Small',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12 * 0.8,
                                ),
                              ),
                              Text(
                                'Medium',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Large',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16 * 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // DATA & ANALYTICS
                    Text(
                      'DATA & ANALYTICS',
                      style: TextStyle(
                        color: AppColors.neonRed,
                        fontSize: 16.0 * fontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildActionItem(
                      'View Statistics',
                      Icons.bar_chart,
                          () {
                        SoundService().playClick();
                        context.push('/statistics');
                      },
                      fontSize,
                    ),
                    _buildActionItem(
                      'Test Sounds',
                      Icons.volume_up,
                          () {
                        SoundService().playClick();
                        _showSoundTestDialog(context, fontSize);
                      },
                      fontSize,
                    ),
                    _buildActionItem(
                      'Clear Cache',
                      Icons.delete,
                          () {
                        SoundService().playClick();
                        _showClearCacheDialog(context, fontSize);
                      },
                      fontSize,
                    ),

                    const SizedBox(height: 30),

                    // LEGAL & SUPPORT
                    Text(
                      'LEGAL & SUPPORT',
                      style: TextStyle(
                        color: AppColors.neonRed,
                        fontSize: 16.0 * fontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildActionItem(
                      'Privacy Policy',
                      Icons.privacy_tip,
                          () {
                        SoundService().playClick();
                        context.push('/legal/privacy');
                      },
                      fontSize,
                    ),
                    _buildActionItem(
                      'Terms & Conditions',
                      Icons.description,
                          () {
                        SoundService().playClick();
                        context.push('/legal/terms');
                      },
                      fontSize,
                    ),
                    _buildActionItem(
                      'About',
                      Icons.info,
                          () {
                        SoundService().playClick();
                        _showAboutDialog(context, fontSize);
                      },
                      fontSize,
                    ),

                    const SizedBox(height: 40),

                    // Reset to Defaults Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          SoundService().playClick();
                          _showResetDefaultsDialog(context, fontSize, notifier);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'RESET TO DEFAULTS',
                          style: TextStyle(
                            fontSize: 16.0 * fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          SoundService().playSuccess();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Settings saved!',
                                style: TextStyle(fontSize: 14.0 * fontSize),
                              ),
                              backgroundColor: AppColors.neonGreen,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonRed,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'SAVE SETTINGS',
                          style: TextStyle(
                            fontSize: 16.0 * fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
      String title,
      IconData icon,
      bool value,
      Function(bool) onChanged,
      double fontSize,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.darkGray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonRed, size: 20 * fontSize),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14 * fontSize,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.neonRed,
            activeTrackColor: AppColors.neonRed.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String label, bool isSelected, VoidCallback onTap, double fontSize) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12 * fontSize),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neonRed : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.neonRed : AppColors.textSecondary,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 14 * fontSize,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(String title, IconData icon, VoidCallback onTap, double fontSize) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.darkGray,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.neonRed, size: 20 * fontSize),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14 * fontSize,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16 * fontSize,
            ),
          ],
        ),
      ),
    );
  }

  void _showSoundTestDialog(BuildContext context, double fontSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neonBlue, width: 2),
        ),
        title: Text(
          'TEST SOUNDS',
          style: TextStyle(
            color: AppColors.neonBlue,
            fontSize: 18 * fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSoundTestButton('Click Sound', SoundService().playClick, fontSize),
            const SizedBox(height: 10),
            _buildSoundTestButton('Success', SoundService().playSuccess, fontSize),
            const SizedBox(height: 10),
            _buildSoundTestButton('Failure', SoundService().playFailure, fontSize),
            const SizedBox(height: 10),
            _buildSoundTestButton('Notification', SoundService().playNotification, fontSize),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              SoundService().playClick();
              Navigator.pop(context);
            },
            child: Text(
              'CLOSE',
              style: TextStyle(
                color: AppColors.neonBlue,
                fontSize: 14 * fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundTestButton(String label, VoidCallback onTap, double fontSize) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkestGray,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.neonBlue),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.neonBlue,
          fontSize: 14 * fontSize,
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, double fontSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neonBlue, width: 2),
        ),
        title: Text(
          'CLEAR CACHE',
          style: TextStyle(
            color: AppColors.neonBlue,
            fontSize: 18 * fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Clear all cached data? This will not affect your game progress.',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14 * fontSize,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              SoundService().playClick();
              Navigator.pop(context);
            },
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14 * fontSize,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              SoundService().playSuccess();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Cache cleared!',
                    style: TextStyle(fontSize: 14 * fontSize),
                  ),
                  backgroundColor: AppColors.neonGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonBlue,
            ),
            child: Text(
              'CLEAR',
              style: TextStyle(fontSize: 14 * fontSize),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDefaultsDialog(BuildContext context, double fontSize, SettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neonOrange, width: 2),
        ),
        title: Text(
          'RESET TO DEFAULTS',
          style: TextStyle(
            color: AppColors.neonOrange,
            fontSize: 18 * fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Reset all settings to default values?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14 * fontSize,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              SoundService().playClick();
              Navigator.pop(context);
            },
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14 * fontSize,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.resetToDefaults();
              SoundService().playSuccess();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Settings reset!',
                    style: TextStyle(fontSize: 14 * fontSize),
                  ),
                  backgroundColor: AppColors.neonGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonOrange,
            ),
            child: Text(
              'RESET',
              style: TextStyle(fontSize: 14 * fontSize),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, double fontSize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.neonBlue, width: 2),
        ),
        title: Text(
          'ABOUT CASE ZERO',
          style: TextStyle(
            color: AppColors.neonBlue,
            fontSize: 18 * fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Version: 1.0.0\n\nAn immersive detective game with crime investigation, clue collection, and puzzle solving.',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14 * fontSize,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              SoundService().playClick();
              Navigator.pop(context);
            },
            child: Text(
              'CLOSE',
              style: TextStyle(
                color: AppColors.neonBlue,
                fontSize: 14 * fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}