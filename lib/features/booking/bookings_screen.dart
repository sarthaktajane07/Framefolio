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
    return Container(
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
              StatusChip(status: booking.status),
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
        ],
      ),
    );
  }
}
