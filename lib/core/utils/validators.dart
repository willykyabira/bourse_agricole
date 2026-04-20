class AppValidators {
  // Valide que le nom du produit n'est pas vide
  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Le nom du produit est obligatoire";
    }
    return null;
  }

  // Valide la quantité (ne doit pas être négative)
  static String? validateStockQuantity(String? value) {
    if (value == null || value.isEmpty) return "Entrez une quantité";
    final n = int.tryParse(value);
    if (n == null) return "Format invalide";
    if (n < 0) return "La quantité ne peut pas être négative";
    return null;
  }

  // Valide l'email pour le Login (Mobile & Web)
  static String? validateEmail(String? value) {
    if (value == null || !value.contains('@')) return "Email invalide";
    return null;
  }
}