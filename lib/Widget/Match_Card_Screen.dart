import 'package:flutter/material.dart';

class MatchCard extends StatelessWidget {
  final String name, age, city, education, photo;
  final VoidCallback onTap;

  const MatchCard({
    super.key,
    required this.name,
    required this.age,
    required this.city,
    required this.education,
    required this.photo,
    required this.onTap, required void Function() onIgnore, required status, required String subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(photo),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$age yrs | $city\n$education"),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }
}
