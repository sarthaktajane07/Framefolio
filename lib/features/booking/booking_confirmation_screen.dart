import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../browse/browse_screen.dart';

/// Booking Confirmation screen — shown after a booking is successfully saved.
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // ── Success icon ─────────────────────────────────────────
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Title ────────────────────────────────────────────────
              const Text(
                '✓ Booking Confirmed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(AppConstants.primaryColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your session has been successfully booked. '
                'The photographer will reach out to confirm.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 32),

              // ── Booking details card ─────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Details',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(AppConstants.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Booking ID',
                        value: bookingId.length > 12
                            ? '…${bookingId.substring(bookingId.length - 12)}'
                            : bookingId,
                      ),
                      _DetailRow(
                        icon: Icons.camera_alt_outlined,
                        label: 'Photographer',
                        value: photographerName,
                      ),
                      _DetailRow(
                        icon: Icons.card_membership_outlined,
                        label: 'Package',
                        value: '$packageName Package',
                      ),
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: DateFormat('EEEE, dd MMMM yyyy').format(bookingDate),
                      ),
                      _DetailRow(
                        icon: Icons.access_time_outlined,
                        label: 'Time',
                        value: timeSlot,
                      ),
                      _DetailRow(
                        icon: Icons.pending_outlined,
                        label: 'Status',
                        value: 'Pending',
                        valueColor: const Color(0xFFF57C00),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ── Back to Home button ──────────────────────────────────
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const BrowseScreen(),
                  ),
                  (route) => false,
                ),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Back to Home'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('View Photographer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(AppConstants.accentColor)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: valueColor ?? const Color(AppConstants.primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
