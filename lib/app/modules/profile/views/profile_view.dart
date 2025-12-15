import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Obx(() {
          final user = controller.user.value;

          if (user != null) {
            final displayName = user.displayName ??
                controller.userData['displayName'] ??
                "User";
            final email =
                user.email ?? controller.userData['email'] ?? "-";
            final photoURL = user.photoURL ??
                controller.userData['photoURL'];

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Anda login sebagai',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 80,
                  backgroundImage: (photoURL != null && photoURL.isNotEmpty)
                      ? NetworkImage(photoURL)
                      : null,
                  child: (photoURL == null || photoURL.isEmpty)
                      ? const Icon(Icons.person, size: 80)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                   '$displayName',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Text(
                  '$email',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: controller.signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ],
            );
          } else if (controller.userData.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Anda login dengan email: ${controller.userData['email']}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          } else {
            // Belum login → tampil tombol login Google
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle,
                    size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Silakan login untuk melihat profil',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.signInWithGoogle,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
