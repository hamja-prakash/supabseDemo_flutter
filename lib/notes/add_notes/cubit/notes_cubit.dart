import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../helper/appconstant.dart';
import 'notes_state.dart';

class NoteCubit extends Cubit<NoteState> {
  final SupabaseClient supabase;

  NoteCubit({SupabaseClient? supabaseClient})
      : supabase = supabaseClient ?? Supabase.instance.client,
        super(NoteInitial());

  int _page = 0;
  final int _limit = 10;
  final List<Map<String, dynamic>> _notes = [];
  bool _isFetching = false;

  // ===== FETCH =====
  Future<void> fetchNotes({bool isLoadMore = false}) async {
    if (_isFetching) return;

    // Reset if refreshing (not loading more)
    if (!isLoadMore) {
      _page = 0;
      _notes.clear();
      // Only emit loading on initial fetch
      emit(NoteLoading());
    }

    if (state is NotesLoaded && isLoadMore && !(state as NotesLoaded).hasMore) return;

    _isFetching = true;

    try {
      final from = _page * _limit;
      final to = from + _limit - 1;

      final res = await supabase
          .from('notes')
          .select()
          .range(from, to)
          .order('created_at', ascending: false); // Order by newest first

      final newNotes = List<Map<String, dynamic>>.from(res);
      _notes.addAll(newNotes);
      _page++;

      _isFetching = false;
      emit(NotesLoaded(List.from(_notes), hasMore: newNotes.length >= _limit));
    } catch (e) {
      _isFetching = false;
      emit(NoteError(e.toString()));
    }
  }

  // ===== ADD =====
  Future<void> addNote(String title, String description) async {
    emit(NoteLoading());
    try {
      await supabase.from('notes').insert({
        AppConstants.titleKey: title,
        AppConstants.descriptionKey: description,
      });
      emit(NoteAddSuccess());
      fetchNotes();
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  // ===== UPDATE =====
  Future<void> updateNote(int id, String title, String description) async {
    emit(NoteLoading());
    try {
      await supabase.from('notes')
          .update({AppConstants.titleKey: title, AppConstants.descriptionKey: description})
          .eq(AppConstants.idKey, id);
      emit(NoteUpdateSuccess());
      fetchNotes();
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  // ===== DELETE =====
  Future<void> deleteNote(int id) async {
    emit(NoteLoading());
    try {
      await supabase.from('notes').delete().eq(AppConstants.idKey, id);
      emit(NoteDeleteSuccess());
      fetchNotes();
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }
}
