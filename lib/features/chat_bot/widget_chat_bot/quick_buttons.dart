
import 'package:flutter/material.dart';

class QuickButtons extends StatelessWidget {
  final Function(String) onTap;

  const QuickButtons({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> buttons = [
      {"text": "🩸 Bleeding.What to do?"},
      {"text": "🔥 Fire or burn.What to do?"},
      {"text": " Earthquake.What to do?"},
      {"text": "🚢 Flood.What to do?"},
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: buttons.map((item) {
        final buttonWidth = MediaQuery.of(context).size.width * 0.44;

        return SizedBox(
          width: buttonWidth,
          height: 60,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,

              side: BorderSide(color: Colors.grey.shade400, width: 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 2,
              shadowColor: Colors.black12,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () => onTap(item["text"]!),
            child: Text(
              item["text"]!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}