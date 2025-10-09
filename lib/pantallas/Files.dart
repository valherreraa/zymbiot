import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Reference> _items = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final ListResult result = await _storage
            .ref('user_files/$userId')
            .listAll();
        setState(() {
          _items = result.items;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar archivos: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadFile(Reference ref) async {
    try {
      final url = await ref.getDownloadURL();
      // TODO: Implementar la descarga del archivo usando url_launcher
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Archivos'),
        backgroundColor: const Color(0xFF800080),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          final isImage =
              item.name.toLowerCase().endsWith('.jpg') ||
              item.name.toLowerCase().endsWith('.png');
          final isPDF = item.name.toLowerCase().endsWith('.pdf');

          return ListTile(
            leading: Icon(
              isImage
                  ? Icons.image
                  : (isPDF ? Icons.picture_as_pdf : Icons.file_present),
            ),
            title: Text(item.name),
            onTap: () => _downloadFile(item),
          );
        },
      ),
    );
  }
}
