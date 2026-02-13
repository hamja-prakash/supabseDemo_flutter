import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_demo/helper/appconstant.dart';
import 'package:supabase_demo/helper/assets_path.dart';
import 'package:supabase_demo/shared/common_widget/common_textfield.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  late Future<Map<String, dynamic>> _profileFuture;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _profileFuture = _getProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AuthException('User not logged in');
      }
      final userId = user.id;
      final data = await _supabase
          .from(AppConstants.profilesTable)
          .select('name, email, phone_number, profile_pic, address: addresses(*)')
          .eq(AppConstants.idKey, userId)
          .maybeSingle();

      if (data == null) {
        // Profile doesn't exist (likely new Google/Apple user)
        // Create a new profile using user metadata
        final metadata = user.userMetadata;
        final name = metadata?['full_name'] as String? ?? 'Guest';
        final email = user.email ?? '';
        final avatar = metadata?['avatar_url'] as String?;

        final newProfile = {
          AppConstants.idKey: userId,
          AppConstants.nameKey: name,
          AppConstants.emailKey: email,
          AppConstants.profilePicKey: avatar,
        };

        await _supabase.from(AppConstants.profilesTable).upsert(newProfile);

        // Return the new profile structure (with null/empty address)
        return {
          ...newProfile,
          'phone_number': null,
          AppConstants.addressKey: [], // Empty list for addresses
        };
      }
      return data;
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
      rethrow;
    } catch (error) {
      if (mounted) context.showSnackBar(AppConstants.somethingWentWrong, isError: true);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            _avatarUrl = (user[AppConstants.profilePicKey] ?? '') as String?;
            
            // Helper to safely get address fields
            String getAddressField(String key) {
              final addresses = user[AppConstants.addressKey] as List<dynamic>?;
              if (addresses != null && addresses.isNotEmpty) {
                return addresses[0][key]?.toString() ?? 'N/A';
              }
              return 'N/A';
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                        ? ClipOval(child: Image.network(_avatarUrl!, width: 100, height: 100, fit: BoxFit.cover))
                        : const Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: const Text(AppConstants.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    trailing: Text(user[AppConstants.nameKey] ?? 'N/A', style: const TextStyle(fontSize: 14)),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: const Text(AppConstants.email, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    trailing: Text(user[AppConstants.emailKey] ?? 'N/A', style: const TextStyle(fontSize: 14)),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: const Text(AppConstants.phoneNo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    trailing: Text(user[AppConstants.phoneNumberKey] ?? 'N/A', style: const TextStyle(fontSize: 14)),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: const Text(AppConstants.country, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    trailing: Text(getAddressField(AppConstants.countryKey), style: const TextStyle(fontSize: 14)),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: const Text(AppConstants.city, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    trailing: Text(getAddressField(AppConstants.cityKey), style: const TextStyle(fontSize: 14)),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: const Text(AppConstants.street, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    trailing: Text(getAddressField(AppConstants.streetKey), style: const TextStyle(fontSize: 14)),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: const Text(AppConstants.postalCode, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    trailing: Text(getAddressField(AppConstants.postalCodeKey), style: const TextStyle(fontSize: 14)),
                  ),

                        ],
                      ),
                    ),
                  ),
                  // const SizedBox(height: 16),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 8),
                  //   child: SizedBox(
                  //     width: double.infinity,
                  //     height: 50,
                  //     child: ElevatedButton(
                  //       // onPressed: _updateProfile,
                  //       onPressed: (){},
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.deepPurple,
                  //         foregroundColor: Colors.white,
                  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  //       ),
                  //       child: const Text('Update Profile'),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }
}

extension ShowSnackBar on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green));
  }
}
