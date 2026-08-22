import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'meuble_generation_page.dart';

class ResultatPage extends StatelessWidget {
  final File imageAvant;
  final String piece;
  final String style;
  final String couleur;

  // Résultat retourné par le worker GPU
  final dynamic resultatIA;

  // URL de l'image source stockée dans Supabase
  final String? inputImageUrl;

  const ResultatPage({
    super.key,
    required this.imageAvant,
    required this.piece,
    required this.style,
    required this.couleur,
    required this.resultatIA,
    this.inputImageUrl,
  });

  static const Color backgroundColor = Color(0xFF102A27);
  static const Color cardColor = Color(0xFF183C34);
  static const Color accentYellow = Color(0xFFE3A812);
  static const Color creamColor = Color(0xFFF5EEDC);
  static const Color secondaryText = Color(0xFFD5D0C2);
  static const Color borderColor = Color(0xFF2A5148);

  String? getImageGenereeUrl() {
    if (resultatIA is! Map) {
      return null;
    }

    final Map<String, dynamic> data =
    Map<String, dynamic>.from(resultatIA as Map);

    debugPrint('RESULTAT IA = $data');

    final result = data['result'];

    if (result is Map) {
      final generatedUrl = result['generated_image_url'];

      debugPrint('GENERATED IMAGE URL = $generatedUrl');

      if (generatedUrl is String &&
          generatedUrl.isNotEmpty &&
          (generatedUrl.startsWith('http://') ||
              generatedUrl.startsWith('https://'))) {
        return generatedUrl;
      }
    }

    return null;
  }

  Widget _buildImageApres() {
    final String? imageUrl = getImageGenereeUrl();

    if (imageUrl == null) {
      return Container(
        color: cardColor,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        child: Text(
          'Image générée indisponible',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: secondaryText,
            fontSize: 11,
          ),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: cardColor,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
            color: accentYellow,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('ERREUR IMAGE GENEREE : $error');
        debugPrint('URL : $imageUrl');

        return Container(
          color: cardColor,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          child: Text(
            'Impossible de charger l’image générée.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: secondaryText,
              fontSize: 11,
            ),
          ),
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: creamColor,
                      size: 19,
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        'AI INTERIOR DESIGN',
                        style: GoogleFonts.plusJakartaSans(
                          color: creamColor.withOpacity(0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 20),

              // ==================================================
              // TITRE
              // ==================================================

              Center(
                child: Text(
                  'Votre nouvel intérieur',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    color: creamColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Une nouvelle ambiance imaginée pour vous.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: secondaryText,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // AVANT / APRÈS
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: _imageCard(
                      titre: 'Avant',
                      image: Image.file(
                        imageAvant,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _imageCard(
                      titre: 'Après',
                      image: _buildImageApres(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ==================================================
              // STYLE
              // ==================================================

              _sectionTitle('Style proposé'),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentYellow.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: accentYellow,
                        size: 23,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Style $style',
                              style: GoogleFonts.playfairDisplay(
                                color: creamColor,
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              getDescriptionStyle(style),
                              style: GoogleFonts.plusJakartaSans(
                                color: secondaryText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // PALETTE
              // ==================================================


              const SizedBox(height: 30),

              // ==================================================
              // MEUBLES
              // ==================================================

              _sectionTitle('Meubles recommandés'),

              const SizedBox(height: 12),

              ...getMeublesSelonPiece(piece).map(
                    (meuble) => _furnitureCard(
                  meuble['icon'] as IconData,
                  meuble['nom'] as String,
                  meuble['description'] as String,
                  context,
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // RETOUR ACCUEIL
              // ==================================================

              Center(
                child: SizedBox(
                  width: 260,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(
                        context,
                            (route) => route.isFirst,
                      );
                    },
                    icon: const Icon(
                      Icons.home_outlined,
                      size: 19,
                    ),
                    label: Text(
                      'Retour à l’accueil',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentYellow,
                      foregroundColor: backgroundColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



// ============================================================
// MEUBLES SELON LA PIÈCE
// ============================================================

List<Map<String, dynamic>> getMeublesSelonPiece(String piece) {
switch (piece.toLowerCase()) {
case 'salon':
return [
{
'icon': Icons.weekend_outlined,
'nom': 'Canapé',
'description': 'Design épuré et confortable',
},
{
'icon': Icons.table_restaurant_outlined,
'nom': 'Table basse',
'description': 'Bois clair et lignes minimalistes',
},
{
'icon': Icons.chair_outlined,
'nom': 'Fauteuil',
'description': 'Assise élégante et confortable',
},
{
'icon': Icons.tv_outlined,
'nom': 'Meuble TV',
'description': 'Rangement moderne et discret',
},
];

case 'chambre':
return [
{
'icon': Icons.bed_outlined,
'nom': 'Lit',
'description': 'Structure confortable et élégante',
},
{
'icon': Icons.table_bar_outlined,
'nom': 'Table de chevet',
'description': 'Pratique et assortie au style',
},
{
'icon': Icons.door_sliding_outlined,
'nom': 'Armoire',
'description': 'Rangement fonctionnel et harmonieux',
},
{
'icon': Icons.inventory_2_outlined,
'nom': 'Commode',
'description': 'Rangement compact et élégant',
},
];

case 'cuisine':
return [
{
'icon': Icons.countertops_outlined,
'nom': 'Îlot central',
'description': 'Surface pratique et conviviale',
},
{
'icon': Icons.chair_outlined,
'nom': 'Tabourets',
'description': 'Assises adaptées à l’espace',
},
{
'icon': Icons.table_restaurant_outlined,
'nom': 'Table à manger',
'description': 'Design harmonieux et fonctionnel',
},
{
'icon': Icons.kitchen_outlined,
'nom': 'Meuble de rangement',
'description': 'Optimisation intelligente de l’espace',
},
];

case 'bureau':
return [
{
'icon': Icons.desk_outlined,
'nom': 'Bureau',
'description': 'Surface de travail fonctionnelle',
},
{
'icon': Icons.chair_outlined,
'nom': 'Chaise de bureau',
'description': 'Confort et ergonomie',
},
{
'icon': Icons.menu_book_outlined,
'nom': 'Bibliothèque',
'description': 'Rangement pratique et élégant',
},
{
'icon': Icons.inventory_2_outlined,
'nom': 'Meuble de rangement',
'description': 'Organisation optimale',
},
];

default:
return [];
}
}


// ============================================================
// DESCRIPTION DU STYLE
// ============================================================

  String getDescriptionStyle(String style) {
    switch (style.toLowerCase()) {
      case 'moderne':
        return 'Élégant • Simple • Lumineux';

      case 'minimaliste':
        return 'Épuré • Fonctionnel • Raffiné';

      case 'scandinave':
        return 'Doux • Naturel • Chaleureux';

      case 'industriel':
        return 'Brut • Authentique • Moderne';

      default:
        return 'Harmonieux • Élégant • Personnalisé';
    }
  }

// ============================================================
// TITRE SECTION
// ============================================================

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        color: creamColor.withOpacity(0.85),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.8,
      ),
    );
  }


// ============================================================
// TITRE SECTION
// ============================================================



  // ============================================================


  // ============================================================
  // IMAGE AVANT / APRÈS
  // ============================================================

  Widget _imageCard({
    required String titre,
    required Widget image,
  }) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,

          // Dégradé
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.65),
                ],
              ),
            ),
          ),

          Positioned(
            left: 14,
            bottom: 14,
            child: Text(
              titre,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COULEURS
  // ============================================================

  Widget _colorCircle(Color couleur) {
    return Container(
      margin: const EdgeInsets.only(right: 14),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: couleur,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
        ),
      ),
    );
  }

  // ============================================================
  // MEUBLE
  // ============================================================

  Widget _furnitureCard(
      IconData icon,
      String titre,
      String description,
      BuildContext context,
      ) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeubleGenerationPage(
                piece: piece,
                style: style,
                couleur: couleur,
                meuble: titre,
                description: description,
                imagePath: imageAvant.path,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentYellow.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: accentYellow,
                  size: 21,
                ),
              ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: GoogleFonts.plusJakartaSans(
                    color: creamColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    color: secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: secondaryText,
            size: 14,
          ),
        ],
      ),
    ),
    );
  }
}