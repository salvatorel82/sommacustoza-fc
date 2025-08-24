import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AppProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isDarkMode = false;
  String _selectedLanguage = 'it';
  bool _notificationsEnabled = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  int get currentIndex => _currentIndex;
  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Navigation
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Theme
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // Language
  void setLanguage(String languageCode) {
    _selectedLanguage = languageCode;
    notifyListeners();
  }

  // Notifications
  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  // Loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Error handling
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Show error with automatic clearing
  void showError(String message, {Duration? duration}) {
    setError(message);
    if (duration != null) {
      Future.delayed(duration, () {
        if (_errorMessage == message) {
          clearError();
        }
      });
    }
  }

  // App lifecycle methods
  void onAppStart() {
    // Initialize app settings
    _loadSettings();
  }

  void onAppPause() {
    // Save current state
    _saveSettings();
  }

  Future<void> _loadSettings() async {
    // TODO: Load from database or shared preferences
    // This is a placeholder for loading saved settings
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    // TODO: Save to database or shared preferences
    // This is a placeholder for saving current settings
  }
}
