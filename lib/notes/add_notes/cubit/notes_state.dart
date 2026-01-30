import 'package:equatable/equatable.dart';

abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

// ===== Initial =====
class NoteInitial extends NoteState {}

// ===== Loading =====
class NoteLoading extends NoteState {}

// ===== Fetch Notes =====
class NotesLoaded extends NoteState {
  final List<Map<String, dynamic>> notes;
  final bool hasMore;
  const NotesLoaded(this.notes, {this.hasMore = true});

  @override
  List<Object?> get props => [notes, hasMore];
}

// ===== Add =====
class NoteAddSuccess extends NoteState {}

// ===== Update =====
class NoteUpdateSuccess extends NoteState {}

// ===== Delete =====
class NoteDeleteSuccess extends NoteState {}

// ===== Error =====
class NoteError extends NoteState {
  final String message;
  const NoteError(this.message);

  @override
  List<Object?> get props => [message];
}
