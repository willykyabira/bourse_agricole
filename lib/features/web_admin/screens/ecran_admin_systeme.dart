import 'package:bourse_agricole/data/repositories/repertoire_authentification.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/screens/ecran_connexion.dart';

class EcranAdminSysteme extends StatefulWidget {
  const EcranAdminSysteme({super.key});

  @override
  State<EcranAdminSysteme> createState() => _EcranAdminSystemeState();
}

class _EcranAdminSystemeState extends State<EcranAdminSysteme> {
  int _selectedIndex = 3; // Par défaut sur Gestion des comptes pour vos tests
  final RepertoireAuthentification _authRepo = RepertoireAuthentification();
  final _supabase = Supabase.instance.client;

  // Couleurs Officielles BAN
  final Color primaryGreen = const Color(0xFF1B5E20);
  final Color bgLight = const Color(0xFFF4F7F6);
  final Color accentGold = const Color(0xFFFBC02D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildImprovedHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(25),
                    child: _getSelectedContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSelectedContent() {
    switch (_selectedIndex) {
      case 0: return const Center(child: Text("Tableau de bord en attente de données"));
      case 1: return const Center(child: Text("Inventaire Global"));
      case 2: return const Center(child: Text("Suivi des Commandes"));
      case 3: return _buildGestionComptesRealTime(); // Version Réelle
      case 4: return const Center(child: Text("Statistiques Agricoles"));
      case 5: return const Center(child: Text("Paramètres"));
      default: return _buildGestionComptesRealTime();
    }
  }

  // --- GESTION DES COMPTES CONNECTÉE À SUPABASE ---
  Widget _buildGestionComptesRealTime() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      // Écoute en temps réel de la table profiles
      stream: _supabase.from('profiles').stream(primaryKey: ['id']).order('nom_complet'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _whiteBox("Erreur", Text("Impossible de charger les comptes : ${snapshot.error}"));
        }

        final tousLesComptes = snapshot.data ?? [];

        // Séparation des comptes par rôle
        final staffComptes = tousLesComptes.where((u) => 
          ['admin', 'finance', 'gestionnaire'].contains(u['role'])).toList();
        
        final marcheComptes = tousLesComptes.where((u) => 
          ['vendeur', 'acheteur'].contains(u['role'])).toList();

        return Column(
          children: [
            // Section STAFF (Admin, Finance, Gestionnaire)
            _whiteBox("Personnel Administratif & Staff", Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${staffComptes.length} Agent(s) actif(s)"),
                    ElevatedButton.icon(
                      onPressed: _showCreateAgentDialog,
                      icon: const Icon(Icons.person_add, color: Colors.white, size: 18),
                      label: const Text("Nouvel Agent staff", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                    ),
                  ],
                ),
                const Divider(height: 30),
                if (staffComptes.isEmpty) const Text("Aucun agent staff trouvé."),
                ...staffComptes.map((u) => _agentTile(
                  u['nom_complet'] ?? "Inconnu", 
                  _formatRole(u['role']), 
                  u['nom_complet'] == "Willy Kyabira"
                )),
              ],
            )),

            const SizedBox(height: 25),

            // Section MARCHÉ (Acheteurs et Vendeurs)
            _whiteBox("Utilisateurs de la Bourse (Marché)", Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${marcheComptes.length} Acteurs agricoles enregistrés"),
                const SizedBox(height: 20),
                if (marcheComptes.isEmpty) const Text("Aucun acheteur ou vendeur enregistré."),
                ...marcheComptes.map((u) => _marketUserTile(
                  u['nom_complet'] ?? "Utilisateur", 
                  u['role'] == 'vendeur' ? "Vendeur (Agriculteur)" : "Acheteur",
                )),
              ],
            )),
          ],
        );
      },
    );
  }

  // --- DIALOGUE DE CRÉATION (Utilise votre Repo Authentification) ---
  void _showCreateAgentDialog() {
    final nomController = TextEditingController();
    final emailController = TextEditingController();
    final passController = TextEditingController();
    String selectedRole = "finance";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Créer un Agent Staff", style: TextStyle(color: primaryGreen)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nomController, decoration: const InputDecoration(labelText: "Nom complet")),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email professionnel")),
                TextField(controller: passController, obscureText: true, decoration: const InputDecoration(labelText: "Mot de passe")),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(value: "finance", child: Text("Chargé de Finance")),
                    DropdownMenuItem(value: "gestionnaire", child: Text("Gestionnaire de Stock")),
                  ],
                  onChanged: (val) => setDialogState(() => selectedRole = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
              onPressed: () async {
                try {
                  await _authRepo.signUp(
                    emailController.text.trim(),
                    passController.text.trim(),
                    nomController.text.trim(),
                    selectedRole,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Agent créé avec succès !")));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text("Créer le compte", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPOSANTS UI ---

  String _formatRole(String? role) {
    switch (role) {
      case 'admin': return "Administrateur";
      case 'finance': return "Chargé de Finance";
      case 'gestionnaire': return "Gestionnaire de Stock";
      default: return role ?? "Utilisateur";
    }
  }

  Widget _agentTile(String n, String r, bool isMe) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isMe ? accentGold : primaryGreen.withOpacity(0.1),
        child: Icon(isMe ? Icons.admin_panel_settings : Icons.badge, color: isMe ? Colors.white : primaryGreen),
      ),
      title: Text(n, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(r),
      trailing: isMe ? const Chip(label: Text("Moi")) : const Icon(Icons.check_circle, color: Colors.green, size: 18),
    );
  }

  Widget _marketUserTile(String name, String role) {
    bool isVendeur = role.contains("Vendeur");
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isVendeur ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        child: Icon(isVendeur ? Icons.agriculture : Icons.shopping_cart, color: isVendeur ? Colors.orange : Colors.blue),
      ),
      title: Text(name),
      subtitle: Text(role),
    );
  }

  Widget _whiteBox(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
          const Divider(height: 30), 
          child
        ]
      ),
    );
  }

  // Les autres méthodes (_buildSidebar, _buildImprovedHeader, _navItem) restent identiques à votre version originale
  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: primaryGreen,
      child: Column(
        children: [
          const SizedBox(height: 50),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/images/logo_ban.png', errorBuilder: (c,e,s) => const Icon(Icons.agriculture, size: 40)),
            ),
          ),
          const SizedBox(height: 15),
          const Text("BAN ADMIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          _navItem(0, Icons.grid_view, "TABLEAU DE BORD"),
          _navItem(1, Icons.inventory_2_outlined, "INVENTAIRE"),
          _navItem(2, Icons.local_shipping_outlined, "COMMANDES"),
          _navItem(3, Icons.people_outline, "GESTION COMPTES"),
          _navItem(4, Icons.bar_chart_outlined, "STATS"),
          _navItem(5, Icons.settings_outlined, "PARAMETRES"),
          const Spacer(),
          ListTile(
            onTap: () async {
              await _authRepo.signOut();
              if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const EcranConnexion()), (r) => false);
            },
            leading: const Icon(Icons.logout, color: Colors.orangeAccent),
            title: const Text("Déconnexion", style: TextStyle(color: Colors.orangeAccent)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.white10,
      leading: Icon(icon, color: isSelected ? accentGold : Colors.white70),
      title: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 13)),
      onTap: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildImprovedHeader() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Row(
        children: [
          const Text("Administration Système", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Willy Kyabira", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Administrateur", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(width: 15),
          CircleAvatar(backgroundColor: primaryGreen, child: const Icon(Icons.person, color: Colors.white)),
        ],
      ),
    );
  }
}