import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_demo/auth/login/view/login_screen.dart';
import 'package:supabase_demo/helper/appconstant.dart';
import 'package:supabase_demo/notes/add_notes/cubit/notes_cubit.dart';
import 'package:supabase_demo/notes/add_notes/cubit/notes_state.dart';
import 'package:supabase_demo/notes/add_notes/view/add_note_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helper/assets_path.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  Future<void> logout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NoteCubit()..fetchNotes(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppConstants.myNotes),
          centerTitle: true,
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: logout,
                  child: const Text(AppConstants.logout),
                ),
              ],
            )
          ],
        ),

        body: BlocConsumer<NoteCubit, NoteState>(
          listener: (context, state) {
            if (state is NoteError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
            if (state is NoteDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppConstants.noteDeleted), backgroundColor: Colors.green),
              );
            }
          },
          builder: (context, state) {
            if (state is NoteLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotesLoaded) {
              if (state.notes.isEmpty) {
                return const Center(child: Text(AppConstants.noNotesFound, style: TextStyle(fontWeight: .normal, fontSize: 20),));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.only(
                          right: 4, left: 16, top: 4, bottom: 4),
                      title: Text(note[AppConstants.titleKey] ?? ''),
                      subtitle: Text(note[AppConstants.descriptionKey] ?? ''),
                      leading: Image.asset(
                        AssetPath.bookLogo,
                        color: Colors.deepPurple,
                        width: 24,
                        height: 24,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              final cubit = context.read<NoteCubit>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: cubit,
                                    child: AddNoteScreen(note: note),
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              final cubit = context.read<NoteCubit>();
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(AppConstants.deleteNote),
                                  content: const Text(AppConstants.deleteConfirmation),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(AppConstants.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        cubit.deleteNote(note[AppConstants.idKey]);
                                      },
                                      child: const Text(AppConstants.delete, style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(child: Text(AppConstants.somethingWentWrong));
          },
        ),

        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
                final cubit = context.read<NoteCubit>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: cubit,
                      child: const AddNoteScreen(),
                    ),
                  ),
                );
              },
              shape: const CircleBorder(),
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
        ),
      ),
    );
  }
}
