import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/photographer_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'portfolio_upload_screen.dart';

class PortfolioManagementScreen extends StatelessWidget {
  const PortfolioManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final uid = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Portfolio',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_rounded, color: Color(AppConstants.primaryColor)),
            tooltip: 'Upload New Photo',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PortfolioUploadScreen(photographerUid: uid),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<PhotographerModel>>(
        stream: firestoreService.photographersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Loading portfolio items...');
          }

          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.error_outline_rounded,
              title: 'Error loading portfolio',
              description: snapshot.error.toString(),
            );
          }

          final allPhotographers = snapshot.data ?? [];
          final photographer = allPhotographers.firstWhere(
            (p) => p.photographerId == uid,
            orElse: () => allPhotographers.isNotEmpty
                ? allPhotographers.first
                : const PhotographerModel(
                    photographerId: '',
                    name: 'Portfolio',
                    specialty: '',
                    coverPhotoUrl: '',
                    startingPrice: 0,
                    bio: '',
                    portfolioImages: [],
                    packages: [],
                  ),
          );

          final images = photographer.portfolioImages;

          if (images.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.photo_library_outlined,
              title: 'Your portfolio is empty',
              description: 'Upload high-resolution photography to attract potential clients.',
              buttonText: '+ Upload Portfolio',
              onButtonPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PortfolioUploadScreen(photographerUid: uid),
                  ),
                );
              },
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 2;
              if (constraints.maxWidth >= 900) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth >= 600) {
                crossAxisCount = 3;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: images.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final imageUrl = images[index];
                  return _PortfolioImageTile(
                    imageUrl: imageUrl,
                    index: index + 1,
                    specialty: photographer.specialty,
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: isDark
                              ? const Color(AppConstants.cardColorValue)
                              : Colors.white,
                          title: Text(
                            'Remove Photo?',
                            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            'Are you sure you want to remove image #${index + 1} from your portfolio?',
                            style: GoogleFonts.plusJakartaSans(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Remove', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          final updatedList = List<String>.from(images)..removeAt(index);
                          final updatedModel = PhotographerModel(
                            photographerId: photographer.photographerId,
                            name: photographer.name,
                            specialty: photographer.specialty,
                            coverPhotoUrl: photographer.coverPhotoUrl,
                            startingPrice: photographer.startingPrice,
                            bio: photographer.bio,
                            portfolioImages: updatedList,
                            packages: photographer.packages,
                          );
                          await firestoreService.savePhotographer(updatedModel);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Photo removed successfully')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to remove photo: $e')),
                          );
                        }
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _PortfolioImageTile extends StatelessWidget {
  final String imageUrl;
  final int index;
  final String specialty;
  final VoidCallback onDelete;

  const _PortfolioImageTile({
    required this.imageUrl,
    required this.index,
    required this.specialty,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(AppConstants.cardColorValue)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(AppConstants.surfaceBorderValue)
              : Colors.grey.shade300,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Preview
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(AppConstants.primaryColor).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      specialty.isEmpty ? 'Photo #$index' : specialty,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(AppConstants.primaryColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info & Actions
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Portfolio Image #$index',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.redAccent,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
