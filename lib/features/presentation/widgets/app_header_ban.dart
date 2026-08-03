import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bourse_agricole/features/presentation/widgets/notification_badge.dart';

/// Couleurs officielles de la plateforme BAN ITURI.
class BanTheme {
  static const Color greenTop = Color(0xFF1B5E20);
  static const Color blueBottom = Color(0xFF3F51B5);
  static const Color gold = Color(0xFFFBC02D);
}

/// En-tête commun et inchangeable affiché en haut de toutes les pages
/// de l'application. Il contient le logo officiel (PNG), le nom de la
/// plateforme et le badge de notifications.
class AppHeaderBan extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showNotifications;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppHeaderBan({
    super.key,
    this.title = "BAN ITURI",
    this.subtitle = "Bourse Agricole Numérique",
    this.showNotifications = true,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [BanTheme.greenTop, BanTheme.blueBottom],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              if (showBackButton) ...[
                IconButton(
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/logo_ban.png",
                    width: 55,
                    height: 55,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (showNotifications) const NotificationBadge(),
            ],
          ),
        ),
      ),
    );
  }
}
