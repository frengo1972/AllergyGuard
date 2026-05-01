import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';
import 'package:allergyguard/data/remote/feedback_remote_repo.dart';

enum FeedbackSubmitOutcome {
  submitted,
  queued,
}

/// Gestisce invio remoto e fallback offline dei feedback analytics.
class FeedbackSubmissionService {
  FeedbackSubmissionService({
    required FeedbackRemoteRepository remoteRepository,
    LocalPreferencesService? preferences,
  })  : _remoteRepository = remoteRepository,
        _preferences = preferences ?? LocalPreferencesService();

  final FeedbackRemoteRepository _remoteRepository;
  final LocalPreferencesService _preferences;

  Future<FeedbackSubmitOutcome> submit({
    required FeedbackType type,
    String? resultLevel,
    bool? isCorrect,
    String? expectedLevel,
    String? productBarcode,
    List<String> allergenKeys = const <String>[],
    String? comment,
  }) async {
    final payload = await _buildPayload(
      type: type,
      resultLevel: resultLevel,
      isCorrect: isCorrect,
      expectedLevel: expectedLevel,
      productBarcode: productBarcode,
      allergenKeys: allergenKeys,
      comment: comment,
    );

    if (_remoteRepository.isConfigured) {
      final success = await _remoteRepository.submitPayload(payload);
      if (success) {
        await flushPending();
        return FeedbackSubmitOutcome.submitted;
      }
    }

    await _enqueuePayload(payload);
    return FeedbackSubmitOutcome.queued;
  }

  Future<int> flushPending() async {
    if (!_remoteRepository.isConfigured) return 0;

    final items = await _preferences.getPendingFeedbackJson();
    if (items.isEmpty) return 0;

    final remaining = <String>[];
    var flushed = 0;

    for (final rawItem in items) {
      try {
        final payload = Map<String, dynamic>.from(
          jsonDecode(rawItem) as Map,
        );
        final success = await _remoteRepository.submitPayload(payload);
        if (success) {
          flushed += 1;
        } else {
          remaining.add(rawItem);
        }
      } catch (_) {
        // Item corrotto: lo scartiamo per non bloccare tutta la coda.
      }
    }

    await _preferences.setPendingFeedbackJson(remaining);
    return flushed;
  }

  Future<void> _enqueuePayload(Map<String, dynamic> payload) async {
    final currentItems = await _preferences.getPendingFeedbackJson();
    final serialized = jsonEncode(payload);
    if (currentItems.contains(serialized)) {
      return;
    }

    await _preferences.setPendingFeedbackJson(
      <String>[serialized, ...currentItems].take(200).toList(),
    );
  }

  Future<Map<String, dynamic>> _buildPayload({
    required FeedbackType type,
    String? resultLevel,
    bool? isCorrect,
    String? expectedLevel,
    String? productBarcode,
    List<String> allergenKeys = const <String>[],
    String? comment,
  }) async {
    final deviceId = await _preferences.getOrCreateDeviceId();
    final languageCode = await _preferences.getInterfaceLanguage();
    final packageInfo = await PackageInfo.fromPlatform();
    final countryCode =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode ?? '';

    return <String, dynamic>{
      'device_id': deviceId,
      'feedback_type': type.apiValue,
      'result_level': resultLevel,
      'is_correct': isCorrect,
      'expected_level': expectedLevel,
      'product_barcode': productBarcode,
      'allergen_keys': allergenKeys,
      'comment': comment,
      'language_code': languageCode,
      'country_code': countryCode,
      'app_version': '${packageInfo.version}+${packageInfo.buildNumber}',
    };
  }
}
