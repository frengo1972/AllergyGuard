import 'dart:convert';

import 'package:allergyguard/data/feedback/feedback_submission_service.dart';
import 'package:allergyguard/data/local/local_preferences_service.dart';
import 'package:allergyguard/data/remote/feedback_remote_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeFeedbackRemoteRepository extends FeedbackRemoteRepository {
  _FakeFeedbackRemoteRepository({
    required this.configured,
    required this.shouldSucceed,
  }) : super(client: null);

  final bool configured;
  bool shouldSucceed;
  final List<Map<String, dynamic>> submittedPayloads = <Map<String, dynamic>>[];

  @override
  bool get isConfigured => configured;

  @override
  Future<bool> submitPayload(Map<String, dynamic> payload) async {
    submittedPayloads.add(Map<String, dynamic>.from(payload));
    return shouldSucceed;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PackageInfo.setMockInitialValues(
      appName: 'AllergyGuard',
      packageName: 'io.github.frengo1972.allergyguard',
      version: '1.2.3',
      buildNumber: '45',
      buildSignature: '',
    );
  });

  test('queues feedback locally when remote backend is unavailable', () async {
    final remoteRepository = _FakeFeedbackRemoteRepository(
      configured: false,
      shouldSucceed: false,
    );
    final preferences = LocalPreferencesService();
    final service = FeedbackSubmissionService(
      remoteRepository: remoteRepository,
      preferences: preferences,
    );

    final outcome = await service.submit(
      type: FeedbackType.scanAccuracy,
      resultLevel: 'danger',
      isCorrect: true,
      productBarcode: '12345',
      allergenKeys: const ['Sesamo'],
    );

    expect(outcome, FeedbackSubmitOutcome.queued);
    final pendingItems = await preferences.getPendingFeedbackJson();
    expect(pendingItems, hasLength(1));

    final payload = Map<String, dynamic>.from(
      jsonDecode(pendingItems.single) as Map,
    );
    expect(payload['feedback_type'], 'scan_accuracy');
    expect(payload['is_correct'], isTrue);
    expect(payload['product_barcode'], '12345');
  });

  test('flushPending sends queued feedback and clears local queue', () async {
    final remoteRepository = _FakeFeedbackRemoteRepository(
      configured: true,
      shouldSucceed: true,
    );
    final preferences = LocalPreferencesService();
    await preferences.setPendingFeedbackJson(<String>[
      jsonEncode(<String, dynamic>{
        'device_id': 'device-1',
        'feedback_type': 'scan_accuracy',
        'result_level': 'warning',
        'is_correct': false,
        'expected_level': 'danger',
        'product_barcode': '999',
        'allergen_keys': <String>['Soia'],
        'comment': 'match errato',
        'language_code': 'it',
        'country_code': 'IT',
        'app_version': '1.2.3+45',
      }),
    ]);
    final service = FeedbackSubmissionService(
      remoteRepository: remoteRepository,
      preferences: preferences,
    );

    final flushed = await service.flushPending();

    expect(flushed, 1);
    expect(remoteRepository.submittedPayloads, hasLength(1));
    expect(await preferences.getPendingFeedbackJson(), isEmpty);
  });
}
