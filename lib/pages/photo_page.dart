
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'configuration_page.dart';

class PhotoPage extends StatefulWidget {
const PhotoPage({super.key});

@override
State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
static const Color creamColor = Color(0xFFF5EEDC);
static const Color accentYellow = Color(0xFFE3A812);
static const Color darkGreen = Color(0xFF102A27);
static const Color secondaryText = Color(0xFFD5D0C2);

final ImagePicker _picker = ImagePicker();

File? imageSelectionnee;

// ─────────────────────────────────
// PRENDRE UNE PHOTO
// ─────────────────────────────────

Future<void> prendrePhoto() async {
final XFile? image = await _picker.pickImage(
source: ImageSource.camera,
imageQuality: 85,
);

if (image != null) {
setState(() {
imageSelectionnee = File(image.path);
});
}
}

// ─────────────────────────────────
// CHOISIR DANS LA GALERIE
// ─────────────────────────────────

Future<void> choisirGalerie() async {
final XFile? image = await _picker.pickImage(
source: ImageSource.gallery,
imageQuality: 85,
);

if (image != null) {
setState(() {
imageSelectionnee = File(image.path);
});
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: Stack(
fit: StackFit.expand,
children: [
// ─────────────────────────────
// PHOTO D'ARRIÈRE-PLAN
// ─────────────────────────────

Image.asset(
'assets/images/interior3.jpg',
fit: BoxFit.cover,
),

// ─────────────────────────────
// VOILE SOMBRE
// ─────────────────────────────

Container(
color: Colors.black.withOpacity(0.55),
),

SafeArea(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 24),
child: Column(
children: [
const SizedBox(height: 12),

// ─────────────────────
// BARRE DU HAUT
// ─────────────────────

Row(
children: [
IconButton(
onPressed: () {
Navigator.pop(context);
},
icon: const Icon(
Icons.arrow_back_ios_new_rounded,
color: creamColor,
size: 20,
),
),

const Spacer(),

Text(
'A I  I N T E R I O R  D E S I G N',
style: TextStyle(
color: creamColor.withOpacity(0.85),
fontSize: 12,
fontWeight: FontWeight.w600,
letterSpacing: 2.5,
),
),

const Spacer(),

const SizedBox(width: 48),
],
),

const SizedBox(height: 20),

// ─────────────────────
// TITRE
// ─────────────────────

Text(
'Importez votre pièce',
textAlign: TextAlign.center,
style: GoogleFonts.playfairDisplay(
color: creamColor,
fontSize: 34,
height: 1.15,
fontWeight: FontWeight.w500,
),
),

const SizedBox(height: 10),

Padding(
padding: const EdgeInsets.symmetric(horizontal: 15),
child: Text(
'Ajoutez une photo de votre intérieur '
'pour commencer la transformation.',
textAlign: TextAlign.center,
style: GoogleFonts.plusJakartaSans(
color: secondaryText,
fontSize: 14,
height: 1.5,
),
),
),

const SizedBox(height: 150),

// ─────────────────────
// ZONE PHOTO
// ─────────────────────

  SizedBox(
    height: 330,
    width: double.infinity,
    child: imageSelectionnee == null
        ? Container(
      decoration: BoxDecoration(
        color: darkGreen.withOpacity(0.78),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: creamColor.withOpacity(0.25),
        ),
      ),
      child: _zoneVide(),
    )
        : _photoSelectionnee(),
  ),

  const SizedBox(height: 20),

// ─────────────────────
// BOUTONS PHOTO
// ─────────────────────

Row(
children: [
Expanded(
child: _photoButton(
icon: Icons.camera_alt_outlined,
label: 'Prendre une photo',
onPressed: prendrePhoto,
),
),

const SizedBox(width: 12),

Expanded(
child: _photoButton(
icon: Icons.photo_library_outlined,
label: 'Galerie',
onPressed: choisirGalerie,
),
),
],
),

const SizedBox(height: 80),

// ─────────────────────
// CONTINUER
// ─────────────────────

SizedBox(
width: 260,
height: 54,
child: ElevatedButton(
onPressed: imageSelectionnee == null
? null
    : () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
ConfigurationPage(
imageAvant: imageSelectionnee!,
),
),
);
},
style: ElevatedButton.styleFrom(
backgroundColor: accentYellow,
disabledBackgroundColor:
accentYellow.withOpacity(0.35),
foregroundColor: darkGreen,
disabledForegroundColor:
darkGreen.withOpacity(0.5),
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(30),
),
),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(
'Continuer',
style: GoogleFonts.playfairDisplay(
fontSize: 15,
fontWeight: FontWeight.w500,
),
),
const SizedBox(width: 10),
const Icon(
Icons.arrow_forward_rounded,
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

// ─────────────────────────────────
// ZONE VIDE
// ─────────────────────────────────

Widget _zoneVide() {
return Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Container(
width: 76,
height: 76,
decoration: BoxDecoration(
color: accentYellow.withOpacity(0.15),
shape: BoxShape.circle,
),
child: const Icon(
Icons.add_a_photo_outlined,
size: 34,
color: accentYellow,
),
),

const SizedBox(height: 20),

Text(
'Ajoutez une photo',
style: GoogleFonts.playfairDisplay(
color: creamColor,
fontSize: 21,
fontWeight: FontWeight.w500,
),
),

const SizedBox(height: 20),

Text(
'Une photo claire de votre pièce\n'
'donnera de meilleurs résultats.',
textAlign: TextAlign.center,
style: GoogleFonts.plusJakartaSans(
color: secondaryText,
fontSize: 12,
height: 1.5,
),
),
],
);
}

// ─────────────────────────────────
// PHOTO SÉLECTIONNÉE
// ─────────────────────────────────

Widget _photoSelectionnee() {
return Center(
child: ClipRRect(
borderRadius: BorderRadius.circular(26),
child: Container(
constraints: const BoxConstraints(
maxHeight: 430,
),
decoration: BoxDecoration(
color: darkGreen.withOpacity(0.78),
borderRadius: BorderRadius.circular(26),
border: Border.all(
color: creamColor.withOpacity(0.25),
),
),
child: Stack(
children: [
// ─────────────────────
// IMAGE ENTIÈRE
// ─────────────────────

Image.file(
imageSelectionnee!,
fit: BoxFit.contain,
),

// ─────────────────────
// BOUTON SUPPRIMER
// ─────────────────────

Positioned(
top: 12,
right: 12,
child: GestureDetector(
onTap: () {
setState(() {
imageSelectionnee = null;
});
},
child: Container(
width: 38,
height: 38,
decoration: const BoxDecoration(
color: Colors.black54,
shape: BoxShape.circle,
),
child: const Icon(
Icons.close,
color: Colors.white,
size: 20,
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

// ─────────────────────────────────
// BOUTON PHOTO
// ─────────────────────────────────

Widget _photoButton({
required IconData icon,
required String label,
required VoidCallback onPressed,
}) {
return SizedBox(
height: 52,
child: OutlinedButton.icon(
onPressed: onPressed,
icon: Icon(
icon,
size: 19,
color: creamColor,
),
label: Text(
label,
style: GoogleFonts.plusJakartaSans(
color: creamColor,
fontSize: 12,
fontWeight: FontWeight.w500,
),
),
style: OutlinedButton.styleFrom(
side: BorderSide(
color: creamColor.withOpacity(0.30),
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(26),
),
),
),
);
}
}

