  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:supabase_demo/auth/login/view/login_screen.dart';
  import 'package:supabase_demo/helper/appconstant.dart';
  import 'package:supabase_demo/notes/add_notes/cubit/notes_cubit.dart';
  import 'package:supabase_demo/notes/add_notes/cubit/notes_state.dart';
  import 'package:supabase_demo/notes/add_notes/view/add_note_screen.dart';
  import 'package:supabase_demo/shared/common_widget/common_textfield.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';

  import 'helper/assets_path.dart';

  class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {
    final supabase = Supabase.instance.client;
    final ScrollController _scrollController = ScrollController();
    late final NoteCubit _noteCubit;
    Timer? _debounce;
    final TextEditingController _searchController = TextEditingController();

    @override
    void initState() {
      super.initState();
      _noteCubit = NoteCubit()..fetchNotes();
      _scrollController.addListener(_onScroll);
    }

    @override
    void dispose() {
      _scrollController.dispose();
      _noteCubit.close();
      _debounce?.cancel();
      _searchController.dispose();
      super.dispose();
    }

    void _onSearchChanged(String query) {
      setState(() {});
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _noteCubit.searchNotes(query);
      });
    }

    void _onScroll() {
      if (_isBottom) {
        if (_noteCubit.state is NotesLoaded && (_noteCubit.state as NotesLoaded).hasMore) {
          _noteCubit.fetchNotes(isLoadMore: true);
        }
      }
    }

    bool get _isBottom {
      if (!_scrollController.hasClients) return false;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      return currentScroll >= (maxScroll * 0.9); // Fetch slightly before bottom
    }

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
      return BlocProvider.value(
        value: _noteCubit,
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

          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                // child: TextField(
                //   controller: _searchController,
                //   decoration: InputDecoration(
                //     hintText: 'Search notes...',
                //     prefixIcon: const Icon(Icons.search),
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(8.0),
                //     ),
                //     filled: true,
                //     fillColor: Colors.grey[200],
                //   ),
                //   onChanged: _onSearchChanged,
                // ),

                child: CustomTextField(
                  controller: _searchController,
                  hint: AppConstants.searchNotes,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                    icon: const Icon(Icons.cancel_outlined),
                    onPressed: () {
                      _searchController.clear();
                      _noteCubit.searchNotes('');
                      setState(() {});
                    },
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              Expanded(
                child: BlocConsumer<NoteCubit, NoteState>(
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
                      return SafeArea(
                        bottom: true,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                          itemCount: state.hasMore ? state.notes.length + 1 : state.notes.length,
                          itemBuilder: (context, index) {
                            if (index >= state.notes.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

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
                                      ),
                      );

              }
              return const Center(child: Text(AppConstants.somethingWentWrong));
            },
              ),
            ),
          ],
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
