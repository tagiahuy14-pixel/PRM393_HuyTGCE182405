import 'package:flutter/material.dart';

import '../controllers/library_controller.dart';
import '../widgets/song_form.dart';

class AddSongScreen extends StatelessWidget {
  const AddSongScreen({super.key, required this.library});
  final LibraryController library;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add song')),
    body: SongForm(onSave: library.add),
  );
}
