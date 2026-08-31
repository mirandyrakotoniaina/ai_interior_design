import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MeubleGenerationPage extends StatefulWidget {
  final String piece;
  final String style;
  final String couleur;
  final String meuble;
  final String description;

  // Image "Après" générée par l'IA depuis ResultatPage
  final dynamic imageUrl;

  const MeubleGenerationPage({
    super.key,
    required this.piece,
    required this.style,
    required this.couleur,
    required this.meuble,
    required this.description,
    required this.imageUrl,
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
  static const Color cardColor = Color(0xFF183C34);
  static const Color accentYellow = Color(0xFFE3A812);
  static const Color creamColor = Color(0xFFF5EEDC);
  static const Color secondaryText = Color(0xFFD5D0C2);
  static const Color borderColor = Color(0xFF2A5148);

  // ============================================================
  // PROGRESSION
  // ============================================================

  double progression = 0;

  // ============================================================
  // IMAGE GÉNÉRÉE PAR LE BACKEND
  // ============================================================

  String? imageGeneree;

  // ============================================================
  // DONNÉES DES MEUBLES
  // ============================================================

  List<Map<String, dynamic>> meubles = [];

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
  // GÉNÉRATION
  // ============================================================

  Future<void> lancerGeneration() async {
    try {
      if (!mounted) return;

      setState(() {
        progression = 0.05;
        etapeActuelle = 0;
        imageGeneree = null;
        meubles = [];
      });

      final uri = Uri.parse(
        'https://ai-interior-designer-api.vercel.app/api/design/generate',
      );

      final request = http.MultipartRequest(
        'POST',
        uri,
      );

      // ==========================================================
      // IMAGE "APRÈS" DE RESULTATPAGE
      // ==========================================================

      debugPrint(
        '========== IMAGE DE RÉFÉRENCE ==========',
      );

      debugPrint(
        'Image générée reçue : ${widget.imageUrl}',
      );

      if (widget.imageUrl == null ||
          widget.imageUrl.toString().trim().isEmpty) {
        throw Exception(
          'L’image générée est introuvable.',
        );
      }

      final imageUrl = widget.imageUrl.toString().trim();

      final imageResponse = await http.get(
        Uri.parse(imageUrl),
      );

      if (imageResponse.statusCode != 200) {
        throw Exception(
          'Impossible de récupérer l’image générée. '
              'Code HTTP : ${imageResponse.statusCode}',
        );
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageResponse.bodyBytes,
          filename: 'image_apres.jpg',
        ),
      );

      debugPrint(
        'Image "Après" ajoutée à la requête.',
      );

      // ==========================================================
      // PARAMÈTRES
      // ==========================================================

      request.fields['room_type'] = widget.piece;
      request.fields['style'] = widget.style;
      request.fields['color_scheme'] = widget.couleur;
      request.fields['furniture'] = widget.meuble;

      request.fields['session_id'] =
          DateTime.now().millisecondsSinceEpoch.toString();

      // ==========================================================
      // PROGRESSION
      // ==========================================================

      if (mounted) {
        setState(() {
          progression = 0.20;
          etapeActuelle = 0;
        });
      }

      // ==========================================================
      // DEBUG
      // ==========================================================

      debugPrint(
        '========== ENVOI BACKEND MEUBLE ==========',
      );

      debugPrint(
        'URL: $uri',
      );

      debugPrint(
        'Image source: IMAGE APRÈS',
      );

      debugPrint(
        'Image URL: $imageUrl',
      );

      debugPrint(
        'Pièce: ${widget.piece}',
      );

      debugPrint(
        'Style: ${widget.style}',
      );

      debugPrint(
        'Couleur: ${widget.couleur}',
      );

      debugPrint(
        'Meuble: ${widget.meuble}',
      );

      debugPrint(
        'Session ID: ${request.fields['session_id']}',
      );

      // ==========================================================
      // ENVOI
      // ==========================================================

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

      // ==========================================================
      // REPONSE BACKEND
      // ==========================================================

      debugPrint(
        '========== REPONSE BACKEND ==========',
      );

      debugPrint(
        response.statusCode.toString(),
      );

      debugPrint(
        response.body,
      );

      debugPrint(
        '=====================================',
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Erreur backend ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception(
          'Réponse backend invalide.',
        );
      }

      final Map<String, dynamic> data =
      Map<String, dynamic>.from(decoded);

      if (mounted) {
        setState(() {
          progression = 0.70;
          etapeActuelle = 2;
        });
      }

      // ==========================================================
      // RESULT
      // ==========================================================

      final dynamic resultData = data['result'];

      Map<String, dynamic>? result;

      if (resultData is Map) {
        result = Map<String, dynamic>.from(
          resultData,
        );
      }

      // ==========================================================
      // IMAGE GÉNÉRÉE
      // ==========================================================

      String? generatedUrl;

      // Première priorité :
      // result.generated_image_url
      if (result != null) {
        final value =
        result['generated_image_url'];

        if (value is String &&
            value.trim().isNotEmpty) {
          generatedUrl = value.trim();
        }
      }

      // Deuxième priorité :
      // data.generated_image_url
      if (generatedUrl == null) {
        final value =
        data['generated_image_url'];

        if (value is String &&
            value.trim().isNotEmpty) {
          generatedUrl = value.trim();
        }
      }

      debugPrint(
        'GENERATED IMAGE URL = $generatedUrl',
      );

      if (generatedUrl == null ||
          generatedUrl.isEmpty) {
        throw Exception(
          'Le backend n’a pas retourné generated_image_url.',
        );
      }

      // ==========================================================
      // RECUPERATION DES MEUBLES
      // ==========================================================

      final marketOffers =
      data['market_offers'];

      if (marketOffers is List) {
        meubles = marketOffers
            .whereType<Map>()
            .map<Map<String, dynamic>>(
              (item) =>
          Map<String, dynamic>.from(item),
        )
            .toList();
      } else {
        meubles = [];
      }

      // ==========================================================
      // DEBUG MEUBLES
      // ==========================================================

      debugPrint(
        '========== MEUBLES RECUPERES ==========',
      );

      debugPrint(
        'Nombre de meubles : ${meubles.length}',
      );

      for (final meubleData in meubles) {
        debugPrint(
          'Meuble : ${meubleData['furniture']}',
        );

        debugPrint(
          'Crop : ${meubleData['crop_image_url']}',
        );

        debugPrint(
          'Prix : ${meubleData['estimated_price']}',
        );
      }

      // ==========================================================
      // FIN
      // ==========================================================

      if (!mounted) return;

      setState(() {
        // IMPORTANT :
        // On remplace l'image "Après" par la nouvelle
        // image générée pour le meuble.
        imageGeneree = generatedUrl;

        progression = 1.0;
        etapeActuelle = 3;
      });

      debugPrint(
        'IMAGE GENEREE = $imageGeneree',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '========== ERREUR GENERATION ==========',
      );

      debugPrint(
        e.toString(),
      );

      debugPrint(
        stackTrace.toString(),
      );

      debugPrint(
        '=======================================',
      );

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
    final pourcentage =
    (progression * 100).toInt();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ======================================================
          // FOND
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
                color:
                accentYellow.withOpacity(0.035),
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
                color:
                Colors.white.withOpacity(0.018),
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
                  padding:
                  const EdgeInsets.symmetric(
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
                          Icons
                              .arrow_back_ios_new_rounded,
                          color: creamColor,
                          size: 19,
                        ),
                      ),

                      Expanded(
                        child: Center(
                          child: Text(
                            'AI INTERIOR DESIGN',
                            style: GoogleFonts
                                .plusJakartaSans(
                              color: creamColor
                                  .withOpacity(0.85),
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w600,
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
                      padding:
                      const EdgeInsets.symmetric(
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
                                  animationController
                                      .value *
                                      2 *
                                      3.14159,
                                  child: child,
                                );
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration:
                                BoxDecoration(
                                  shape:
                                  BoxShape.circle,
                                  border: Border.all(
                                    color:
                                    accentYellow
                                        .withOpacity(
                                        0.35),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 68,
                                    height: 68,
                                    decoration:
                                    BoxDecoration(
                                      shape: BoxShape
                                          .circle,
                                      color:
                                      accentYellow
                                          .withOpacity(
                                          0.10),
                                    ),
                                    child:
                                    const Icon(
                                      Icons
                                          .auto_awesome_rounded,
                                      color:
                                      accentYellow,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 32,
                            ),

                            // ======================================
                            // TITRE
                            // ======================================

                            Text(
                              'Création de votre\n${widget.meuble}',
                              textAlign:
                              TextAlign.center,
                              style: GoogleFonts
                                  .playfairDisplay(
                                color: creamColor,
                                fontSize: 32,
                                height: 1.15,
                                fontWeight:
                                FontWeight.w500,
                              ),
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            // ======================================
                            // DESCRIPTION
                            // ======================================

                            Text(
                              widget.description,
                              textAlign:
                              TextAlign.center,
                              style: GoogleFonts
                                  .plusJakartaSans(
                                color:
                                secondaryText,
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(
                              height: 26,
                            ),

                            // ======================================
                            // INFORMATIONS
                            // ======================================

                            Padding(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceEvenly,
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

                            const SizedBox(
                              height: 30,
                            ),

                            // ======================================
                            // IMAGE
                            // ======================================

                            _zoneImage(),

                            // ======================================
                            // MEUBLES
                            // ======================================

                            if (progression >= 1.0 &&
                                meubles.isNotEmpty) ...[
                              const SizedBox(
                                height: 35,
                              ),

                              _sectionTitre(
                                'MEUBLES DE VOTRE PIÈCE',
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              ...meubles.map(
                                    (meubleData) =>
                                    _carteMeuble(
                                      meubleData,
                                    ),
                              ),
                            ],

                            const SizedBox(
                              height: 28,
                            ),

                            // ======================================
                            // ÉTAPE
                            // ======================================

                            AnimatedSwitcher(
                              duration:
                              const Duration(
                                milliseconds: 300,
                              ),
                              child: Text(
                                etapes[
                                etapeActuelle],
                                key: ValueKey(
                                  etapeActuelle,
                                ),
                                textAlign:
                                TextAlign.center,
                                style: GoogleFonts
                                    .plusJakartaSans(
                                  color: creamColor
                                      .withOpacity(
                                      0.9),
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // ======================================
                            // BARRE
                            // ======================================

                            SizedBox(
                              width: 260,
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius
                                    .circular(10),
                                child:
                                LinearProgressIndicator(
                                  value:
                                  progression,
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

                            const SizedBox(
                              height: 12,
                            ),

                            // ======================================
                            // POURCENTAGE
                            // ======================================

                            Text(
                              '$pourcentage%',
                              style: GoogleFonts
                                  .plusJakartaSans(
                                color:
                                secondaryText
                                    .withOpacity(
                                    0.7),
                                fontSize: 11,
                                fontWeight:
                                FontWeight.w500,
                              ),
                            ),

                            const SizedBox(
                              height: 22,
                            ),

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
                                style: GoogleFonts
                                    .plusJakartaSans(
                                  color:
                                  secondaryText
                                      .withOpacity(
                                      0.65),
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
                // BAS
                // ==================================================

                Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 25,
                  ),
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
                        style: GoogleFonts
                            .plusJakartaSans(
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
  // ZONE IMAGE
  // ============================================================

  Widget _zoneImage() {
    // IMPORTANT :
    // Pendant la génération, on affiche l'image "Après"
    // reçue de ResultatPage.
    //
    // Une fois la génération terminée, imageGeneree contient
    // la nouvelle image retournée par le backend.

    final String? urlAAfficher =
        imageGeneree ??
            (widget.imageUrl != null &&
                widget.imageUrl
                    .toString()
                    .trim()
                    .isNotEmpty
                ? widget.imageUrl
                .toString()
                .trim()
                : null);

    if (urlAAfficher == null) {
      return _placeholderImage();
    }

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(22),
      child: Image.network(
        urlAAfficher,
        width: double.infinity,
        height: 220,
        fit: BoxFit.contain,
        loadingBuilder:
            (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return _placeholderImage();
        },
        errorBuilder:
            (context, error, stackTrace) {
          debugPrint(
            'ERREUR IMAGE MEUBLE : $error',
          );

          debugPrint(
            'URL IMAGE MEUBLE : $urlAAfficher',
          );

          return _placeholderImage();
        },
      ),
    );
  }

  // ============================================================
  // PLACEHOLDER IMAGE
  // ============================================================

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        color:
        cardColor.withOpacity(0.45),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
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
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                  accentYellow.withOpacity(
                      0.35),
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
            style:
            GoogleFonts.plusJakartaSans(
              color: creamColor,
              fontSize: 12,
              fontWeight:
              FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'L’image générée apparaîtra ici',
            textAlign: TextAlign.center,
            style:
            GoogleFonts.plusJakartaSans(
              color:
              secondaryText.withOpacity(
                  0.55),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TITRE SECTION
  // ============================================================

  Widget _sectionTitre(String titre) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: borderColor,
          ),
        ),

        Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          child: Text(
            titre,
            style:
            GoogleFonts.plusJakartaSans(
              color:
              creamColor.withOpacity(
                  0.75),
              fontSize: 10,
              fontWeight:
              FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),

        Expanded(
          child: Container(
            height: 1,
            color: borderColor,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CARTE MEUBLE
  // ============================================================

  Widget _carteMeuble(
      Map<String, dynamic> meubleData) {
    final String nom =
    (meubleData['furniture'] ??
        'Meuble')
        .toString();

    final cropData = meubleData['crop_image_url'];

    String? cropUrl;

    if (cropData is Map) {
      final url = cropData['url'];

      if (url is String && url.trim().isNotEmpty) {
        cropUrl = url.trim();
      }
    }

    final String prix =
    (meubleData['estimated_price'] ??
        'Prix non disponible')
        .toString();

    final stores =
    meubleData['stores'] is List
        ? meubleData['stores'] as List
        : [];

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 18,
      ),
      decoration: BoxDecoration(
        color:
        cardColor.withOpacity(0.55),
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ==================================================
            // IMAGE DU MEUBLE
            // ==================================================

            ClipRRect(
              borderRadius:
              BorderRadius.circular(14),
              child: cropUrl != null &&
                  cropUrl.isNotEmpty
                  ? Image.network(
                cropUrl,
                width:
                double.infinity,
                height: 170,
                fit: BoxFit.contain,
                errorBuilder:
                    (context,
                    error,
                    stackTrace) {
                  return _imageMeublePlaceholder(
                    nom,
                  );
                },
              )
                  : _imageMeublePlaceholder(
                nom,
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // NOM
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: Text(
                    nom,
                    style: GoogleFonts
                        .playfairDisplay(
                      color: creamColor,
                      fontSize: 23,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ),

                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration:
                  BoxDecoration(
                    color: accentYellow
                        .withOpacity(0.12),
                    borderRadius:
                    BorderRadius.circular(
                        20),
                    border: Border.all(
                      color: accentYellow
                          .withOpacity(
                          0.25),
                    ),
                  ),
                  child: Icon(
                    _getIconForMeuble(
                      nom,
                    ),
                    color:
                    accentYellow,
                    size: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ==================================================
            // PRIX
            // ==================================================

            Text(
              'PRIX ESTIMÉ',
              style:
              GoogleFonts.plusJakartaSans(
                color: secondaryText
                    .withOpacity(0.55),
                fontSize: 9,
                fontWeight:
                FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              prix,
              style:
              GoogleFonts.plusJakartaSans(
                color: creamColor,
                fontSize: 12,
                height: 1.5,
                fontWeight:
                FontWeight.w500,
              ),
            ),

            // ==================================================
            // MAGASINS
            // ==================================================

            if (stores.isNotEmpty) ...[
              const SizedBox(height: 18),

              Text(
                'OÙ L’ACHETER ?',
                style:
                GoogleFonts.plusJakartaSans(
                  color: secondaryText
                      .withOpacity(0.55),
                  fontSize: 9,
                  fontWeight:
                  FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 10),

              ...stores.map(
                    (store) =>
                    _storeItem(store),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PLACEHOLDER MEUBLE
  // ============================================================

  Widget _imageMeublePlaceholder(
      String nom) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForMeuble(nom),
            color:
            accentYellow.withOpacity(
                0.75),
            size: 38,
          ),

          const SizedBox(height: 10),

          Text(
            'Aperçu indisponible',
            style:
            GoogleFonts.plusJakartaSans(
              color: secondaryText,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAGASIN
  // ============================================================

  Widget _storeItem(dynamic store) {
    if (store is! Map) {
      return const SizedBox.shrink();
    }

    final String title =
    (store['title'] ?? 'Magasin')
        .toString();

    final String url =
    (store['url'] ?? '').toString();

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color:
        backgroundColor.withOpacity(
            0.55),
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(12),
        onTap: url.isEmpty
            ? null
            : () async {
          final uri =
          Uri.tryParse(url);

          if (uri == null) {
            return;
          }

          final success =
          await launchUrl(
            uri,
            mode: LaunchMode
                .externalApplication,
          );

          if (!success &&
              mounted) {
            ScaffoldMessenger
                .of(context)
                .showSnackBar(
              const SnackBar(
                content: Text(
                  'Impossible d’ouvrir ce site.',
                ),
              ),
            );
          }
        },
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration:
                BoxDecoration(
                  shape:
                  BoxShape.circle,
                  color: accentYellow
                      .withOpacity(0.10),
                ),
                child: const Icon(
                  Icons
                      .storefront_rounded,
                  color:
                  accentYellow,
                  size: 18,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: GoogleFonts
                      .plusJakartaSans(
                    color: creamColor,
                    fontSize: 11,
                    height: 1.35,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons
                    .arrow_forward_ios_rounded,
                color: secondaryText
                    .withOpacity(0.55),
                size: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ICÔNE MEUBLE
  // ============================================================

  IconData _getMeubleIcon() {
    return _getIconForMeuble(
      widget.meuble,
    );
  }

  IconData _getIconForMeuble(
      String meuble) {
    final nom =
    meuble.toLowerCase();

    // ============================
    // SALON
    // ============================

    if (nom.contains('canape') ||
        nom.contains('canape')) {
      return Icons.weekend_rounded;
    }

    if (nom.contains('fauteuil')) {
      return Icons.chair_rounded;
    }

    if (nom.contains('table basse')) {
      return Icons
          .table_restaurant_rounded;
    }

    if (nom.contains('meuble tv')) {
      return Icons.tv_rounded;
    }

    // ============================
    // CHAMBRE
    // ============================

    if (nom.contains('lit')) {
      return Icons.bed_rounded;
    }

    if (nom.contains('armoire')) {
      return Icons
          .door_sliding_rounded;
    }

    if (nom.contains('commode')) {
      return Icons
          .inventory_2_rounded;
    }

    // ============================
    // BUREAU
    // ============================

    if (nom.contains('bureau')) {
      return Icons.desk_rounded;
    }

    if (nom.contains('étagère') ||
        nom.contains('etagere')) {
      return Icons.shelves;
    }

    // ============================
    // CUISINE
    // ============================

    if (nom.contains('îlot') ||
        nom.contains('ilot')) {
      return Icons
          .table_restaurant_rounded;
    }

    if (nom.contains(
        'table de cuisine')) {
      return Icons
          .table_restaurant_rounded;
    }

    if (nom.contains(
        'table à manger') ||
        nom.contains('table a manger')) {
      return Icons
          .table_restaurant_rounded;
    }

    if (nom.contains(
        'meuble de cuisine')) {
      return Icons
          .kitchen_rounded;
    }

    if (nom.contains(
        'meuble de rangement')) {
      return Icons
          .kitchen_rounded;
    }

    if (nom.contains('buffet')) {
      return Icons.kitchen_rounded;
    }

    if (nom.contains('tabouret')) {
      return Icons.chair_rounded;
    }

    if (nom.contains('évier') ||
        nom.contains('evier')) {
      return Icons
          .water_drop_rounded;
    }

    // ============================
    // GÉNÉRAL
    // ============================

    if (nom.contains('chaise')) {
      return Icons.chair_rounded;
    }

    if (nom.contains('table')) {
      return Icons
          .table_restaurant_rounded;
    }

    return Icons.chair_alt_rounded;
  }

  // ============================================================
  // INFORMATIONS
  // ============================================================

  Widget _info(
      String titre,
      String valeur) {
    return Expanded(
      child: Column(
        children: [
          Text(
            titre,
            textAlign: TextAlign.center,
            style:
            GoogleFonts.plusJakartaSans(
              color: secondaryText
                  .withOpacity(0.55),
              fontSize: 9,
              fontWeight:
              FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            valeur,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style:
            GoogleFonts.plusJakartaSans(
              color: creamColor,
              fontSize: 13,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}