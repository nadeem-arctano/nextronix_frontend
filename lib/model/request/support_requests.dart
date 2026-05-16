class TicketReplyRequest {
  final String? message;
  final String? senderType;
  final String? attachment;

  TicketReplyRequest({
    this.message,
    this.senderType = 'admin',
    this.attachment,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (message != null) map['message'] = message;
    if (senderType != null) map['senderType'] = senderType;
    if (attachment != null) map['attachment'] = attachment;
    return map;
  }
}

class PriorityRequest {
  final String? priority;
  PriorityRequest({this.priority});
  Map<String, dynamic> toJson() => {'priority': priority};
}
