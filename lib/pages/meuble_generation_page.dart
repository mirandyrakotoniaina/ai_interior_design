import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class MeubleGenerationPage extends StatefulWidget {
  final String piece;
  final String style;
  final String couleur;
  final String meuble;
  final String description;
  final String imagePath;

  const MeubleGenerationPage({
    super.key,
    required this.piece,
    required this.style,
    required this.couleur,
    required this.meuble,
    required this.description,
    required this.imagePath,
  });

  @override
  State<MeubleGenerationPage> createState() =>
      _MeubleGenerationPageState();
}

class _MeubleGenerationPageState extends State<MeubleGenerationPage>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // COULEURS DU THÈME
  // ============================================================

  static const Color backgroundColor = Color(0xFF102A27);
  static const Color accentYellow = Color(0xFFE3A812);
  static const Color creamColor = Color(0xFFF5EEDC);
  static const Color secondaryText = Color(0xFFD5D0C2);
  static const Color borderColor = Color(0xFF2A5148);

  // ============================================================
  // PROGRESSION
  // ============================================================

  double progression = 0;



  // ============================================================
  // IMAGE GÉNÉRÉE
  // ============================================================

  // Pour l'instant null.
  // Plus tard, FastAPI fournira l'URL de l'image ici.
  String? imageGeneree;

  // ============================================================
  // ANIMATION
  // ============================================================

  late AnimationController animationController;

  // ============================================================
  // ÉTAPES
  // ============================================================

  final List<String> etapes = [
    'Analyse de vos préférences',
    'Recherche du meuble idéal',
    'Création de votre meuble',
    'Finalisation du rendu',
  ];

  int etapeActuelle = 0;

  // ============================================================
  // INITIALISATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    lancerGeneration();
  }

  // ============================================================
  // GÉNÉRATION SIMULÉE
  // ============================================================

  Future<void> lancerGeneration() async {
    try {
      if (!mounted) return;

      setState(() {
        progression = 0.05;
        etapeActuelle = 0;
      });

      final uri = Uri.parse(
        'https://ai-interior-designer-api.vercel.app/api/design/generate',
      );

      final request = http.MultipartRequest('POST', uri);

      // Photo originale
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          widget.imagePath,
        ),
      );

      // Paramètres envoyés au backend
      request.fields['room_type'] = widget.piece;
      request.fields['style'] = widget.style;
      request.fields['color_scheme'] = widget.couleur;
      request.fields['furniture'] = widget.meuble;

      // Progression visuelle
      if (mounted) {
        setState(() {
          progression = 0.20;
          etapeActuelle = 0;
        });
      }

      debugPrint('========== ENVOI BACKEND ==========');
      debugPrint('URL: $uri');
      debugPrint('Image: ${widget.imagePath}');
      debugPrint('Pièce: ${widget.piece}');
      debugPrint('Style: ${widget.style}');
      debugPrint('Couleur: ${widget.couleur}');
      debugPrint('Meuble: ${widget.meuble}');

      final streamedResponse = await request.send();

      if (mounted) {
        setState(() {
          progression = 0.45;
          etapeActuelle = 1;
        });
      }

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint('========== REPONSE BACKEND ==========');
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      debugPrint('=====================================');

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Erreur backend ${response.statusCode}: ${response.body}',
        );
      }

      final data = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          progression = 0.70;
          etapeActuelle = 2;
        });
      }

      // ==========================================================
      // RÉCUPÉRATION DE L'IMAGE GÉNÉRÉE
      // ==========================================================

      final result = data['result'];

      final generatedUrl =
      result?['generated_image_url'];

      debugPrint(
        'GENERATED IMAGE URL = $generatedUrl',
      );

      if (generatedUrl == null ||
          generatedUrl.toString().isEmpty) {
        throw Exception(
          'Le backend n\'a pas retourné generated_image_url',
        );
      }

      if (!mounted) return;

      setState(() {
        imageGeneree = generatedUrl.toString();
        progression = 1.0;
        etapeActuelle = 3;
      });

      debugPrint(
        'IMAGE GENEREE = $imageGeneree',
      );
    } catch (e, stackTrace) {
      debugPrint('========== ERREUR GENERATION ==========');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('=======================================');

      if (!mounted) return;

      setState(() {
        progression = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de générer le meuble : $e',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final pourcentage = (progression * 100).toInt();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ======================================================
          // FOND VERT
          // ======================================================

          Container(
            color: backgroundColor,
          ),

          // ======================================================
          // EFFET DE PROFONDEUR
          // ======================================================

          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentYellow.withOpacity(0.035),
              ),
            ),
          ),

          Positioned(
            bottom: -150,
            left: -120,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.018),
              ),
            ),
          ),

          // ======================================================
          // CONTENU
          // ======================================================

          SafeArea(
            child: Column(
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
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
                            style:
                            GoogleFonts.plusJakartaSans(
                              color:
                              creamColor.withOpacity(0.85),
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
                ),

                // ==================================================
                // CONTENU CENTRAL
                // ==================================================

                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            // ======================================
                            // ICÔNE ANIMÉE
                            // ======================================

                            AnimatedBuilder(
                              animation:
                              animationController,
                              builder:
                                  (context, child) {
                                return Transform.rotate(
                                  angle:
                                  animationController.value *
                                      2 *
                                      3.14159,
                                  child: child,
                                );
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: accentYellow
                                        .withOpacity(0.35),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 68,
                                    height: 68,
                                    decoration:
                                    BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: accentYellow
                                          .withOpacity(0.10),
                                    ),
                                    child: const Icon(
                                      Icons
                                          .auto_awesome_rounded,
                                      color: accentYellow,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // ======================================
                            // TITRE
                            // ======================================

                            Text(
                              'Création de votre\n${widget.meuble}',
                              textAlign: TextAlign.center,
                              style:
                              GoogleFonts.playfairDisplay(
                                color: creamColor,
                                fontSize: 32,
                                height: 1.15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ======================================
                            // DESCRIPTION
                            // ======================================

                            Text(
                              widget.description,
                              textAlign: TextAlign.center,
                              style:
                              GoogleFonts.plusJakartaSans(
                                color: secondaryText,
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: 26),

                            // ======================================
                            // INFORMATIONS
                            // ======================================

                            Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  _info(
                                    'PIÈCE',
                                    widget.piece,
                                  ),
                                  _info(
                                    'STYLE',
                                    widget.style,
                                  ),
                                  _info(
                                    'COULEUR',
                                    widget.couleur,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // ======================================
                            // ZONE IMAGE GÉNÉRÉE
                            // ======================================

                            _zoneImage(),

                            const SizedBox(height: 28),

                            // ======================================
                            // ÉTAPE ACTUELLE
                            // ======================================

                            AnimatedSwitcher(
                              duration:
                              const Duration(
                                milliseconds: 300,
                              ),
                              child: Text(
                                etapes[etapeActuelle],
                                key: ValueKey(
                                  etapeActuelle,
                                ),
                                textAlign: TextAlign.center,
                                style:
                                GoogleFonts.plusJakartaSans(
                                  color: creamColor
                                      .withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ======================================
                            // BARRE DE PROGRESSION
                            // ======================================

                            SizedBox(
                              width: 260,
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(10),
                                child:
                                LinearProgressIndicator(
                                  value: progression,
                                  minHeight: 4,
                                  backgroundColor:
                                  borderColor,
                                  valueColor:
                                  const AlwaysStoppedAnimation<
                                      Color>(
                                    accentYellow,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ======================================
                            // POURCENTAGE
                            // ======================================

                            Text(
                              '$pourcentage%',
                              style:
                              GoogleFonts.plusJakartaSans(
                                color: secondaryText
                                    .withOpacity(0.7),
                                fontSize: 11,
                                fontWeight:
                                FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 22),

                            // ======================================
                            // MESSAGE FINAL
                            // ======================================

                            AnimatedOpacity(
                              duration:
                              const Duration(
                                milliseconds: 400,
                              ),
                              opacity:
                              progression >= 1.0
                                  ? 1
                                  : 0,
                              child: Text(
                                'Votre meuble est prêt à prendre vie.',
                                textAlign:
                                TextAlign.center,
                                style:
                                GoogleFonts.plusJakartaSans(
                                  color: secondaryText
                                      .withOpacity(0.65),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // BAS DE PAGE
                // ==================================================

                Padding(
                  padding:
                  const EdgeInsets.only(bottom: 25),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration:
                        const BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentYellow,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Création personnalisée par IA',
                        style:
                        GoogleFonts.plusJakartaSans(
                          color: secondaryText
                              .withOpacity(0.55),
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ZONE DE L'IMAGE
  // ============================================================

  Widget _zoneImage() {
    if (imageGeneree != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.network(
          imageGeneree!,
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _placeholderImage();
          },
        ),
      );
    }

    return _placeholderImage();
  }

  // ============================================================
  // PLACEHOLDER IMAGE
  // ============================================================

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        color: const Color(0xFF183C34).withOpacity(0.45),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cercle animé
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle:
                animationController.value *
                    2 *
                    3.14159,
                child: child,
              );
            },
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentYellow.withOpacity(0.35),
                ),
              ),
              child: Icon(
                _getMeubleIcon(),
                color: accentYellow,
                size: 27,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Votre meuble prend forme...',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: creamColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'L’image générée apparaîtra ici',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: secondaryText.withOpacity(0.55),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
  IconData _getMeubleIcon() {
    final meuble = widget.meuble.toLowerCase();

    // ============================
    // SALON
    // ============================

    if (meuble.contains('canapé') ||
        meuble.contains('canape')) {
      return Icons.weekend_rounded;
    }

    if (meuble.contains('fauteuil')) {
      return Icons.chair_rounded;
    }

    if (meuble.contains('table basse')) {
      return Icons.table_restaurant_rounded;
    }

    if (meuble.contains('meuble tv')) {
      return Icons.tv_rounded;
    }

    // ============================
    // CHAMBRE
    // ============================

    if (meuble.contains('lit')) {
      return Icons.bed_rounded;
    }

    if (meuble.contains('armoire')) {
      return Icons.door_sliding_rounded;
    }

    if (meuble.contains('commode')) {
      return Icons.inventory_2_rounded;
    }

    // ============================
    // BUREAU
    // ============================

    if (meuble.contains('bureau')) {
      return Icons.desk_rounded;
    }

    if (meuble.contains('étagère') ||
        meuble.contains('etagere')) {
      return Icons.shelves;
    }

    // ============================
    // CUISINE
    // ============================

    if (meuble.contains('îlot') ||
        meuble.contains('ilot')) {
      return Icons.table_restaurant_rounded;
    }

    if (meuble.contains('table de cuisine')) {
      return Icons.table_restaurant_rounded;
    }

    if (meuble.contains('meuble de cuisine')) {
      return Icons.kitchen_rounded;
    }

    if (meuble.contains('buffet')) {
      return Icons.kitchen_rounded;
    }

    if (meuble.contains('tabouret')) {
      return Icons.chair_rounded;
    }

    if (meuble.contains('évier') ||
        meuble.contains('evier')) {
      return Icons.water_drop_rounded;
    }

    // ============================
    // GÉNÉRAL
    // ============================

    if (meuble.contains('chaise')) {
      return Icons.chair_rounded;
    }

    if (meuble.contains('table')) {
      return Icons.table_restaurant_rounded;
    }

    // Icône par défaut
    return Icons.chair_alt_rounded;
  }



  // ============================================================
  // INFORMATIONS
  // ============================================================

  Widget _info(String titre, String valeur) {
    return Expanded(
      child: Column(
        children: [
          Text(
            titre,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: secondaryText.withOpacity(0.55),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            valeur,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: creamColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}