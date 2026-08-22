import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'resultat_page.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;


class GenerationPage extends StatefulWidget {
  final File imageAvant;
  final String piece;
  final String style;
  final String couleur;

  const GenerationPage({
    super.key,
    required this.imageAvant,
    required this.piece,
    required this.style,
    required this.couleur,
  });

  @override
  State<GenerationPage> createState() => _GenerationPageState();
}

class _GenerationPageState extends State<GenerationPage>
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

  Timer? timer;

  // ============================================================
  // ANIMATION
  // ============================================================

  late AnimationController animationController;

  // ============================================================
  // ÉTAPES DE GÉNÉRATION
  // ============================================================

  final List<String> etapes = [
    'Analyse de votre espace',
    'Harmonisation des couleurs',
    'Création de votre ambiance',
    'Finalisation de votre intérieur',
  ];

  int etapeActuelle = 0;

  Map<String, dynamic>? resultatIA;
  bool generationTerminee = false;

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
    timer?.cancel();

    try {
      timer = Timer.periodic(
        const Duration(milliseconds: 100),
            (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }

          setState(() {
            progression =
                (progression + 0.005).clamp(0.0, 0.90);

            if (progression < 0.25) {
              etapeActuelle = 0;
            } else if (progression < 0.50) {
              etapeActuelle = 1;
            } else if (progression < 0.75) {
              etapeActuelle = 2;
            } else {
              etapeActuelle = 3;
            }
          });
        },
      );

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://ai-interior-designer-api.vercel.app/api/design/generate',
        ),
      );

      // ==========================================================
      // PHOTO ORIGINALE
      // ==========================================================

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          widget.imageAvant.path,
        ),
      );

      // ==========================================================
      // PARAMÈTRES
      // ==========================================================

      request.fields['room_type'] = widget.piece;
      request.fields['style'] = widget.style;
      request.fields['color_scheme'] = widget.couleur;

      // IMPORTANT :
      // Le backend actuel ne gère pas encore le meuble sélectionné.
      request.fields['furniture'] = '';

      debugPrint('========== GENERATION ==========');
      debugPrint('Image : ${widget.imageAvant.path}');
      debugPrint('Pièce : ${widget.piece}');
      debugPrint('Style : ${widget.style}');
      debugPrint('Couleur : ${widget.couleur}');
      debugPrint('Furniture envoyé : ""');

      // ==========================================================
      // ENVOI
      // ==========================================================

      final response = await request.send();

      final responseBody =
      await response.stream.bytesToString();

      debugPrint('========== REPONSE BACKEND ==========');
      debugPrint(responseBody);
      debugPrint('=====================================');

      if (!mounted) return;

      // ==========================================================
      // ERREUR HTTP
      // ==========================================================

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        timer?.cancel();

        String message =
            'Erreur lors de la génération.';

        try {
          final errorJson =
          jsonDecode(responseBody);

          if (errorJson is Map &&
              errorJson['detail'] != null) {
            message =
                errorJson['detail'].toString();
          }
        } catch (_) {}

        throw Exception(message);
      }

      // ==========================================================
      // JSON
      // ==========================================================

      final decoded = jsonDecode(responseBody);

      if (decoded is! Map) {
        throw Exception(
          'Réponse du serveur invalide.',
        );
      }

      // On garde toute la réponse
      final resultatIA =
      Map<String, dynamic>.from(decoded);

      debugPrint(
        'RESULTAT IA = $resultatIA',
      );

      // ==========================================================
      // IMAGE GÉNÉRÉE
      // ==========================================================

      final result = resultatIA['result'];

      if (result is Map) {
        debugPrint(
          'GENERATED IMAGE URL = '
              '${result['generated_image_url']}',
        );
      }

      timer?.cancel();

      setState(() {
        progression = 1.0;
        etapeActuelle = 3;
      });

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      // ==========================================================
      // RETOUR VERS RESULTAT PAGE
      // ==========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultatPage(
            imageAvant: File(widget.imageAvant.path),
            piece: widget.piece,
            style: widget.style,
            couleur: widget.couleur,
            resultatIA: resultatIA,
          ),
        ),
      );
    } catch (e, stackTrace) {
      timer?.cancel();

      debugPrint(
        '====================================',
      );
      debugPrint(
        'ERREUR GENERATION : $e',
      );
      debugPrint(
        'STACK TRACE :',
      );
      debugPrint(
        stackTrace.toString(),
      );
      debugPrint(
        '====================================',
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: backgroundColor,
            title: Text(
              'Erreur',
              style:
              GoogleFonts.playfairDisplay(
                color: creamColor,
                fontSize: 22,
              ),
            ),
            content: Text(
              e.toString().replaceFirst(
                'Exception: ',
                '',
              ),
              style:
              GoogleFonts.plusJakartaSans(
                color: secondaryText,
                fontSize: 13,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
                  style:
                  GoogleFonts.plusJakartaSans(
                    color: accentYellow,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }
  @override
  void dispose() {
    timer?.cancel();
    animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: Stack(
        fit: StackFit.expand,
        children: [

          // ====================================================
          // IMAGE DE FOND
          // ====================================================

          Image.asset(
            'assets/images/interior2.jpg',
            fit: BoxFit.cover,
          ),

          // ====================================================
          // VOILE SOMBRE
          // ====================================================

          Container(
            color: backgroundColor.withOpacity(0.82),
          ),

          // ====================================================
          // CONTENU
          // ====================================================

          SafeArea(
            child: Column(
              children: [

                // ====================================================
                // HEADER
                // ====================================================

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [

                      IconButton(
                        onPressed: () {
                          timer?.cancel();
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
                ),

                // ====================================================
                // CONTENU CENTRAL
                // ====================================================

                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 35,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          // ==================================================
                          // ICÔNE ANIMÉE
                          // ==================================================

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
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: accentYellow.withOpacity(0.35),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accentYellow.withOpacity(0.10),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: accentYellow,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 42),

                          // ==================================================
                          // TITRE
                          // ==================================================

                          Text(
                            'Votre intérieur\nprend vie',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              color: creamColor,
                              fontSize: 34,
                              height: 1.15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ==================================================
                          // DESCRIPTION
                          // ==================================================

                          Text(
                            'Notre intelligence artificielle imagine '
                                'un espace qui vous ressemble.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              color: secondaryText,
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 42),

                          // ==================================================
                          // ÉTAPE ACTUELLE
                          // ==================================================

                          AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 300,
                            ),
                            child: Text(
                              etapes[etapeActuelle],
                              key: ValueKey(etapeActuelle),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                color: creamColor.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ==================================================
                          // BARRE DE PROGRESSION
                          // ==================================================

                          SizedBox(
                            width: 260,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progression,
                                minHeight: 4,
                                backgroundColor: borderColor,
                                valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                  accentYellow,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ==================================================
                          // POURCENTAGE
                          // ==================================================

                          Text(
                            '${(progression * 100).toInt()}%',
                            style: GoogleFonts.plusJakartaSans(
                              color: secondaryText.withOpacity(0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ====================================================
                // BAS DE PAGE
                // ====================================================

                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 25,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentYellow,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        'Création personnalisée par IA',
                        style: GoogleFonts.plusJakartaSans(
                          color: secondaryText.withOpacity(0.55),
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
}