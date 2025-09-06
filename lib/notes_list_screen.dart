import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'note_edit_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await DBHelper.instance.getNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _deleteNote(int id) async {
    await DBHelper.instance.deleteNote(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note supprimée')),
    );
    _loadNotes();
  }

  void _goToEdit([Map<String, dynamic>? note]) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditScreen(note: note)),
    );
    if (updated == true) {
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Notes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () {
              // Déconnexion : retour à login et suppression de la pile
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          )
        ],
      ),
      body: _notes.isEmpty
          ? const Center(
        child: Text(
          "Aucune note pour l’instant",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(
                note['title'] ?? 'Sans titre',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                note['content'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Modifier',
                    onPressed: () => _goToEdit(note),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Supprimer',
                    onPressed: () => _deleteNote(note['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToEdit(),
        tooltip: 'Ajouter une note',
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
