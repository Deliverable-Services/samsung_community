import 'package:flutter/foundation.dart';

import '../../data/core/exceptions/app_exception.dart';
import '../../data/core/utils/result.dart';
import '../../data/models/event_model.dart';
import 'supabase_service.dart';

class EventService {
  Future<Result<List<EventModel>>> getEvents({
    EventType? eventType,
    bool? isPublished,
    int? limit,
    int? offset,
    String? searchQuery,
  }) async {
    try {
      var query = SupabaseService.client
          .from('events')
          .select()
          .isFilter('deleted_at', null)
          // Always fetch only live events
          .eq('event_type', EventType.liveEvent.toJson());

      if (isPublished != null) {
        query = query.eq('is_published', isPublished);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final searchTerm = '%${searchQuery.trim()}%';
        query = query.ilike('title', searchTerm);
      }

      var transformQuery = query.order('created_at', ascending: false);

      if (offset != null) {
        transformQuery = transformQuery.range(
          offset,
          offset + (limit ?? 20) - 1,
        );
      } else if (limit != null) {
        transformQuery = transformQuery.limit(limit);
      }

      final response = await transformQuery;

      final eventList = (response as List)
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(eventList);
    } catch (e) {
      debugPrint('Error in getEvents: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<List<EventModel>>> getUserEvents({
    required String userId,
    bool? isPublished,
    int? limit,
    int? offset,
    String? searchQuery,
  }) async {
    try {
      // Get event IDs from event_registrations where user has registered
      final registrationsResponse = await SupabaseService.client
          .from('event_registrations')
          .select('event_id')
          .eq('user_id', userId);

      if (registrationsResponse.isEmpty) {
        return const Success([]);
      }

      final eventIds = (registrationsResponse as List)
          .map((reg) => reg['event_id'] as String)
          .toList();

      // Build OR query for multiple event IDs
      if (eventIds.isEmpty) {
        return const Success([]);
      }

      // Build OR conditions for event IDs
      final orConditions = eventIds.map((id) => 'id.eq.$id').join(',');

      // Now get the events (only live events)
      var query = SupabaseService.client
          .from('events')
          .select()
          .or(orConditions)
          .isFilter('deleted_at', null)
          .eq('event_type', EventType.liveEvent.toJson());

      if (isPublished != null) {
        query = query.eq('is_published', isPublished);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final searchTerm = '%${searchQuery.trim()}%';
        query = query.ilike('title', searchTerm);
      }

      var transformQuery = query.order('created_at', ascending: false);

      if (offset != null) {
        transformQuery = transformQuery.range(
          offset,
          offset + (limit ?? 20) - 1,
        );
      } else if (limit != null) {
        transformQuery = transformQuery.limit(limit);
      }

      final response = await transformQuery;

      final eventList = (response as List)
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(eventList);
    } catch (e) {
      debugPrint('Error in getUserEvents: $e');
      return Failure(AppException.fromError(e).message);
    }
  }

  Future<Result<EventModel?>> getEventById(String id) async {
    try {
      final response = await SupabaseService.client
          .from('events')
          .select()
          .eq('id', id)
          .isFilter('deleted_at', null)
          .maybeSingle();

      if (response == null) {
        return const Success(null);
      }

      final event = EventModel.fromJson(response);
      return Success(event);
    } catch (e) {
      debugPrint('Error in getEventById: $e');
      return Failure(AppException.fromError(e).message);
    }
  }
}
