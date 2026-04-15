import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPanelWeb extends StatelessWidget {
  const AdminPanelWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Administration Système")),
      body: StreamBuilder(
        stream: Supabase.instance.client.from('profiles').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final users = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user['email']),
                subtitle: Text("Rôle actuel : ${user['role']}"),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Logique pour changer le rôle de l'utilisateur
                  },
                  child: const Text("Modifier les accès"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
