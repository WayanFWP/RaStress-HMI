import 'package:flutter/foundation.dart';

class PeakInfo {
  final int index;
  final double value;
  final double distance; // in meters

  PeakInfo({
    required this.index,
    required this.value,
    required this.distance,
  });
}

class RangeProfileAnalyzer {
  /// Detect multiple peaks in range profile
  /// Returns list of significant peaks
  static List<PeakInfo> detectPeaks(List<double> rangeProfile) {
    if (rangeProfile.isEmpty) return [];

    List<PeakInfo> peaks = [];
    
    // Find all local maxima
    for (int i = 1; i < rangeProfile.length - 1; i++) {
      // Check if this point is a local maximum
      if (rangeProfile[i] > rangeProfile[i - 1] && 
          rangeProfile[i] > rangeProfile[i + 1]) {
        
        // Calculate distance in meters (assuming 64 bins cover 0.3m to 2.5m)
        double distance = 0.3 + (i / 64.0) * 2.2;
        
        peaks.add(PeakInfo(
          index: i,
          value: rangeProfile[i],
          distance: distance,
        ));
      }
    }

    // Sort peaks by value (descending)
    peaks.sort((a, b) => b.value.compareTo(a.value));

    // Filter out weak peaks - only keep peaks that are at least 30% of the strongest peak
    if (peaks.isNotEmpty) {
      double threshold = peaks.first.value * 0.3;
      peaks = peaks.where((peak) => peak.value >= threshold).toList();
    }

    if (kDebugMode && peaks.length > 1) {
      print("Multiple peaks detected: ${peaks.length} significant peaks");
      for (var peak in peaks) {
        print("  Peak at ${peak.distance.toStringAsFixed(2)}m, strength: ${peak.value.toStringAsFixed(1)}");
      }
    }

    return peaks;
  }

  /// Check if multiple breathing sources are detected
  static bool hasMultipleSources(List<double> rangeProfile) {
    final peaks = detectPeaks(rangeProfile);
    
    // If we have more than one significant peak, multiple sources detected
    // Also ensure peaks are reasonably separated (at least 0.3m apart)
    if (peaks.length < 2) return false;

    // Check distance between peaks
    for (int i = 0; i < peaks.length - 1; i++) {
      for (int j = i + 1; j < peaks.length; j++) {
        double distance = (peaks[i].distance - peaks[j].distance).abs();
        if (distance >= 0.3) {
          // Two significant peaks with reasonable separation
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