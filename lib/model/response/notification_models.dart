import '../../core/utils/parsers.dart';
import 'support_models.dart' show PaginationInfo;

class AppNotification {
  final int id;
  final String type;
  final String title;
  final String? message;
  final bool isRead;
  final int? entityId;
  final String? entityType;
  final String? createdAt;

  AppNotification({
    this.id = 0,
    this.type = '',
    this.title = '',
    this.message,
    this.isRead = false,
    this.entityId,
    this.entityType,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: parseInt(json['id']),
        type: json['type']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        message: json['message']?.toString(),
        isRead: parseBool(json['isRead']),
        entityId: json['entityId'] != null ? parseInt(json['entityId']) : null,
        entityType: json['entityType']?.toString(),
        createdAt: json['createdAt']?.toString(),
      );
}

class NotificationListResponse {
  final List<AppNotification>? data;
  final PaginationInfo? pagination;
  NotificationListResponse({this.data, this.pagination});
  factory NotificationListResponse.fromJson(Map<String, dynamic> json) =>
      NotificationListResponse(
        data: json['data'] != null
            ? (json['data'] as List)
                  .map((e) => AppNotification.fromJson(e))
                  .toList()
            : null,
        pagination: json['pagination'] != null
            ? PaginationInfo.fromJson(json['pagination'])
            : null,
      );
}

class NotificationStats {
  final int unread;
  final int total;

  NotificationStats({this.unread = 0, this.total = 0});

  factory NotificationStats.fromJson(Map<String, dynamic> json) =>
      NotificationStats(
        unread: parseInt(json['unread']),
        total: parseInt(json['total']),
      );
}

class NotificationStatsResponse {
  final NotificationStats? data;
  NotificationStatsResponse({this.data});
  factory NotificationStatsResponse.fromJson(Map<String, dynamic> json) =>
      NotificationStatsResponse(
        data: json['data'] != null
            ? NotificationStats.fromJson(json['data'])
            : null,
      );
}
