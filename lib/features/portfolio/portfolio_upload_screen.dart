import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  const PortfolioUploadScreen({super.key, required this.photographerUid});

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

  // ── Pick cover photo ───────────────────────────────────────────────────────
  Future<void> _pickCoverPhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) setState(() => _coverImage = file);
  }

  // ── Pick portfolio images ──────────────────────────────────────────────────
  Future<void> _pickPortfolioImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 80);
    if (files.isNotEmpty) {
      setState(() => _portfolioImages.addAll(files));
    }
  }

  void _removePortfolioImage(int index) {
    setState(() => _portfolioImages.removeAt(index));
  }

  // ── Upload and publish ─────────────────────────────────────────────────────
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
      _totalToUpload = 1 + _portfolioImages.length; // cover + portfolio
      _uploadStatus = 'Uploading cover photo…';
    });

    try {
      // 1. Upload cover photo
      final coverUrl = await _storageService.uploadCoverPhoto(_coverImage!, uid);
      setState(() {
        _uploadedCount = 1;
        _uploadStatus = 'Uploading portfolio images…';
      });

      // 2. Upload portfolio images sequentially (async/await)
      final List<String> portfolioUrls = [];
      for (int i = 0; i < _portfolioImages.length; i++) {
        final url = await _storageService.uploadPortfolioImage(
          _portfolioImages[i],
          uid,
        );
        portfolioUrls.add(url);
        setState(() {
          _uploadedCount = i + 2;
          _uploadStatus =
              'Uploading image ${i + 1} of ${_portfolioImages.length}…';
        });
      }

      // 3. Save to Firestore
      setState(() => _uploadStatus = 'Saving to database…');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('Portfolio Published!'),
          ],
        ),
        content: const Text(
          'Your portfolio is now live and visible to clients.',
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

  // ── Upload progress UI ─────────────────────────────────────────────────────
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
              color: Color(AppConstants.accentColor),
            ),
            const SizedBox(height: 24),
            Text(
              _uploadStatus,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(AppConstants.primaryColor),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: const Color(AppConstants.accentColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 10),
            Text(
              '$_uploadedCount / $_totalToUpload uploaded',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ── Form UI ────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress cue
            _buildProgressSteps(),
            const SizedBox(height: 24),

            // ── Section: Basic Info ──────────────────────────────────
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
                labelText: 'Bio / About You',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // ── Section: Cover Photo ─────────────────────────────────
            _sectionLabel('Cover Photo'),
            const SizedBox(height: 12),
            _buildCoverPhotoPicker(),
            const SizedBox(height: 24),

            // ── Section: Portfolio Images ────────────────────────────
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

            // ── Publish button ───────────────────────────────────────
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
            color: const Color(AppConstants.accentColor),
          ),
        ),
        _ProgressStep(number: 2, label: 'Photos', active: true),
        Expanded(
          child: Container(height: 2, color: Colors.grey.shade300),
        ),
        _ProgressStep(number: 3, label: 'Publish', active: false),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Color(AppConstants.primaryColor),
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
          color: const Color(0xFFF0EBE3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _coverImage != null
                ? const Color(AppConstants.accentColor)
                : Colors.grey.shade300,
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
                    color: Color(AppConstants.accentColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap to select cover photo',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(11),
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
              borderRadius: BorderRadius.circular(8),
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
                    color: Colors.black54,
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
    final color = active
        ? const Color(AppConstants.accentColor)
        : Colors.grey.shade400;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? const Color(AppConstants.accentColor) : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              color: active ? Colors.white : Colors.grey.shade500,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: color)),
      ],
    );
  }
}
