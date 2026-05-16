import '../../core/utils/parsers.dart';

// ─── Tickets ──────────────────────────────────────────────────────────────────
class TicketListResponse {
  final bool? success;
  final String? message;
  final List<Ticket>? data;
  final PaginationInfo? pagination;

  TicketListResponse({this.success, this.message, this.data, this.pagination});

  factory TicketListResponse.fromJson(Map<String, dynamic> json) =>
      TicketListResponse(
        success: json['success'],
        message: json['message']?.toString(),
        data: json['data'] != null
            ? (json['data'] as List).map((e) => Ticket.fromJson(e)).toList()
            : null,
        pagination: json['pagination'] != null
            ? PaginationInfo.fromJson(json['pagination'])
            : null,
      );
}

class TicketDetailResponse {
  final bool? success;
  final TicketDetail? data;
  TicketDetailResponse({this.success, this.data});
  factory TicketDetailResponse.fromJson(Map<String, dynamic> json) =>
      TicketDetailResponse(
        success: json['success'],
        data: json['data'] != null ? TicketDetail.fromJson(json['data']) : null,
      );
}

class Ticket {
  final int id;
  final String ticketNumber;
  final int? userId;
  final String subject;
  final String? category;
  final String priority;
  final String status;
  final String? customerName;
  final String? customerEmail;
  final String? lastReplyAt;
  final String? createdAt;

  Ticket({
    this.id = 0,
    this.ticketNumber = '',
    this.userId,
    this.subject = '',
    this.category,
    this.priority = 'medium',
    this.status = 'open',
    this.customerName,
    this.customerEmail,
    this.lastReplyAt,
    this.createdAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    id: parseInt(json['id']),
    ticketNumber: json['ticketNumber']?.toString() ?? '',
    userId: json['userId'] != null ? parseInt(json['userId']) : null,
    subject: json['subject']?.toString() ?? '',
    category: json['category']?.toString(),
    priority: json['priority']?.toString() ?? 'medium',
    status: json['status']?.toString() ?? 'open',
    customerName: json['customerName']?.toString(),
    customerEmail: json['customerEmail']?.toString(),
    lastReplyAt: json['lastReplyAt']?.toString(),
    createdAt: json['createdAt']?.toString(),
  );
}

class TicketDetail extends Ticket {
  final String? customerMobile;
  final List<TicketMessage> messages;

  TicketDetail({
    super.id,
    super.ticketNumber,
    super.userId,
    super.subject,
    super.category,
    super.priority,
    super.status,
    super.customerName,
    super.customerEmail,
    super.lastReplyAt,
    super.createdAt,
    this.customerMobile,
    this.messages = const [],
  });

  factory TicketDetail.fromJson(Map<String, dynamic> json) => TicketDetail(
    id: parseInt(json['id']),
    ticketNumber: json['ticketNumber']?.toString() ?? '',
    userId: json['userId'] != null ? parseInt(json['userId']) : null,
    subject: json['subject']?.toString() ?? '',
    category: json['category']?.toString(),
    priority: json['priority']?.toString() ?? 'medium',
    status: json['status']?.toString() ?? 'open',
    customerName: json['customerName']?.toString(),
    customerEmail: json['customerEmail']?.toString(),
    customerMobile: json['customerMobile']?.toString(),
    lastReplyAt: json['lastReplyAt']?.toString(),
    createdAt: json['createdAt']?.toString(),
    messages: json['messages'] != null
        ? (json['messages'] as List)
              .map((e) => TicketMessage.fromJson(e))
              .toList()
        : [],
  );
}

class TicketMessage {
  final int id;
  final int ticketId;
  final String senderType;
  final String? senderName;
  final String message;
  final String? attachment;
  final String? createdAt;

  TicketMessage({
    this.id = 0,
    this.ticketId = 0,
    this.senderType = 'customer',
    this.senderName,
    this.message = '',
    this.attachment,
    this.createdAt,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) => TicketMessage(
    id: parseInt(json['id']),
    ticketId: parseInt(json['ticketId']),
    senderType: json['senderType']?.toString() ?? 'customer',
    senderName: json['senderName']?.toString(),
    message: json['message']?.toString() ?? '',
    attachment: json['attachment']?.toString(),
    createdAt: json['createdAt']?.toString(),
  );
}

class TicketStats {
  final int totalTickets;
  final int openTickets;
  final int pendingTickets;
  final int resolvedTickets;
  final int closedTickets;
  final int urgentTickets;

  TicketStats({
    this.totalTickets = 0,
    this.openTickets = 0,
    this.pendingTickets = 0,
    this.resolvedTickets = 0,
    this.closedTickets = 0,
    this.urgentTickets = 0,
  });

  factory TicketStats.fromJson(Map<String, dynamic> json) => TicketStats(
    totalTickets: parseInt(json['totalTickets']),
    openTickets: parseInt(json['openTickets']),
    pendingTickets: parseInt(json['pendingTickets']),
    resolvedTickets: parseInt(json['resolvedTickets']),
    closedTickets: parseInt(json['closedTickets']),
    urgentTickets: parseInt(json['urgentTickets']),
  );
}

class TicketStatsResponse {
  final TicketStats? data;
  TicketStatsResponse({this.data});
  factory TicketStatsResponse.fromJson(Map<String, dynamic> json) =>
      TicketStatsResponse(
        data: json['data'] != null ? TicketStats.fromJson(json['data']) : null,
      );
}

// ─── Contact messages ─────────────────────────────────────────────────────────
class ContactMessage {
  final int id;
  final String name;
  final String email;
  final String? mobile;
  final String? subject;
  final String message;
  final String status;
  final String? createdAt;

  ContactMessage({
    this.id = 0,
    this.name = '',
    this.email = '',
    this.mobile,
    this.subject,
    this.message = '',
    this.status = 'new',
    this.createdAt,
  });

  factory ContactMessage.fromJson(Map<String, dynamic> json) => ContactMessage(
    id: parseInt(json['id']),
    name: json['name']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    mobile: json['mobile']?.toString(),
    subject: json['subject']?.toString(),
    message: json['message']?.toString() ?? '',
    status: json['status']?.toString() ?? 'new',
    createdAt: json['createdAt']?.toString(),
  );
}

class ContactMessageListResponse {
  final List<ContactMessage>? data;
  final PaginationInfo? pagination;
  ContactMessageListResponse({this.data, this.pagination});
  factory ContactMessageListResponse.fromJson(Map<String, dynamic> json) =>
      ContactMessageListResponse(
        data: json['data'] != null
            ? (json['data'] as List)
                  .map((e) => ContactMessage.fromJson(e))
                  .toList()
            : null,
        pagination: json['pagination'] != null
            ? PaginationInfo.fromJson(json['pagination'])
            : null,
      );
}

// ─── Pagination ───────────────────────────────────────────────────────────────
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  PaginationInfo({
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.itemsPerPage = 10,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => PaginationInfo(
    currentPage: parseInt(json['currentPage'], defaultValue: 1),
    totalPages: parseInt(json['totalPages'], defaultValue: 1),
    totalItems: parseInt(json['totalItems']),
    itemsPerPage: parseInt(json['itemsPerPage'], defaultValue: 10),
  );
}
