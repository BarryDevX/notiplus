import 'package:flutter/material.dart';
import 'db_helper.dart';

class NoteEditScreen extends StatefulWidget {
  final Map<String, dynamic>? note;
  const NoteEditScreen({super.key, this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!['title'] ?? '';
      _contentController.text = widget.note!['content'] ?? '';
    }
  }

  Future<void> _saveNote() async {
    if (_formKey.currentState!.validate()) {
      if (widget.note == null) {
        // Ajout
        await DBHelper.instance.insertNote({
          'title': _titleController.text,
          'content': _contentController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note ajoutée')),
        );
      } else {
        // Modification
        await DBHelper.instance.updateNote({
          'id': widget.note!['id'],
          'title': _titleController.text,
          'content': _contentController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note modifiée')),
        );
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? "Nouvelle Note" : "Modifier Note"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Titre",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Titre requis" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Contenu",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Contenu requis" : null,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("Sauvegarder"),
                    onPressed: _saveNote,
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: const Text("Annuler"),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
