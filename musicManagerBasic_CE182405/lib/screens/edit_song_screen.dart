import 'package:flutter/material.dart';

import '../controllers/library_controller.dart';
import '../models/song.dart';
import '../widgets/song_form.dart';

class EditSongScreen extends StatelessWidget {
  const EditSongScreen({super.key, required this.library, required this.song});
  final LibraryController library;
  final Song song;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit song')),
    body: SongForm(
      initialSong: song,
      onSave: (values) => library.edit(song.id!, values),
    ),
  );
}
