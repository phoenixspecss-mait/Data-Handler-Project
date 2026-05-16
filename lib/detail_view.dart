import 'package:flutter/material.dart';
import 'package:project/main.dart';

class DetailView extends StatelessWidget {
  final Character character;
  const DetailView({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(character.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              // image with rounded top corners
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  character.image,
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 400,
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 80, color: Colors.grey),
                  ),
                ),
              ),

              // info inside card
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(character.name,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold)),
                    const Divider(height: 24),
                    _row(Icons.circle, 'Status', character.status),
                    _row(Icons.biotech, 'Species', character.species),
                    _row(Icons.wc, 'Gender', character.gender),
                    _row(Icons.public, 'Origin', character.origin),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    Color valueColor = Colors.black; // default
    if (label == 'Status') {
      if (value == 'Alive') {
        valueColor = Colors.green;
      } else if (value == 'Dead') {
        valueColor = Colors.red;
      } else {
        valueColor = Colors.grey;
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Expanded(
            child: Text(value, style:  TextStyle(fontSize: 18,color: valueColor)),
          ),
        ],
      ),
    );
  }
}