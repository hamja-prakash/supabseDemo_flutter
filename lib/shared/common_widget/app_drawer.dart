import 'package:flutter/material.dart';
import 'package:supabase_demo/auth/login/view/login_screen.dart';
import 'package:supabase_demo/helper/appconstant.dart';
import 'package:supabase_demo/profile/view/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _supabase = Supabase.instance.client;
  String? _avatarUrl;
  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        _email = user.email ?? '';
        final data = await _supabase
            .from(AppConstants.profilesTable)
            .select()
            .eq(AppConstants.idKey, user.id)
            .maybeSingle();

        if (data != null) {
          setState(() {
            _name = (data[AppConstants.nameKey] ?? '') as String;
             _avatarUrl = (data[AppConstants.profilePicKey] ?? '') as String?;
          });
        }
      }
    } catch (_) {
      // Handle error silently or log
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _supabase.auth.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:  Column(
          children: [
            SizedBox(
              height: 250,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  _avatarUrl!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person, size: 40, color: Colors.grey),
                                ),
                              )
                            : const Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _name.isNotEmpty ? _name : 'Guest',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(AppConstants.logout),
              onTap: () => _logout(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
    );
  }
}
