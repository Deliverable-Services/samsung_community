import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/services/supabase_service.dart';

class AppLifecycleService extends GetxService with WidgetsBindingObserver {
  static AppLifecycleService get instance => Get.find<AppLifecycleService>();

  String? _currentUserId;
  bool _isInitialized = false;
  Timer? _heartbeatTimer;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _onlineThreshold = Duration(minutes: 5);

  Future<void> initialize() async {
    if (_isInitialized) return;

    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;

    final currentUser = SupabaseService.currentUser;
    if (currentUser != null) {
      _currentUserId = currentUser.id;
      await _setOnlineStatus(true);
      _startHeartbeat();
    }
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    _setOnlineStatus(true);
    _startHeartbeat();
  }

  void clearCurrentUserId() {
    if (_currentUserId != null) {
      _stopHeartbeat();
      _setOnlineStatus(false);
      _currentUserId = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (_currentUserId == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _setOnlineStatus(true);
        _startHeartbeat();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _stopHeartbeat();
        _setOnlineStatus(false);
        break;
    }
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    if (_currentUserId == null) return;

    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      _updateLastSeen();
    });
    _updateLastSeen();
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _updateLastSeen() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await SupabaseService.client
          .from('users')
          .update({
            'is_online': true,
            'last_seen_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      debugPrint('Error updating last seen: $e');
    }
  }

  Future<void> _setOnlineStatus(bool isOnline) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await SupabaseService.client
          .from('users')
          .update({
            'is_online': isOnline,
            if (!isOnline) 'last_seen_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      debugPrint('Error updating online status: $e');
    }
  }

  static bool isUserOnline(bool isOnline, DateTime? lastSeenAt) {
    if (!isOnline) return false;
    if (lastSeenAt == null) return false;

    final now = DateTime.now();
    final timeSinceLastSeen = now.difference(lastSeenAt);
    return timeSinceLastSeen <= _onlineThreshold;
  }

  @override
  void onClose() {
    _stopHeartbeat();
    WidgetsBinding.instance.removeObserver(this);
    final userId = _currentUserId;
    if (userId != null) {
      _setOnlineStatus(false);
    }
    super.onClose();
  }
}
