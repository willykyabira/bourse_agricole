import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OngletProfil extends StatelessWidget {
  const OngletProfil({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    // Informations de l'utilisateur connecté
    final String userName =
        user?.userMetadata?['nom_complet'] ?? "Utilisateur BAN";

    final String userIdentifiant =
        user?.email ?? user?.phone ?? "Compte Actif";

    const Color banGreen = Color(0xFF1B5E20);
    const Color banEarth = Color(0xFF795548);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Carte d'identité de l'utilisateur
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFD1D9D1),
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.01),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: banEarth,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
            title: Text(
              userName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              userIdentifiant,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.edit,
                size: 20,
                color: banGreen,
              ),
              onPressed: () => _afficherModaleInfo(
                context,
                userName,
                userIdentifiant,
              ),
            ),
          ),
        ),

        const SizedBox(height: 25),

        // Menus du profil
        _buildMenuTile(
          Icons.info_outline,
          "Informations personnelles",
          banEarth,
          () => _afficherModaleInfo(
            context,
            userName,
            userIdentifiant,
          ),
        ),

        _buildMenuTile(
          Icons.security,
          "Sécurité & Mot de passe",
          banEarth,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Pour modifier vos paramètres de sécurité, contactez l'administrateur BAN.",
                ),
              ),
            );
          },
        ),

        _buildMenuTile(
          Icons.language,
          "Langue (Français)",
          banEarth,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "L'application BAN est configurée par défaut en Français.",
                ),
              ),
            );
          },
        ),

        _buildMenuTile(
          Icons.help_outline,
          "Support & Aide",
          banEarth,
          () {
            showAboutDialog(
              context: context,
              applicationName:
                  "Bourse Agricole Numérique (BAN)",
              applicationVersion: "v1.0.0",
              applicationLegalese:
                  "© 2026 Plateforme BAN. Tous droits réservés.",
            );
          },
        ),

        const SizedBox(height: 25),
        const Divider(),
        const SizedBox(height: 10),

        // Déconnexion
        ListTile(
          leading: const Icon(
            Icons.logout,
            color: Colors.redAccent,
          ),
          title: Text(
            "Déconnexion",
            style: GoogleFonts.poppins(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          onTap: () async {
            final bool? confirmer =
                await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                    "Déconnexion",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    "Voulez-vous vraiment vous déconnecter de la plateforme BAN ?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      child: Text(
                        "Annuler",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, true),
                      child: const Text(
                        "Se déconnecter",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );

            if (confirmer == true) {
              await supabase.auth.signOut();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            }
          },
        ),
      ],
    );
  }

  // Élément du menu du profil
  Widget _buildMenuTile(
    IconData icon,
    String title,
    Color color,
    VoidCallback action,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: color,
        size: 22,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 16,
        color: Colors.grey,
      ),
      onTap: action,
    );
  }

  // Affiche les informations du compte
  void _afficherModaleInfo(
    BuildContext context,
    String nom,
    String contact,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "Détails du Compte",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B5E20),
                ),
              ),

              const Divider(height: 20),
              const SizedBox(height: 10),

              Text(
                "NOM COMPLET :",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                nom,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                "IDENTIFIANT UNIQUE :",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                contact,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () =>
                      Navigator.pop(context),
                  child: const Text("Fermer"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}