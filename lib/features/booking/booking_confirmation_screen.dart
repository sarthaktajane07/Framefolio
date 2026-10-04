import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/status_chip.dart';
import '../home/home_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String bookingId;
  final String photographerName;
  final String packageName;
  final DateTime bookingDate;
  final String timeSlot;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.photographerName,
    required this.packageName,
    required this.bookingDate,
    required this.timeSlot,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMMM yyyy').format(bookingDate);

    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColorValue),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Minimal check icon badge
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(AppConstants.cardColorValue),
                    border: Border.all(
                      color: const Color(AppConstants.primaryColor).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 48,
                    color: Color(AppConstants.primaryColor),
                  ),
                ),
                const SizedBox(height: 28),

                // Title & Subtitle (Requirement 20)
                Text(
                  'Your story is booked.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(AppConstants.textPrimaryValue),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your session request has been sent to the photographer.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(AppConstants.textSecondaryValue),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),

                // Booking Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.cardColorValue),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(AppConstants.surfaceBorderValue),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('PHOTOGRAPHER', photographerName),
                      const Divider(height: 24, color: Color(AppConstants.surfaceBorderValue)),
                      _buildSummaryRow('DATE & TIME', '$formattedDate ($timeSlot)'),
                      const Divider(height: 24, color: Color(AppConstants.surfaceBorderValue)),
                      _buildSummaryRow('PACKAGE', '$packageName Package'),
                      const Divider(height: 24, color: Color(AppConstants.surfaceBorderValue)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'STATUS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: const Color(AppConstants.primaryColor),
                            ),
                          ),
                          const StatusChip(status: 'Pending'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Action Button (Requirement 20)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppConstants.textPrimaryValue),
                    foregroundColor: const Color(AppConstants.backgroundColorValue),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'BACK TO EXPLORE',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: const Color(AppConstants.primaryColor),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(AppConstants.textPrimaryValue),
            ),
          ),
        ),
      ],
    );
  }
}
