import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../helper/appconstant.dart';
import 'notes_state.dart';

class NoteCubit extends Cubit<NoteState> {
  final SupabaseClient supabase;

  NoteCubit({SupabaseClient? supabaseClient})
      : supabase = supabaseClient ?? Supabase.instance.client,
        super(NoteInitial());

  // ===== FETCH =====
  Future<void> fetchNotes() async {
    emit(NoteLoading());
    try {
      final res = await supabase.from('notes').select();
      emit(NotesLoaded(List<Map<String, dynamic>>.from(res)));
    } catch (e) {
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
