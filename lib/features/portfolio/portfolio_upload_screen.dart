import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../models/photographer_model.dart';
import '../../services/storage_service.dart';
import '../../services/firestore_service.dart';

/// Portfolio Upload screen — only for authenticated photographers.
/// Uploads cover photo + portfolio images to Cloudinary, saves metadata to Firestore.
class PortfolioUploadScreen extends StatefulWidget {
  final String photographerUid;

  const PortfolioUploadScreen({super.key, this.photographerUid = ''});

  @override
  State<PortfolioUploadScreen> createState() => _PortfolioUploadScreenState();
}

class _PortfolioUploadScreenState extends State<PortfolioUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _bioController = TextEditingController();

  final _storageService = StorageService();
  final _firestoreService = FirestoreService();

  String _specialty = AppConstants.specialties.first;
  XFile? _coverImage;
  final List<XFile> _portfolioImages = [];

  bool _isUploading = false;
  int _uploadedCount = 0;
  int _totalToUpload = 0;
  String _uploadStatus = '';

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickCoverPhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 75,
    );
    if (file != null) setState(() => _coverImage = file);
  }

  Future<void> _pickPortfolioImages() async {
    final files = await _picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 75,
    );
    if (files.isNotEmpty) {
      setState(() => _portfolioImages.addAll(files));
    }
  }

  void _removePortfolioImage(int index) {
    setState(() => _portfolioImages.removeAt(index));
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    if (_coverImage == null) {
      _showError('Please select a cover photo.');
      return;
    }

    if (_portfolioImages.isEmpty) {
      _showError('Please add at least one portfolio image.');
      return;
    }

    final uid = widget.photographerUid.isNotEmpty
        ? widget.photographerUid
        : (FirebaseAuth.instance.currentUser?.uid ?? 'unknown');

    setState(() {
      _isUploading = true;
      _uploadedCount = 0;
      _totalToUpload = 1 + _portfolioImages.length;
      _uploadStatus = 'Uploading portfolio photos…';
    });

    try {
      final coverFuture = _storageService.uploadCoverPhoto(_coverImage!, uid);
      final portfolioFutures = _portfolioImages
          .map((img) => _storageService.uploadPortfolioImage(img, uid))
          .toList();

      final results = await Future.wait([coverFuture, ...portfolioFutures]);
      final coverUrl = results.first;
      final portfolioUrls = List<String>.from(results.sublist(1));

      setState(() {
        _uploadedCount = _totalToUpload;
        _uploadStatus = 'Saving to database…';
      });
      final model = PhotographerModel(
        photographerId: uid,
        name: _nameController.text.trim(),
        specialty: _specialty,
        coverPhotoUrl: coverUrl,
        startingPrice: double.parse(_priceController.text.trim()),
        bio: _bioController.text.trim(),
        portfolioImages: portfolioUrls,
        packages: AppConstants.packages,
      );
      await _firestoreService.savePhotographer(model);

      if (!mounted) return;
      _showSuccess();
    } catch (e) {
      if (!mounted) return;
      _showError('Upload failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(AppConstants.primaryColor), size: 28),
            const SizedBox(width: 10),
            Text(
              'Portfolio Live!',
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: Text(
          'Your photography portfolio is published and visible to clients.',
          style: GoogleFonts.plusJakartaSans(color: const Color(AppConstants.textMutedValue)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Portfolio')),
      body: _isUploading ? _buildUploadProgress() : _buildForm(),
    );
  }

  Widget _buildUploadProgress() {
    final progress = _totalToUpload > 0 ? _uploadedCount / _totalToUpload : 0.0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              size: 64,
              color: Color(AppConstants.primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              _uploadStatus,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF181B26),
              color: const Color(AppConstants.primaryColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 10),
            Text(
              '$_uploadedCount / $_totalToUpload uploaded',
              style: GoogleFonts.plusJakartaSans(color: const Color(AppConstants.textMutedValue)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressSteps(),
            const SizedBox(height: 24),

            _sectionLabel('Basic Information'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Photographer / Studio Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _specialty,
              decoration: const InputDecoration(
                labelText: 'Specialty Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: AppConstants.specialties
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _specialty = v);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Starting Price (₹)',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Price is required';
                if (double.tryParse(v.trim()) == null ||
                    double.parse(v.trim()) <= 0) {
                  return 'Enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _bioController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Bio / Story',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            _sectionLabel('Cover Photo'),
            const SizedBox(height: 12),
            _buildCoverPhotoPicker(),
            const SizedBox(height: 24),

            _sectionLabel('Portfolio Images'),
            const SizedBox(height: 12),
            if (_portfolioImages.isNotEmpty) _buildPortfolioPreview(),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _pickPortfolioImages,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                _portfolioImages.isEmpty
                    ? 'Add Portfolio Images'
                    : 'Add More Images',
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: _publish,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Publish Portfolio'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Row(
      children: [
        _ProgressStep(number: 1, label: 'Info', active: true),
        Expanded(
          child: Container(
            height: 2,
            color: const Color(AppConstants.primaryColor),
          ),
        ),
        _ProgressStep(number: 2, label: 'Photos', active: true),
        Expanded(
          child: Container(
            height: 2,
            color: const Color(AppConstants.primaryColor),
          ),
        ),
        _ProgressStep(number: 3, label: 'Publish', active: true),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.playfairDisplay(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _buildCoverPhotoPicker() {
    return GestureDetector(
      onTap: _pickCoverPhoto,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF181B26),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _coverImage != null
                ? const Color(AppConstants.primaryColor)
                : const Color(AppConstants.surfaceBorderValue),
            width: 1.5,
          ),
        ),
        child: _coverImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo_outlined,
                    size: 40,
                    color: Color(AppConstants.primaryColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap to select cover photo',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(AppConstants.textMutedValue),
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: kIsWeb
                    ? Image.network(_coverImage!.path, fit: BoxFit.cover,
                        width: double.infinity)
                    : Image.file(File(_coverImage!.path),
                        fit: BoxFit.cover, width: double.infinity),
              ),
      ),
    );
  }

  Widget _buildPortfolioPreview() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _portfolioImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final file = _portfolioImages[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: kIsWeb
                  ? Image.network(file.path, fit: BoxFit.cover)
                  : Image.file(File(file.path), fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removePortfolioImage(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final int number;
  final String label;
  final bool active;

  const _ProgressStep({
    required this.number,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? const Color(AppConstants.primaryColor) : const Color(0xFF181B26),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(AppConstants.primaryColor)),
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: GoogleFonts.plusJakartaSans(
              color: active ? const Color(0xFF0B0C10) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: const Color(AppConstants.primaryColor),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

