import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'photo_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Palette de couleurs
  static const Color creamColor = Color(0xFFF5EEDC);
  static const Color accentYellow = Color(0xFFE3A812);
  static const Color darkGreen = Color(0xFF102A27);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Image de fond plein écran
          Image.asset(
            'assets/images/interior1.jpg',
            fit: BoxFit.cover,
          ),

          // 2. Filtre sombre pour garantir la lisibilité du texte
          Container(
            color: Colors.black.withOpacity(0.30),
          ),

          // 3. Contenu principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Nom de la marque (Ancrage en haut)
                  Text(
                    'A I   I N T E R I O R   D E S I G N',
                    style: TextStyle(
                      color: creamColor.withOpacity(0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Slogan principal (Police Serif éditoriale)
                  Text(
                    'Imaginez votre\nchez-vous autrement',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      color: creamColor,
                      fontSize: 36,
                      height: 1.15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Une photo suffit pour révéler tout le potentiel de votre intérieur.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: creamColor.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  // Espaceur dynamique pour caler le bouton en bas
                  const Spacer(),

                  // Bouton CTA principal
                  SizedBox(
                    width: 280,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PhotoPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentYellow,
                        foregroundColor: darkGreen, // Texte vert foncé pour un contraste optimal
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Commencer l'expérience",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.arrow_forward,
                            size: 19,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}