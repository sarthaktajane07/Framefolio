import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../models/booking_model.dart';
import '../../services/firestore_service.dart';
import 'booking_confirmation_screen.dart';

/// Cinematic Editorial Booking screen with package cards, date selector, and form validation.
class BookingScreen extends StatefulWidget {
  final String photographerId;
  final String photographerName;

  const BookingScreen({
    super.key,
    required this.photographerId,
    required this.photographerName,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  String _selectedPackage = 'Standard';
  DateTime? _selectedDate;
  String? _selectedTimeSlot = '10:00 AM';
  bool _isSubmitting = false;

  final Map<String, Map<String, String>> _packageDetails = {
    'Basic': {
      'price': '₹10,000',
      'desc': 'Essential coverage',
      'duration': '2 Hours Shoot',
    },
    'Standard': {
      'price': '₹18,000',
      'desc': 'Extended coverage',
      'duration': '4 Hours Shoot',
    },
    'Premium': {
      'price': '₹30,000',
      'desc': 'Complete experience',
      'duration': 'Full Day Shoot',
    },
  };

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? tomorrow,
      firstDate: tomorrow,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(AppConstants.primaryColor),
              onPrimary: Color(AppConstants.backgroundColorValue),
              surface: Color(AppConstants.cardElevatedValue),
              onSurface: Color(AppConstants.textPrimaryValue),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      _showError('Please select a session date.');
      return;
    }
    if (_selectedTimeSlot == null) {
      _showError('Please select a time slot.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final clientId = user?.uid ?? 'anonymous';

      final booking = BookingModel(
        bookingId: '',
        clientId: clientId,
        photographerId: widget.photographerId,
        photographerName: widget.photographerName,
        clientName: _nameController.text.trim(),
        clientEmail: _emailController.text.trim(),
        clientPhone: _phoneController.text.trim(),
        packageName: _selectedPackage,
        bookingDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        timeSlot: _selectedTimeSlot!,
        message: _messageController.text.trim(),
        status: 'pending',
      );

      final bookingId = await _firestoreService.saveBooking(booking);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            bookingId: bookingId,
            photographerName: widget.photographerName,
            packageName: _selectedPackage,
            bookingDate: _selectedDate!,
            timeSlot: _selectedTimeSlot!,
          ),
        ),
      );
    } catch (e) {
      _showError('Booking failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColorValue),
      appBar: AppBar(
        title: Text(
          'Book Your Session',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Photographer Preview Summary (Requirement 15) ──────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.cardColorValue),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(AppConstants.surfaceBorderValue)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(AppConstants.secondaryBgValue),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(AppConstants.surfaceBorderValue)),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Color(AppConstants.primaryColor),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.photographerName,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(AppConstants.textPrimaryValue),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Professional Photography Session',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(AppConstants.textMutedValue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Client Details Section (Requirement 16) ────────────────
              _fieldLabel('CLIENT NAME'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.plusJakartaSans(color: const Color(AppConstants.textPrimaryValue)),
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 18),

              _fieldLabel('EMAIL ADDRESS'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.plusJakartaSans(color: const Color(AppConstants.textPrimaryValue)),
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter your email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              _fieldLabel('PHONE NUMBER'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.plusJakartaSans(color: const Color(AppConstants.textPrimaryValue)),
                decoration: const InputDecoration(
                  hintText: 'Enter phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone number is required';
                  if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(v.trim())) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // ── Package Selector Cards (Requirement 17) ────────────────
              _fieldLabel('SELECT EXPERIENCE PACKAGE'),
              const SizedBox(height: 12),
              _buildPackageCards(),
              const SizedBox(height: 28),

              // ── Date & Time Selector (Requirement 18) ──────────────────
              _fieldLabel('CHOOSE YOUR DATE & TIME'),
              const SizedBox(height: 12),

              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.cardColorValue),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedDate != null
                          ? const Color(AppConstants.primaryColor)
                          : const Color(AppConstants.surfaceBorderValue),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(AppConstants.primaryColor),
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedDate == null ? 'SELECT DATE' : DateFormat('dd MMMM yyyy').format(_selectedDate!).toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(AppConstants.primaryColor),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedDate == null
                                  ? 'Tap to pick session date'
                                  : DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!),
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(AppConstants.textPrimaryValue),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Color(AppConstants.primaryColor)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time slot selector
              Text(
                'PREFERRED TIME SLOT',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(AppConstants.textMutedValue),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.timeSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  return ChoiceChip(
                    label: Text(slot),
                    selected: isSelected,
                    selectedColor: const Color(AppConstants.textPrimaryValue),
                    backgroundColor: const Color(AppConstants.cardColorValue),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      color: isSelected
                          ? const Color(AppConstants.backgroundColorValue)
                          : const Color(AppConstants.textSecondaryValue),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(AppConstants.textPrimaryValue)
                          : const Color(AppConstants.surfaceBorderValue),
                    ),
                    onSelected: (_) => setState(() => _selectedTimeSlot = slot),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Additional Message Field
              _fieldLabel('ADDITIONAL MESSAGE'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                style: GoogleFonts.plusJakartaSans(color: const Color(AppConstants.textPrimaryValue)),
                decoration: const InputDecoration(
                  hintText: 'Describe your vision, shoot location, or special requests…',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 36),

              // Primary CTA Button (Requirement 19)
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.textPrimaryValue),
                  foregroundColor: const Color(AppConstants.backgroundColorValue),
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Color(AppConstants.backgroundColorValue),
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'CONFIRM BOOKING',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCards() {
    return Column(
      children: AppConstants.packages.map((pkg) {
        final isSelected = _selectedPackage == pkg;
        final details = _packageDetails[pkg] ?? {
          'price': '₹15,000',
          'desc': 'Coverage package',
          'duration': 'Standard shoot',
        };

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => setState(() => _selectedPackage = pkg),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(AppConstants.primaryColor).withValues(alpha: 0.12)
                    : const Color(AppConstants.cardColorValue),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(AppConstants.primaryColor)
                      : const Color(AppConstants.surfaceBorderValue),
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(AppConstants.primaryColor)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? const Color(AppConstants.primaryColor)
                            : const Color(AppConstants.textMutedValue),
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Color(AppConstants.backgroundColorValue),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pkg.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(AppConstants.textPrimaryValue),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${details['desc']} • ${details['duration']}',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(AppConstants.textMutedValue),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    details['price']!,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(AppConstants.primaryColor),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 1.8,
          color: const Color(AppConstants.primaryColor),
        ),
      );
}
