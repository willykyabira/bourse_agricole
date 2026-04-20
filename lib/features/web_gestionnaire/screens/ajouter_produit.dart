import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AjouterProduit extends StatefulWidget {
  final Map<String, dynamic>? productToEdit;
  final bool isDialog;

  const AjouterProduit({super.key, this.productToEdit, required this.isDialog});

  @override
  State<AjouterProduit> createState() => _AjouterProduitState();
}

class _AjouterProduitState extends State<AjouterProduit> {
  final Color primaryGreen = const Color(0xFF1B5E20);
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _catCtrl = TextEditingController();
  final TextEditingController _qteCtrl = TextEditingController();
  final TextEditingController _unitCtrl = TextEditingController();
  final TextEditingController _puCtrl = TextEditingController();
  final TextEditingController _ptCtrl = TextEditingController();

  DateTime? _dateRecolte;
  DateTime? _datePeremption;

  // Base de données des produits BAN
  final Map<String, Map<String, dynamic>> _dataProduits = {
    'Tomate': {'cat': 'Produits frais', 'jours': 7},
    'Banane': {'cat': 'Produits frais', 'jours': 5},
    'Mangue': {'cat': 'Produits frais', 'jours': 10},
    'Légumes feuilles': {'cat': 'Produits frais', 'jours': 3},
    'Manioc frais': {'cat': 'Tubercules', 'jours': 3},
    'Patate douce': {'cat': 'Tubercules', 'jours': 28},
    'Pomme de terre': {'cat': 'Tubercules', 'jours': 90},
    'Maïs (grain sec)': {'cat': 'Céréales', 'jours': 730},
    'Riz': {'cat': 'Céréales', 'jours': 1095},
    'Haricots': {'cat': 'Céréales', 'jours': 1095},
    'So_ja': {'cat': 'Céréales', 'jours': 730},
    'Arachides': {'cat': 'Oléagineux', 'jours': 180},
    'Sésame': {'cat': 'Oléagineux', 'jours': 365},
    'Manioc séché': {'cat': 'Transformés', 'jours': 270},
    'Café': {'cat': 'Transformés', 'jours': 730},
    'Cacao': {'cat': 'Transformés', 'jours': 730},
  };

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      _nomCtrl.text = widget.productToEdit!['nom_produit'] ?? '';
      _catCtrl.text = widget.productToEdit!['categorie'] ?? '';
      _qteCtrl.text = widget.productToEdit!['quantite'].toString();
      _unitCtrl.text = widget.productToEdit!['unite_mesure'] ?? '';
      _puCtrl.text = widget.productToEdit!['prix_unitaire']?.toString() ?? '0';
      _ptCtrl.text = widget.productToEdit!['prix_total']?.toString() ?? '0';
      if (widget.productToEdit!['date_recolte'] != null) {
        _dateRecolte = DateTime.parse(widget.productToEdit!['date_recolte']);
        _datePeremption = DateTime.parse(widget.productToEdit!['date_peremption']);
      }
    }
    _qteCtrl.addListener(_calculerPrixTotal);
    _puCtrl.addListener(_calculerPrixTotal);
  }

  void _calculerPrixTotal() {
    final q = double.tryParse(_qteCtrl.text) ?? 0;
    final p = double.tryParse(_puCtrl.text) ?? 0;
    setState(() => _ptCtrl.text = (q * p).toStringAsFixed(2));
  }

  void _onProductSelected(String? prod) {
    if (prod != null) {
      setState(() {
        _nomCtrl.text = prod;
        _catCtrl.text = _dataProduits[prod]!['cat'];
        _majPeremption();
      });
    }
  }

  void _majPeremption() {
    if (_dateRecolte != null && _dataProduits.containsKey(_nomCtrl.text)) {
      int jours = _dataProduits[_nomCtrl.text]!['jours'];
      setState(() => _datePeremption = _dateRecolte!.add(Duration(days: jours)));
    }
  }

  Future<void> _choisirDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      locale: const Locale("fr", "FR"),
    );
    if (picked != null) {
      setState(() {
        _dateRecolte = picked;
        _majPeremption();
      });
    }
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate() || _dateRecolte == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir tout, incluant la date")));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final data = {
        'nom_produit': _nomCtrl.text,
        'categorie': _catCtrl.text,
        'quantite': double.tryParse(_qteCtrl.text) ?? 0,
        'unite_mesure': _unitCtrl.text,
        'prix_unitaire': double.tryParse(_puCtrl.text) ?? 0,
        'prix_total': double.tryParse(_ptCtrl.text) ?? 0,
        'date_recolte': _dateRecolte?.toIso8601String(),
        'date_peremption': _datePeremption?.toIso8601String(),
      };
      if (widget.productToEdit == null) {
        await Supabase.instance.client.from('produits').insert(data);
      } else {
        await Supabase.instance.client.from('produits').update(data).eq('id', widget.productToEdit!['id']);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView( // Empêche les bandes jaunes
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("FORMULAIRE DE RECEPTION PRODUIT", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 18)),
                  const Divider(),
                  DropdownButtonFormField<String>(
                    value: _nomCtrl.text.isEmpty ? null : _nomCtrl.text,
                    decoration: _decor("Sélectionnez le produit"),
                    items: _dataProduits.keys.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: _onProductSelected,
                  ),
                  const SizedBox(height: 10),
                  _champ("Catégorie (Auto)", _catCtrl, actif: false),
                  Row(
                    children: [
                      Expanded(child: _champ("Quantité", _qteCtrl, estNum: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _champ("Unité", _unitCtrl)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _champ("Prix Unit. (\$)", _puCtrl, estNum: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _champ("Prix Total (\$)", _ptCtrl, actif: false)),
                    ],
                  ),
                  _dateTile("Date de récolte", _dateRecolte, icon: Icons.event, color: const Color(0xFFE8F5E9), onTap: () => _choisirDate(context)),
                  const SizedBox(height: 8),
                  _dateTile("Péremption (Auto)", _datePeremption, icon: Icons.timer_outlined, color: Colors.orange.shade50),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _sauvegarder,
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, padding: const EdgeInsets.all(15)),
                      child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("ENREGISTRER DANS BAN", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decor(String label) => InputDecoration(
    labelText: label, filled: true, fillColor: const Color(0xFFF1F4F1),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
  );

  Widget _champ(String label, TextEditingController ctrl, {bool estNum = false, bool actif = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl, enabled: actif, keyboardType: estNum ? TextInputType.number : TextInputType.text,
        decoration: _decor(label),
      ),
    );
  }

  Widget _dateTile(String label, DateTime? dt, {required IconData icon, required Color color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, color: primaryGreen, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                Text(dt == null ? "Cliquez pour choisir" : DateFormat('dd/MM/yyyy').format(dt), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}