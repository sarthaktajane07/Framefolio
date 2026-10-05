import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

/// Cinematic Editorial Session Requests & Bookings Screen.
class BookingsScreen extends StatefulWidget {
  final bool isPhotographer;

  const BookingsScreen({super.key, this.isPhotographer = false});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  final List<String> _tabs = ['ALL', 'PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _authService.currentUser?.uid ?? '';
    final isPhotographer = widget.isPhotographer;

    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColorValue),
      appBar: AppBar(
        title: Text(
          isPhotographer ? 'Session Requests' : 'My Session Bookings',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(AppConstants.textPrimaryValue),
          unselectedLabelColor: const Color(AppConstants.textMutedValue),
          indicatorColor: const Color(AppConstants.primaryColor),
          indicatorWeight: 2,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: isPhotographer
            ? _firestoreService.photographerBookingsStream(uid)
            : _firestoreService.clientBookingsStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Loading session requests...');
          }

          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.error_outline_rounded,
              title: 'Error loading bookings',
              description: snapshot.error.toString(),
            );
          }

          final userBookings = snapshot.data ?? [];

          return TabBarView(
            controller: _tabController,
            children: _tabs.map((statusFilter) {
              final filtered = statusFilter == 'ALL'
                  ? userBookings
                  : userBookings
                      .where((b) => b.status.toUpperCase() == statusFilter)
                      .toList();

              if (filtered.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.event_busy_rounded,
                  title: 'No bookings found',
                  description: statusFilter == 'ALL'
                      ? 'You have no active session bookings.'
                      : 'No $statusFilter session bookings found.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final booking = filtered[index];
                  return _BookingCard(
                    booking: booking,
                    isPhotographer: isPhotographer,
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isPhotographer;

  const _BookingCard({
    required this.booking,
    required this.isPhotographer,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final cur = booking.status.toLowerCase();
        if (cur == 'pending') {
          _updateStatus(context, 'confirmed');
        } else {
          _showActionDialog(context);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(AppConstants.cardColorValue),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(AppConstants.surfaceBorderValue),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Client Name / Photographer Name & Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isPhotographer ? booking.clientName : booking.photographerName,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: const Color(AppConstants.textPrimaryValue),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusChip(
                status: booking.status,
                onTap: () {
                  final cur = booking.status.toLowerCase();
                  if (cur == 'pending') {
                    _updateStatus(context, 'confirmed');
                  } else if (cur == 'confirmed') {
                    _updateStatus(context, 'completed');
                  } else {
                    _showActionDialog(context);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(AppConstants.surfaceBorderValue)),
          const SizedBox(height: 10),

          // Details grid: Date & Package
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Color(AppConstants.primaryColor),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      booking.bookingDate.isNotEmpty ? booking.bookingDate : 'Date TBD',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(AppConstants.textSecondaryValue),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      size: 14,
                      color: Color(AppConstants.primaryColor),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${booking.packageName} Package',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(AppConstants.textSecondaryValue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (booking.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(AppConstants.secondaryBgValue),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(AppConstants.surfaceBorderValue)),
              ),
              child: Text(
                'Note: "${booking.message}"',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  color: const Color(AppConstants.textSecondaryValue),
                ),
              ),
            ),
          ],

          // Actions for session requests (Accept / Decline / Mark Completed)
          if (booking.status.toLowerCase() == 'pending') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(context, 'confirmed'),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                    label: Text(
                      'ACCEPT SESSION',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppConstants.primaryColor),
                      foregroundColor: const Color(AppConstants.backgroundColorValue),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _updateStatus(context, 'cancelled'),
                  icon: const Icon(Icons.close_rounded, size: 16, color: Colors.redAccent),
                  label: Text(
                    'DECLINE',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.redAccent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (booking.status.toLowerCase() == 'confirmed') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(context, 'completed'),
                    icon: const Icon(Icons.task_alt_rounded, size: 16),
                    label: Text(
                      'MARK COMPLETED',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _updateStatus(context, 'cancelled'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}

  void _showActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(AppConstants.cardColorValue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Manage Session Request',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(AppConstants.textPrimaryValue),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client: ${booking.clientName}',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(AppConstants.textPrimaryValue),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Package: ${booking.packageName}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(AppConstants.textSecondaryValue),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${booking.status.toUpperCase()}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(AppConstants.primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(AppConstants.surfaceBorderValue)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogCtx);
                _updateStatus(context, 'confirmed');
              },
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('ACCEPT SESSION (CONFIRM)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.primaryColor),
                foregroundColor: const Color(AppConstants.backgroundColorValue),
                minimumSize: const Size.fromHeight(44),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogCtx);
                _updateStatus(context, 'completed');
              },
              icon: const Icon(Icons.task_alt_rounded),
              label: const Text('MARK AS COMPLETED'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(dialogCtx);
                _updateStatus(context, 'cancelled');
              },
              icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
              label: const Text('DECLINE / CANCEL SESSION', style: TextStyle(color: Colors.redAccent)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    final firestore = FirestoreService();
    try {
      await firestore.updateBookingStatus(
        bookingId: booking.bookingId,
        status: newStatus,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session request ${newStatus == "confirmed" ? "Accepted!" : newStatus}'),
          backgroundColor: newStatus == 'confirmed'
              ? const Color(AppConstants.primaryColor)
              : newStatus == 'completed'
                  ? Colors.green.shade800
                  : Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
