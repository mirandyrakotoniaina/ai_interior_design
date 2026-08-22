import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'generation_page.dart';
import 'dart:io';


class ConfigurationPage extends StatefulWidget {
  final File imageAvant;

  const ConfigurationPage({
    super.key,
    required this.imageAvant,
  });

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  // ============================================================
  // COULEURS DU THÈME
  // ============================================================

  static const Color backgroundColor = Color(0xFF102A27);
  static const Color cardColor = Color(0xFF183C34);
  static const Color accentYellow = Color(0xFFE3A812);
  static const Color creamColor = Color(0xFFF5EEDC);
  static const Color secondaryText = Color(0xFFD5D0C2);
  static const Color borderColor = Color(0xFF2A5148);

  // ============================================================
  // SÉLECTIONS
  // ============================================================

  String piece = 'Salon';
  String style = 'Moderne';
  String couleur = 'Beige';

  // ============================================================
  // DONNÉES DE CONFIGURATION
  // ============================================================

  final List<String> pieces = ['Salon', 'Chambre', 'Cuisine', 'Bureau'];
  final List<String> styles = ['Moderne', 'Minimaliste', 'Scandinave', 'Industriel'];

  final List<Map<String, dynamic>> couleurs = [
    {'name': 'Beige', 'color': const Color(0xFFE5D3B3)},
    {'name': 'Blanc', 'color': const Color(0xFFF5F5F5)},
    {'name': 'Gris', 'color': const Color(0xFF8E8E93)},
    {'name': 'Vert', 'color': const Color(0xFF2E5A44)},
  ];






  String getImageSelonCouleur() {
    return 'assets/images/'
        '${piece.toLowerCase()}_'
        '${style.toLowerCase()}_'
        '${couleur.toLowerCase()}.jpg';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // ====================================================
          // CONTENU SCROLLABLE
          // ====================================================
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. GRANDE IMAGE D'EN-TÊTE
                  _buildHeaderImage(context),

                  const SizedBox(height: 20),

                  // 2. SECTIONS DE SÉLECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Type de pièce'),
                        const SizedBox(height: 10),
                        _buildHorizontalChips(
                          items: pieces,
                          selectedItem: piece,
                          onSelected: (val) => setState(() => piece = val),
                        ),

                        const SizedBox(height: 22),

                        _sectionTitle('Style d\'ambiance'),
                        const SizedBox(height: 10),
                        _buildHorizontalChips(
                          items: styles,
                          selectedItem: style,
                          onSelected: (val) => setState(() => style = val),
                        ),

                        const SizedBox(height: 22),

                        _sectionTitle('Couleur dominante'),
                        const SizedBox(height: 12),
                        _buildColorSelector(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ====================================================
          // BARRE D'ACTION FIXE EN BAS
          // ====================================================
          _buildBottomActionBar(context),
        ],
      ),
    );
  }

  // ============================================================
  // WIDGET : IMAGE AVEC EFFET TRANSLUCIDE (HEADER)
  // ============================================================
  Widget _buildHeaderImage(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Image principale avec coins arrondis en bas
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(36),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              key: ValueKey(getImageSelonCouleur()),
              height: screenHeight * 0.58,
              width: double.infinity,
              child: Image.asset(
                getImageSelonCouleur(),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // Bouton Retour Flottant
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),

        // Carte d'information translucide en bas de l'image
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(36),
              ),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.85),
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$piece $style',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.palette_outlined,
                            color: accentYellow,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tonalité $couleur',
                            style: GoogleFonts.plusJakartaSans(
                              color: secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  // ============================================================
  // WIDGET : DÉFILEMENT HORIZONTAL POUR LES SELECTIONS
  // ============================================================
  Widget _buildHorizontalChips({
    required List<String> items,
    required String selectedItem,
    required Function(String) onSelected,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: items.map((item) {
          final isSelected = selectedItem == item;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onSelected(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? accentYellow : cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? accentYellow : borderColor,
                  ),
                ),
                child: Text(
                  item,
                  style: GoogleFonts.plusJakartaSans(
                    color: isSelected ? backgroundColor : creamColor,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // WIDGET : SELECTEUR DE COULEURS
  // ============================================================
  Widget _buildColorSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: couleurs.map((item) {
        final String name = item['name'] as String;
        final Color color = item['color'] as Color;
        final bool selected = couleur == name;

        return GestureDetector(
          onTap: () => setState(() => couleur = name),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? accentYellow : borderColor,
                    width: selected ? 2.5 : 1,
                  ),
                ),
                child: selected
                    ? const Icon(
                  Icons.check_rounded,
                  color: backgroundColor,
                  size: 18,
                )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  color: selected ? accentYellow : secondaryText,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // WIDGET : BARRE DE BOUTON BAS (STYLE "ADD TO CART")
  // ============================================================
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Récapitulatif à gauche
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuration',
                style: GoogleFonts.plusJakartaSans(
                  color: secondaryText,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$piece • $style',
                style: GoogleFonts.playfairDisplay(
                  color: creamColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Bouton d'action "Générer" à droite
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GenerationPage(
                    imageAvant: widget.imageAvant,
                      piece: piece,
                      style: style,
                      couleur: couleur
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentYellow,
              foregroundColor: backgroundColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Générer',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 17,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WIDGET : TITRE DE SECTION
  // ============================================================
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        color: creamColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}