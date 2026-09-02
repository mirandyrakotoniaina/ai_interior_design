import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';

import 'meuble_generation_page.dart';

class ResultatPage extends StatelessWidget {
  final File imageAvant;
  final String piece;
  final String style;
  final String couleur;

  // Réponse complète du backend
  final dynamic resultatIA;

  // URL de l'image source
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

  // ============================================================
  // COULEURS
  // ============================================================

  static const Color backgroundColor = Color(0xFF102A27);
  static const Color cardColor = Color(0xFF183C34);
  static const Color accentYellow = Color(0xFFE3A812);
  static const Color creamColor = Color(0xFFF5EEDC);
  static const Color secondaryText = Color(0xFFD5D0C2);
  static const Color borderColor = Color(0xFF2A5148);

  // ============================================================
  // RÉCUPÉRER L'URL DE L'IMAGE GÉNÉRÉE
  // ============================================================

  String? getImageGenereeUrl() {
    if (resultatIA is! Map) {
      debugPrint('RESULTAT IA : ce n\'est pas une Map');
      return null;
    }

    final Map<String, dynamic> data =
    Map<String, dynamic>.from(resultatIA as Map);

    debugPrint('========== RESULTAT IA ==========');
    debugPrint(data.toString());

    // Le backend peut avoir generated_image_url directement
    final directUrl = data['generated_image_url'];

    if (directUrl is String &&
        directUrl.trim().isNotEmpty &&
        (directUrl.startsWith('http://') ||
            directUrl.startsWith('https://'))) {
      return directUrl.trim();
    }

    // Ou dans result
    final result = data['result'];

    if (result is Map) {
      final generatedUrl = result['generated_image_url'];

      if (generatedUrl is String &&
          generatedUrl.trim().isNotEmpty &&
          (generatedUrl.startsWith('http://') ||
              generatedUrl.startsWith('https://'))) {
        return generatedUrl.trim();
      }
    }

    debugPrint('Aucune URL image générée trouvée.');

    return null;
  }

  // ============================================================
  // NORMALISER UN NOM DE MEUBLE
  // ============================================================

  String _normaliserMeuble(String valeur) {
    return valeur
        .toLowerCase()
        .trim()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }

  // ============================================================
  // RÉCUPÉRER L'OFFRE DU MARCHÉ
  //
  // Exemple backend :
  //
  // {
  //   "furniture": "Canapé",
  //   "estimated_price": "...",
  //   "stores": [...]
  // }
  // ============================================================

  Map<String, dynamic>? _getMarketOffer(String meuble) {
    if (resultatIA is! Map) {
      debugPrint('RESULTAT IA invalide.');
      return null;
    }

    final data = Map<String, dynamic>.from(resultatIA as Map);

    final marketOffers = data['market_offers'];

    if (marketOffers is! List) {
      debugPrint('market_offers absent.');
      return null;
    }

    final meubleRecherche = _normaliserMeuble(meuble);

    debugPrint(
      'Recherche offre pour : $meubleRecherche',
    );

    for (final offer in marketOffers) {
      if (offer is! Map) {
        continue;
      }

      final furniture =
      _normaliserMeuble(
        (offer['furniture'] ?? '').toString(),
      );

      debugPrint(
        'Offre backend : $furniture',
      );

      if (furniture == meubleRecherche) {
        final offre =
        Map<String, dynamic>.from(offer);

        debugPrint(
          '========== OFFRE TROUVÉE ==========',
        );
        debugPrint(
          'Meuble : $meuble',
        );
        debugPrint(
          'Offre : $offre',
        );
        debugPrint(
          '===================================',
        );

        return offre;
      }
    }

    debugPrint(
      'Aucune offre trouvée pour $meuble',
    );

    return null;
  }

  // ============================================================
  // IMAGE APRÈS
  // ============================================================

  Widget _buildImageApres(BuildContext context) {
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageFullscreenPage(
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        loadingBuilder: (
            context,
            child,
            loadingProgress,
            ) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            color: cardColor,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accentYellow,
              ),
            ),
          );
        },
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          debugPrint(
            'ERREUR IMAGE GENEREE : $error',
          );

          debugPrint(
            'URL : $imageUrl',
          );

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
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

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
                        'A I  I N T E R I O R  D E S I G N',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color:
                          creamColor.withOpacity(0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.5,
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
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _imageCard(
                      titre: 'Après',
                      image: _buildImageApres(context),
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
                  borderRadius:
                  BorderRadius.circular(20),
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
                        color:
                        accentYellow.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: accentYellow,
                        size: 23,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Style $style',
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style:
                            GoogleFonts.playfairDisplay(
                              color: creamColor,
                              fontSize: 19,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            getDescriptionStyle(style),
                            maxLines: 2,
                            overflow:
                            TextOverflow.ellipsis,
                            style:
                            GoogleFonts.plusJakartaSans(
                              color: secondaryText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // MEUBLES
              // ==================================================

              _sectionTitle(
                'Meubles recommandés',
              ),

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
                      style:
                      GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      accentYellow,
                      foregroundColor:
                      backgroundColor,
                      elevation: 0,
                      shape:
                      RoundedRectangleBorder(
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

  List<Map<String, dynamic>> getMeublesSelonPiece(
      String piece) {
    switch (piece.toLowerCase()) {
      case 'salon':
        return [
          {
            'icon': Icons.weekend_outlined,
            'nom': 'Canape',
            'description':
            'Design épuré et confortable',
          },
          {
            'icon':
            Icons.table_restaurant_outlined,
            'nom': 'Table basse',
            'description':
            'Bois clair et lignes minimalistes',
          },
          {
            'icon': Icons.chair_outlined,
            'nom': 'Fauteuil',
            'description':
            'Assise élégante et confortable',
          },
          {
            'icon': Icons.tv_outlined,
            'nom': 'Meuble TV',
            'description':
            'Rangement moderne et discret',
          },
        ];

      case 'chambre':
        return [
          {
            'icon': Icons.bed_outlined,
            'nom': 'Lit',
            'description':
            'Structure confortable et élégante',
          },
          {
            'icon': Icons.table_bar_outlined,
            'nom': 'Table de chevet',
            'description':
            'Pratique et assortie au style',
          },
          {
            'icon':
            Icons.door_sliding_outlined,
            'nom': 'Armoire',
            'description':
            'Rangement fonctionnel et harmonieux',
          },
          {
            'icon':
            Icons.inventory_2_outlined,
            'nom': 'Commode',
            'description':
            'Rangement compact et élégant',
          },
        ];

      case 'cuisine':
        return [
          {
            'icon':
            Icons.countertops_outlined,
            'nom': 'Îlot central',
            'description':
            'Surface pratique et conviviale',
          },
          {
            'icon': Icons.chair_outlined,
            'nom': 'Tabourets',
            'description':
            'Assises adaptées à l’espace',
          },
          {
            'icon':
            Icons.table_restaurant_outlined,
            'nom': 'Table à manger',
            'description':
            'Design harmonieux et fonctionnel',
          },
          {
            'icon': Icons.kitchen_outlined,
            'nom': 'Meuble de rangement',
            'description':
            'Optimisation intelligente de l’espace',
          },
        ];

      case 'bureau':
        return [
          {
            'icon': Icons.desk_outlined,
            'nom': 'Bureau',
            'description':
            'Surface de travail fonctionnelle',
          },
          {
            'icon': Icons.chair_outlined,
            'nom': 'Chaise de bureau',
            'description':
            'Confort et ergonomie',
          },
          {
            'icon':
            Icons.menu_book_outlined,
            'nom': 'Bibliothèque',
            'description':
            'Rangement pratique et élégant',
          },
          {
            'icon':
            Icons.inventory_2_outlined,
            'nom': 'Meuble de rangement',
            'description':
            'Organisation optimale',
          },
        ];

      default:
        return [];
    }
  }

  // ============================================================
  // DESCRIPTION STYLE
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
  // CARTE IMAGE
  // ============================================================

  Widget _imageCard({
    required String titre,
    required Widget image,
  }) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
        ),
        color: cardColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,

          IgnorePointer(
            child: DecoratedBox(
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
          ),

          Positioned(
            left: 14,
            bottom: 14,
            child: IgnorePointer(
              child: Text(
                titre,
                style:
                GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARTE MEUBLE
  // ============================================================

  Widget _furnitureCard(
      IconData icon,
      String titre,
      String description,
      BuildContext context,
      ) {
    return GestureDetector(
      onTap: () {
        // IMPORTANT :
        // On récupère directement l'offre
        // déjà renvoyée par /api/design/generate.

        final offer =
        _getMarketOffer(titre);

        String? estimatedPrice;
        List<dynamic> stores = [];

        if (offer != null) {
          final dynamic price =
          offer['estimated_price'];

          if (price != null &&
              price.toString().trim().isNotEmpty) {
            estimatedPrice =
                price.toString().trim();
          }

          final dynamic storesData =
          offer['stores'];

          if (storesData is List) {
            stores =
            List<dynamic>.from(storesData);
          }
        }

        debugPrint(
          '========== NAVIGATION MEUBLE ==========',
        );
        debugPrint('Meuble : $titre');
        debugPrint(
          'Prix : $estimatedPrice',
        );
        debugPrint(
          'Magasins : ${stores.length}',
        );
        debugPrint(
          '=======================================',
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MeubleGenerationPage(
                  piece: piece,
                  style: style,
                  couleur: couleur,
                  meuble: titre,
                  description: description,

                  // DONNÉES DU BACKEND
                  estimatedPrice:
                  estimatedPrice,
                  stores: stores,
                ),
          ),
        );
      },

      child: Container(
        margin:
        const EdgeInsets.only(bottom: 10),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius:
          BorderRadius.circular(18),
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
                color:
                accentYellow.withOpacity(0.10),
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
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    GoogleFonts.plusJakartaSans(
                      color: creamColor,
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    description,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    GoogleFonts.plusJakartaSans(
                      color: secondaryText,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

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

// ================================================================
// PAGE IMAGE PLEIN ÉCRAN
// ================================================================

class ImageFullscreenPage extends StatefulWidget {
  final String imageUrl;

  const ImageFullscreenPage({
    super.key,
    required this.imageUrl,
  });

  @override
  State<ImageFullscreenPage> createState() =>
      _ImageFullscreenPageState();
}

class _ImageFullscreenPageState
    extends State<ImageFullscreenPage> {
  bool telechargement = false;

  // ============================================================
  // TÉLÉCHARGER
  // ============================================================

  Future<void> telechargerImage() async {
    try {
      setState(() {
        telechargement = true;
      });

      final response = await http.get(
        Uri.parse(widget.imageUrl),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Impossible de récupérer l’image.',
        );
      }

      final Uint8List bytes =
          response.bodyBytes;

      await Gal.putImageBytes(
        bytes,
        name:
        'AI_Interior_Design_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Image enregistrée dans votre galerie.',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'ERREUR TELECHARGEMENT : $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Impossible d’enregistrer l’image : $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          telechargement = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,

        title: Text(
          'Votre intérieur',
          style:
          GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

        actions: [
          IconButton(
            onPressed: telechargement
                ? null
                : telechargerImage,
            icon: telechargement
                ? const SizedBox(
              width: 20,
              height: 20,
              child:
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Icon(
              Icons.download_rounded,
            ),
            tooltip: 'Télécharger',
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SizedBox.expand(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          panEnabled: true,
          scaleEnabled: true,

          child: Image.network(
            widget.imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,

            loadingBuilder:
                (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return const Center(
                child:
                CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            },

            errorBuilder:
                (context, error, stackTrace) {
              return Center(
                child: Padding(
                  padding:
                  const EdgeInsets.all(30),
                  child: Text(
                    'Impossible de charger l’image.',
                    textAlign:
                    TextAlign.center,
                    style:
                    GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}