
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../helper/appconstant.dart';
import '../../../shared/common_widget/common_textfield.dart';
import '../cubit/notes_cubit.dart';
import '../cubit/notes_state.dart';

class AddNoteScreen extends StatefulWidget {
  final Map<String, dynamic>? note;
  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final title = TextEditingController();
  final description = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      title.text = widget.note![AppConstants.titleKey] ?? '';
      description.text = widget.note![AppConstants.descriptionKey] ?? '';
    }
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.note == null ? AppConstants.addNote : AppConstants.editNote)),
        body: SafeArea(
          child: BlocListener<NoteCubit, NoteState>(
            listener: (context, state) {
              if (state is NoteAddSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppConstants.noteAdded), backgroundColor: Colors.green),
                );
                Navigator.pop(context);
              }
              if (state is NoteUpdateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppConstants.noteUpdated), backgroundColor: Colors.green),
                );
                Navigator.pop(context);
              }

              if (state is NoteError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: BlocBuilder<NoteCubit, NoteState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            controller: title,
                            hint: AppConstants.title,
                            keyboardType: TextInputType.text,
                          ),

                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: description,
                            hint: AppConstants.description,
                            keyboardType: TextInputType.text,
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: state is NoteLoading
                                  ? null
                                  : () {
                                FocusScope.of(context).unfocus();

                                final titleText = title.text.trim();
                                final descriptionText = description.text.trim();

                                if (widget.note == null) {
                                  context.read<NoteCubit>().addNote(
                                    titleText,
                                    descriptionText,
                                  );
                                } else {
                                  context.read<NoteCubit>().updateNote(
                                    widget.note![AppConstants.idKey],
                                    titleText,
                                    descriptionText,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                  widget.note == null ? AppConstants.save : AppConstants.update,
                                  style: const TextStyle(fontSize: 16)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Loading Overlay
                    if (state is NoteLoading)
                      Container(
                        color: Colors.black54,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );
  }
}
