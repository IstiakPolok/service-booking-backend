import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/token_storage.dart';
import '../../providers/ai_chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_view.dart';
import 'change_password_dialog.dart';
import 'edit_profile_dialog.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  void _showApiSettingsDialog(BuildContext context) {
    final controller = TextEditingController(text: ApiEndpoints.baseUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Backend API URL'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configure the backend endpoint for your environment (Emulator: 10.0.2.2, Physical device: LAN IP):',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'http://10.0.2.2:5000/api',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.text = ApiEndpoints.defaultBaseUrl;
              },
              child: const Text('Reset Default'),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final newUrl = controller.text.trim();
                if (newUrl.isNotEmpty) {
                  await TokenStorage.saveCustomBaseUrl(newUrl);
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('API URL updated to: $newUrl'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out of your account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                // 1. Close confirmation dialog
                Navigator.pop(dialogContext);

                // 2. Perform logout (clears token, cached user, and auth state)
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();

                // 3. Clear AI chat session for security
                if (context.mounted) {
                  Provider.of<AiChatProvider>(context, listen: false).clearChat();
                }

                // 4. Navigate cleanly to Login screen, removing all previous routes
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginView()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // User Avatar & Identity Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primary.withAlpha(30),
                    backgroundImage: user?.avatar != null ? NetworkImage(user!.avatar!) : null,
                    child: user?.avatar == null
                        ? const Icon(Icons.person, size: 44, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.phone!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Account: ${(user?.role ?? 'User').toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile Actions
            _buildSectionHeader('Account Settings'),
            const SizedBox(height: 10),

            _buildTile(
              icon: Icons.person_outline_rounded,
              title: 'Edit Personal Information',
              subtitle: 'Update your name, phone, and photo',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const EditProfileDialog(),
                );
              },
            ),
            _buildTile(
              icon: Icons.lock_outline_rounded,
              title: 'Change Password',
              subtitle: 'Update your account login password',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const ChangePasswordDialog(),
                );
              },
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Application & Network'),
            const SizedBox(height: 10),

            _buildTile(
              icon: Icons.dns_outlined,
              title: 'Backend API Endpoint',
              subtitle: ApiEndpoints.baseUrl,
              onTap: () => _showApiSettingsDialog(context),
            ),
            _buildTile(
              icon: Icons.info_outline_rounded,
              title: 'App Version',
              subtitle: '1.0.0 (Production Release)',
              onTap: null,
            ),

            const SizedBox(height: 28),

            // Sign out button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20)
            : null,
      ),
    );
  }
}
