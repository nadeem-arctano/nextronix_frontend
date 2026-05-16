import 'package:flutter/foundation.dart';

import '../model/response/response.dart';
import '../repository/nextronix_repository.dart';

class SupportProvider extends ChangeNotifier {
  List<Ticket> _tickets = [];
  TicketDetail? _selectedTicket;
  TicketStats? _stats;
  PaginationInfo? _pagination;
  bool _isLoading = false;
  bool _isReplying = false;
  String? _error;

  String? _statusFilter;
  String? _priorityFilter;
  String? _search;
  int _currentPage = 1;

  // Contact messages
  List<ContactMessage> _contactMessages = [];
  PaginationInfo? _contactPagination;
  bool _isLoadingContact = false;

  final NextronixRepository _repo = NextronixRepository();

  List<Ticket> get tickets => _tickets;
  TicketDetail? get selectedTicket => _selectedTicket;
  TicketStats? get stats => _stats;
  PaginationInfo? get pagination => _pagination;
  bool get isLoading => _isLoading;
  bool get isReplying => _isReplying;
  String? get error => _error;
  String? get statusFilter => _statusFilter;
  String? get priorityFilter => _priorityFilter;
  String? get search => _search;
  int get currentPage => _currentPage;

  List<ContactMessage> get contactMessages => _contactMessages;
  PaginationInfo? get contactPagination => _contactPagination;
  bool get isLoadingContact => _isLoadingContact;

  // ─── Tickets list ───────────────────────────────────────────────────────────
  Future<AlertErrorResponse?> loadTickets({int page = 1}) async {
    _isLoading = true;
    _error = null;
    _currentPage = page;
    notifyListeners();

    try {
      final response = await _repo.getTickets(
        page: page,
        status: _statusFilter,
        priority: _priorityFilter,
        search: _search,
      );
      _tickets = response.data ?? [];
      _pagination = response.pagination;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load tickets';
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> loadStats() async {
    try {
      final response = await _repo.getTicketStats();
      _stats = response.data;
      notifyListeners();
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> loadTicketById(int id) async {
    _isLoading = true;
    _selectedTicket = null;
    notifyListeners();
    try {
      final response = await _repo.getTicketById(id: id);
      _selectedTicket = response.data;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> reply(int ticketId, String message) async {
    _isReplying = true;
    notifyListeners();
    try {
      await _repo.replyToTicket(id: ticketId, message: message);
      await loadTicketById(ticketId);
      _isReplying = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isReplying = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updateStatus(int ticketId, String status) async {
    try {
      await _repo.updateTicketStatus(id: ticketId, status: status);
      await loadTicketById(ticketId);
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<AlertErrorResponse?> updatePriority(
    int ticketId,
    String priority,
  ) async {
    try {
      await _repo.updateTicketPriority(id: ticketId, priority: priority);
      await loadTicketById(ticketId);
      return null;
    } catch (e) {
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  void setStatusFilter(String? value) {
    _statusFilter = value;
    loadTickets();
  }

  void setPriorityFilter(String? value) {
    _priorityFilter = value;
    loadTickets();
  }

  void setSearch(String? value) {
    _search = value;
    loadTickets();
  }

  // ─── Contact messages ───────────────────────────────────────────────────────
  Future<AlertErrorResponse?> loadContactMessages({int page = 1}) async {
    _isLoadingContact = true;
    notifyListeners();
    try {
      final response = await _repo.getContactMessages(page: page);
      _contactMessages = response.data ?? [];
      _contactPagination = response.pagination;
      _isLoadingContact = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoadingContact = false;
      notifyListeners();
      return AlertErrorResponse.getErrorResponse(e);
    }
  }

  Future<void> markContactStatus(int id, String status) async {
    try {
      await _repo.updateContactMessageStatus(id: id, status: status);
      await loadContactMessages();
    } catch (e) {
      // ignore
    }
  }
}
