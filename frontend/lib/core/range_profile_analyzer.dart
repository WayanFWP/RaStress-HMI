import 'package:flutter/foundation.dart';
import 'constants/app_constants.dart';

class PeakInfo {
  final int index;
  final double value;
  final double distance; // in meters

  PeakInfo({required this.index, required this.value, required this.distance});

  @override
  String toString() =>
      'PeakInfo(index: $index, distance: ${distance.toStringAsFixed(2)}m, value: ${value.toStringAsFixed(1)})';
}

class RangeProfileAnalyzer {
  /// Detect multiple peaks in range profile
  /// Returns list of significant peaks sorted by strength
  static List<PeakInfo> detectPeaks(List<double> rangeProfile) {
    if (rangeProfile.isEmpty) return [];

    final peaks = _findLocalMaxima(rangeProfile);
    final filteredPeaks = _filterWeakPeaks(peaks);

    _logPeaksIfDebug(filteredPeaks);

    return filteredPeaks;
  }

  /// Find all local maxima in the range profile
  static List<PeakInfo> _findLocalMaxima(List<double> rangeProfile) {
    final peaks = <PeakInfo>[];

    for (int i = 1; i < rangeProfile.length - 1; i++) {
      if (_isLocalMaximum(rangeProfile, i)) {
        peaks.add(_createPeakInfo(i, rangeProfile[i]));
      }
    }

    // Sort by value (descending - strongest first)
    peaks.sort((a, b) => b.value.compareTo(a.value));
    return peaks;
  }

  /// Check if a point is a local maximum
  static bool _isLocalMaximum(List<double> data, int index) {
    return data[index] > data[index - 1] && data[index] > data[index + 1];
  }

  /// Create PeakInfo with calculated distance
  static PeakInfo _createPeakInfo(int index, double value) {
    final distance =
        AppConstants.minDetectionRange +
        (index / AppConstants.rangeProfileBins) *
            AppConstants.detectionRangeCoverage;

    return PeakInfo(index: index, value: value, distance: distance);
  }

  /// Filter out weak peaks based on threshold ratio
  static List<PeakInfo> _filterWeakPeaks(List<PeakInfo> peaks) {
    if (peaks.isEmpty) return peaks;

    final threshold = peaks.first.value * AppConstants.peakThresholdRatio;
    return peaks.where((peak) => peak.value >= threshold).toList();
  }

  /// Log peaks in debug mode
  static void _logPeaksIfDebug(List<PeakInfo> peaks) {
    if (kDebugMode && peaks.length > 1) {
      debugPrint("Multiple peaks detected: ${peaks.length} significant peaks");
      for (final peak in peaks) {
        debugPrint("  $peak");
      }
    }
  }

  /// Check if multiple breathing sources are detected
  /// Returns true if multiple well-separated peaks are found
  static bool hasMultipleSources(List<double> rangeProfile) {
    final peaks = detectPeaks(rangeProfile);

    if (peaks.length < 2) return false;

    // Check if any pair of peaks is sufficiently separated
    return _hasSeparatedPeaks(peaks);
  }

  /// Check if peaks are reasonably separated
  static bool _hasSeparatedPeaks(List<PeakInfo> peaks) {
    for (int i = 0; i < peaks.length - 1; i++) {
      for (int j = i + 1; j < peaks.length; j++) {
        final distance = (peaks[i].distance - peaks[j].distance).abs();
        if (distance >= AppConstants.minimumPeakSeparation) {
          return true;
        }
      }
    }
    return false;
  }

  /// Get the number of detected sources
  static int getSourceCount(List<double> rangeProfile) {
    return detectPeaks(rangeProfile).length;
  }

  /// Get the primary (strongest) peak
  static PeakInfo? getPrimaryPeak(List<double> rangeProfile) {
    final peaks = detectPeaks(rangeProfile);
    return peaks.isNotEmpty ? peaks.first : null;
  }
}
