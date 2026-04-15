import 'package:flutter/material.dart';
import 'data/models/user_model.dart';
// Importations des screens des features
import 'features/mobile_vendeur/screens/notification_screen.dart';
import 'features/mobile_acheteur/screens/catalog_screen.dart';
import 'features/web_gestionnaire/screens/stock_dashboard.dart';
import 'features/web_finance/screens/finance_report_screen.dart';
import 'features/web_admin/screens/admin_panel_screen.dart';

class AppRouter {
  static Widget getRoleBasedScreen(UserRole role) {
    switch (role) {
      case UserRole.vendeur: return const NotificationVendeurScreen();
      case UserRole.acheteur: return const CatalogAcheteurScreen();
      case UserRole.gestionnaire: return const StockDashboardWeb();
      case UserRole.finance: return const FinanceReportWeb();
      case UserRole.admin: return const AdminPanelWeb();
    }
  }
}
