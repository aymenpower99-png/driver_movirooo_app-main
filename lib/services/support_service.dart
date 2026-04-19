import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/models/ticket_model.dart';

/// Service layer for the support-ticket API.
class SupportService {
  final _dio = ApiClient.instance.dio;

  /// Creates a new support ticket.
  /// Returns the created [TicketModel].
  Future<TicketModel> createTicket({
    required String subject,
    required String description,
    required TicketCategory category,
    String? rideId,
    Map<String, dynamic>? metadata,
  }) async {
    final res = await _dio.post(Endpoints.tickets, data: {
      'subject':     subject,
      'description': description,
      'category':    category.apiValue,
      if (rideId   != null) 'rideId':   rideId,
      if (metadata != null) 'metadata': metadata,
    });
    return TicketModel.fromJson(res.data as Map<String, dynamic>);
  }

  /// Lists the driver's own tickets (paginated).
  Future<TicketListResult> listMyTickets({int page = 1, int limit = 20}) async {
    final res = await _dio.get(
      Endpoints.tickets,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data  = res.data as Map<String, dynamic>;
    final items = (data['data'] as List<dynamic>)
        .map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return TicketListResult(
      tickets: items,
      total:   (data['total'] as num?)?.toInt() ?? items.length,
      page:    (data['page']  as num?)?.toInt() ?? page,
    );
  }

  /// Fetches a single ticket with its messages.
  Future<TicketModel> getTicket(String id) async {
    final res = await _dio.get(Endpoints.ticket(id));
    return TicketModel.fromJson(res.data as Map<String, dynamic>);
  }

  /// Replies to a ticket.
  Future<TicketMessageModel> replyToTicket(String id, String body) async {
    final res = await _dio.post(Endpoints.ticketReply(id), data: {'body': body});
    return TicketMessageModel.fromJson(res.data as Map<String, dynamic>);
  }
}

class TicketListResult {
  final List<TicketModel> tickets;
  final int total;
  final int page;
  const TicketListResult({required this.tickets, required this.total, required this.page});
}
