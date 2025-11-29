import 'package:flutter/material.dart';

class RangeProfileChart extends StatelessWidget {
  final List<double> bins;

  const RangeProfileChart({super.key, required this.bins});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bins.map((v) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              height: (v * 1.2).clamp(2, 140),
              decoration: BoxDecoration(
                color: const Color(0xFF2BE4DC),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
