import 'package:flutter/material.dart';

import '../models/song.dart';
import '../utils/validation.dart';
import 'app_feedback.dart';
import 'content_width.dart';

class SongForm extends StatefulWidget {
  const SongForm({super.key, this.initialSong, required this.onSave});
  final Song? initialSong;
  final Future<Song> Function(Song) onSave;
  @override
  State<SongForm> createState() => _SongFormState();
}

class _SongFormState extends State<SongForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _artist;
  late final TextEditingController _year;
  late String _genre;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initialSong?.title);
    _artist = TextEditingController(text: widget.initialSong?.artist);
    _year = TextEditingController(text: widget.initialSong?.year);
    _genre = widget.initialSong?.genre ?? Song.genres.first;
  }

  @override
  void dispose() {
    _title.dispose();
    _artist.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final saved = await widget.onSave(
        Song(
          title: _title.text.trim(),
          artist: _artist.text.trim(),
          year: _year.text.trim(),
          genre: _genre,
        ),
      );
      if (mounted) Navigator.pop(context, saved);
    } catch (error) {
      debugPrint('Saving song failed: $error');
      if (mounted) {
        showMessage(
          context,
          'Could not save this song. Your changes are kept here. Please try again.',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: SafeArea(
      child: ContentWidth(
        maxWidth: 650,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Form(
                key: _form,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.initialSong == null
                          ? 'A new addition to your collection'
                          : 'Make it your own',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Keep the details of every song in one place.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      key: const Key('song-title'),
                      controller: _title,
                      enabled: !_saving,
                      maxLength: 120,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g. Love Story',
                        prefixIcon: Icon(Icons.music_note_outlined),
                      ),
                      validator: (value) =>
                          Validation.requiredText(value, 'a song title'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('song-artist'),
                      controller: _artist,
                      enabled: !_saving,
                      maxLength: 120,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Artist',
                        hintText: 'e.g. Taylor Swift',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          Validation.requiredText(value, 'an artist'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('song-year'),
                      controller: _year,
                      enabled: !_saving,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Release year',
                        hintText: '${DateTime.now().year}',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                      ),
                      validator: Validation.year,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: const Key('song-genre'),
                      initialValue: _genre,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Genre',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: Song.genres
                          .map(
                            (genre) => DropdownMenuItem(
                              value: genre,
                              child: Text(genre),
                            ),
                          )
                          .toList(),
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _genre = value!),
                    ),
                    const SizedBox(height: 30),
                    FilledButton.icon(
                      key: const Key('save-song'),
                      onPressed: _saving ? null : _submit,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(
                        _saving
                            ? 'Saving…'
                            : widget.initialSong == null
                            ? 'Save song'
                            : 'Save changes',
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      key: const Key('cancel-song'),
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
