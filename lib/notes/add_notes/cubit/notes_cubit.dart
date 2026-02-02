import 'dart:io';
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
  String _searchQuery = '';

  // ===== SEARCH =====
  Future<void> searchNotes(String query) async {
    _searchQuery = query;
    _page = 0;
    _notes.clear();
    await fetchNotes();
  }

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

      var query = supabase.from(AppConstants.notesTable).select();

      if (_searchQuery.isNotEmpty) {
        // query = query.ilike(
        //   AppConstants.titleKey,
        //   '%$_searchQuery%',
        // );
        query = query.or('${AppConstants.titleKey}.ilike.%$_searchQuery%,${AppConstants.descriptionKey}.ilike.%$_searchQuery%');
      }

      final res = await query
          .range(from, to)
          // .order('title', ascending: true)
          .order(AppConstants.createdAtKey, ascending: false);

      final newNotes = List<Map<String, dynamic>>.from(res);
      _notes.addAll(newNotes);
      _page++;

      _isFetching = false;
      emit(NotesLoaded(List.from(_notes), hasMore: newNotes.length >= _limit));
    } on PostgrestException catch (e) {
      _isFetching = false;
      emit(NoteError(e.message));
    } on SocketException {
      _isFetching = false;
      emit(NoteError(AppConstants.noInternet));
    } catch (e) {
      _isFetching = false;
      emit(NoteError(e.toString()));
    }
  }

  // ===== ADD =====
  Future<void> addNote(String title, String description) async {
    emit(NoteLoading());
    try {
      await supabase.from(AppConstants.notesTable).insert({
        AppConstants.titleKey: title,
        AppConstants.descriptionKey: description,
      });
      emit(NoteAddSuccess());
      fetchNotes();
    } on PostgrestException catch (e) {
      emit(NoteError(e.message));
    } on SocketException {
      emit(NoteError(AppConstants.noInternet));
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  // ===== UPDATE =====
  Future<void> updateNote(int id, String title, String description) async {
    emit(NoteLoading());
    try {
      await supabase.from(AppConstants.notesTable)
          .update({AppConstants.titleKey: title, AppConstants.descriptionKey: description})
          .eq(AppConstants.idKey, id);
      emit(NoteUpdateSuccess());
      fetchNotes();
    } on PostgrestException catch (e) {
      emit(NoteError(e.message));
    } on SocketException {
      emit(NoteError(AppConstants.noInternet));
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
    } on PostgrestException catch (e) {
      emit(NoteError(e.message));
    } on SocketException {
      emit(NoteError(AppConstants.noInternet));
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }
}
