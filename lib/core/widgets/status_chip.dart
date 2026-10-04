import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();

    Color bg;
    Color border;
    Color text;
    Color dot;

    if (lower == 'confirmed') {
      bg = const Color(0xFF0D2818);
      border = const Color(0xFF165B33);
      text = const Color(0xFF4EAE71);
      dot = const Color(0xFF2ECC71);
    } else if (lower == 'completed') {
      bg = const Color(0xFF0A2540);
      border = const Color(0xFF1E4976);
      text = const Color(0xFF64B5F6);
      dot = const Color(0xFF2196F3);
    } else if (lower == 'cancelled' || lower == 'canceled') {
      bg = const Color(0xFF2C0D11);
      border = const Color(0xFF5C1D24);
      text = const Color(0xFFE57373);
      dot = const Color(0xFFF44336);
    } else {
      // Pending default
      bg = const Color(0xFF2B210B);
      border = const Color(0xFF6B531C);
      text = const Color(0xFFE5C158);
      dot = const Color(0xFFFFC107);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.isEmpty ? 'Pending' : status[0].toUpperCase() + status.substring(1),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}
