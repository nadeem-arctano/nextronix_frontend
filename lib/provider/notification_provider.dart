import 'package:flutter/foundation.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _items = [];
  PaginationInfo? _pagination;
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  String? _typeFilter;
  bool? _isReadFilter;
  int _currentPage = 1;

  final NextronixRepository _repo = NextronixRepository();

  List<AppNotification> get items => _items;
  PaginationInfo? get pagination => _pagination;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get typeFilter => _typeFilter;
  bool? get isReadFilter => _isReadFilter;
  int get currentPage => _currentPage;

  Future<AlertErrorResponse?> loadStats() async {
    try {
      final response = await _repo.getNotificationStats();
      _unreadCount = response.data?.unread ?? 0;
      notifyListeners();
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> loadNotifications({int page = 1}) async {
    _isLoading = true;
    _error = null;
    _currentPage = page;
    notifyListeners();

    try {
      final response = await _repo.getNotifications(
        page: page,
        type: _typeFilter,
        isRead: _isReadFilter,
      );
      _items = response.data ?? [];
      _pagination = response.pagination;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load notifications';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _repo.markNotificationRead(id: id);
      _items = _items.map((n) {
        if (n.id == id) {
          return AppNotification(
            id: n.id,
            type: n.type,
            title: n.title,
            message: n.message,
            isRead: true,
            entityId: n.entityId,
            entityType: n.entityType,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
    } catch (e) {
      // ignore
    }
  }

  Future<void> markAllRead() async {
    try {
      await _repo.markAllNotificationsRead();
      _items = _items
          .map(
            (n) => AppNotification(
              id: n.id,
              type: n.type,
              title: n.title,
              message: n.message,
              isRead: true,
              entityId: n.entityId,
              entityType: n.entityType,
              createdAt: n.createdAt,
            ),
          )
          .toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      // ignore
    }
  }

  Future<void> remove(int id) async {
    try {
      await _repo.deleteNotification(id: id);
      _items.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      // ignore
    }
  }

  void setTypeFilter(String? value) {
    _typeFilter = value;
    loadNotifications();
  }

  void setReadFilter(bool? value) {
    _isReadFilter = value;
    loadNotifications();
  }
}
