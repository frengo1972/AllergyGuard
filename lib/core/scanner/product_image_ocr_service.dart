import 'dart:io';

import 'package:allergyguard/core/ocr/ocr_service.dart';
import 'package:allergyguard/domain/models/product.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ProductImageOcrResult {
  const ProductImageOcrResult({
    required this.candidate,
    required this.ocrResult,
  });

  final ProductImageCandidate candidate;
  final OcrResult ocrResult;
}

/// Scarica poche immagini Open Food Facts rilevanti e le passa all'OCR locale.
class ProductImageOcrService {
  ProductImageOcrService({
    required Dio dio,
    required OcrService ocrService,
  })  : _dio = dio,
        _ocrService = ocrService;

  final Dio _dio;
  final OcrService _ocrService;

  Future<List<ProductImageOcrResult>> processLabelImages(
    Product product, {
    int maxImages = 2,
    String? preferredLanguageCode,
  }) async {
    final candidates = _prioritizedCandidates(
      product.labelImageCandidates,
      preferredLanguageCode: preferredLanguageCode,
    ).take(maxImages).toList(growable: false);
    final results = <ProductImageOcrResult>[];

    for (var index = 0; index < candidates.length; index++) {
      final candidate = candidates[index];
      try {
        final imagePath = await _downloadImage(
          candidate.url,
          barcode: product.barcode,
          index: index,
        );
        final ocrResult = await _ocrService.processFile(imagePath);
        if (!ocrResult.isEmpty) {
          results.add(
            ProductImageOcrResult(
              candidate: candidate,
              ocrResult: ocrResult,
            ),
          );
        }
      } catch (_) {
        // OFF images are an accuracy boost, not a hard dependency.
      }
    }

    return results;
  }

  List<ProductImageCandidate> _prioritizedCandidates(
    List<ProductImageCandidate> candidates, {
    required String? preferredLanguageCode,
  }) {
    final sorted = candidates.toList();
    sorted.sort((left, right) {
      final typeCompare =
          _typePriority(left.type).compareTo(_typePriority(right.type));
      if (typeCompare != 0) return typeCompare;
      final languageCompare =
          _languagePriority(left, preferredLanguageCode).compareTo(
        _languagePriority(right, preferredLanguageCode),
      );
      if (languageCompare != 0) return languageCompare;
      final resolutionCompare = _resolutionPriority(left.url)
          .compareTo(_resolutionPriority(right.url));
      if (resolutionCompare != 0) return resolutionCompare;
      return left.url.length.compareTo(right.url.length);
    });
    return sorted;
  }

  int _typePriority(ProductImageType type) {
    return switch (type) {
      ProductImageType.ingredients => 0,
      ProductImageType.packaging => 1,
      ProductImageType.front => 2,
      ProductImageType.nutrition => 3,
    };
  }

  int _languagePriority(
    ProductImageCandidate candidate,
    String? preferredLanguageCode,
  ) {
    if (preferredLanguageCode == null || preferredLanguageCode.isEmpty) {
      return candidate.languageCode == null ? 1 : 0;
    }
    if (candidate.languageCode == preferredLanguageCode) return 0;
    if (candidate.languageCode == null) return 1;
    return 2;
  }

  int _resolutionPriority(String url) {
    if (url.contains('.400.jpg')) return 0;
    if (url.contains('.full.jpg')) return 1;
    if (url.endsWith('.jpg')) return 1;
    if (url.contains('.200.jpg')) return 2;
    if (url.contains('.100.jpg')) return 3;
    return 4;
  }

  Future<String> _downloadImage(
    String url, {
    required String barcode,
    required int index,
  }) async {
    final response = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Empty Open Food Facts image response');
    }

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/off_${_safeFilePart(barcode)}_$index.jpg',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  String _safeFilePart(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }
}
