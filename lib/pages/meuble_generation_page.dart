
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class MeubleGenerationPage extends StatefulWidget {
final String piece;
final String style;
final String couleur;
final String meuble;
final String description;

final String? estimatedPrice;
final List<dynamic> stores;

const MeubleGenerationPage({
super.key,
required this.piece,
required this.style,
required this.couleur,
required this.meuble,
required this.description,
this.estimatedPrice,
this.stores = const [],
});

@override
State<MeubleGenerationPage> createState() =>
_MeubleGenerationPageState();
}

class _MeubleGenerationPageState
extends State<MeubleGenerationPage> {

// ============================================================
// COULEURS
// ============================================================

static const Color backgroundColor =
Color(0xFF102A27);

static const Color cardColor =
Color(0xFF183C34);

static const Color accentYellow =
Color(0xFFE3A812);

static const Color creamColor =
Color(0xFFF5EEDC);

static const Color secondaryText =
Color(0xFFD5D0C2);

static const Color borderColor =
Color(0xFF2A5148);

// ============================================================
// DONNÉES
// ============================================================

late String prix;
late List<dynamic> stores;

// ============================================================
// INITIALISATION
// ============================================================

@override
void initState() {
super.initState();

// recupere les donnees retournees

prix = widget.estimatedPrice != null &&
widget.estimatedPrice!.trim().isNotEmpty
? widget.estimatedPrice!.trim()
    : 'Prix non disponible';

stores = List<dynamic>.from(widget.stores);

debugPrint(
'========== MEUBLE GENERATION ==========',
);

debugPrint(
'Meuble : ${widget.meuble}',
);

debugPrint(
'Prix : $prix',
);

debugPrint(
'Nombre de magasins : ${stores.length}',
);

debugPrint(
'=======================================',
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
child: Column(
children: [

// ==================================================
// HEADER
// ==================================================

Padding(
padding: const EdgeInsets.fromLTRB(
18,
8,
18,
8,
),

child: Row(
children: [

Container(
width: 42,
height: 42,

decoration: BoxDecoration(
shape: BoxShape.circle,
color: creamColor.withOpacity(0.05),
border: Border.all(
color: borderColor,
),
),

child: IconButton(
padding: EdgeInsets.zero,

onPressed: () {
Navigator.pop(context);
},

icon: const Icon(
Icons.arrow_back_ios_new_rounded,
color: creamColor,
size: 17,
),
),
),

Expanded(
child: Center(
child: Column(
children: [

Text(
'AI INTERIOR DESIGN',
style:
GoogleFonts.plusJakartaSans(
color:
creamColor.withOpacity(0.85),
fontSize: 10,
fontWeight: FontWeight.w600,
letterSpacing: 2.2,
),
),

const SizedBox(height: 3),

Container(
width: 24,
height: 1,
color: accentYellow.withOpacity(0.7),
),
],
),
),
),

const SizedBox(
width: 42,
),
],
),
),

// ==================================================
// CONTENU
// ==================================================

Expanded(
child: SingleChildScrollView(
physics: const BouncingScrollPhysics(),

padding: const EdgeInsets.fromLTRB(
22,
18,
22,
35,
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment.stretch,

children: [

// ==========================================
// PETIT LABEL
// ==========================================

Center(
child: Row(
mainAxisSize: MainAxisSize.min,
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
'SÉLECTION INTÉRIEURE',
style:
GoogleFonts.plusJakartaSans(
color: accentYellow,
fontSize: 9,
fontWeight: FontWeight.w600,
letterSpacing: 1.6,
),
),
],
),
),

const SizedBox(height: 14),

// ==========================================
// TITRE
// ==========================================

Text(
widget.meuble,
textAlign: TextAlign.center,

style:
GoogleFonts.playfairDisplay(
color: creamColor,
fontSize: 36,
height: 1.1,
fontWeight: FontWeight.w500,
),
),

const SizedBox(height: 12),

// ==========================================
// DESCRIPTION
// ==========================================

Padding(
padding: const EdgeInsets.symmetric(
horizontal: 12,
),

child: Text(
widget.description,
textAlign: TextAlign.center,

style:
GoogleFonts.plusJakartaSans(
color: secondaryText
    .withOpacity(0.78),
fontSize: 12,
height: 1.65,
),
),
),

const SizedBox(height: 24),

// ==========================================
// INFORMATIONS
// ==========================================

_infosCard(),

const SizedBox(height: 24),

// ==========================================
// IMAGE
// ==========================================

_imageMeuble(),

const SizedBox(height: 30),

// ==========================================
// PRIX
// ==========================================

_sectionTitre('PRIX'),

const SizedBox(height: 14),

_cartePrix(),

const SizedBox(height: 30),

// ==========================================
// MAGASINS
// ==========================================

_sectionTitre('OÙ L’ACHETER ?'),

const SizedBox(height: 8),

Text(
'Retrouvez ce meuble auprès de nos sélections partenaires.',
textAlign: TextAlign.center,

style:
GoogleFonts.plusJakartaSans(
color: secondaryText.withOpacity(0.55),
fontSize: 10,
height: 1.5,
),
),

const SizedBox(height: 16),

if (stores.isNotEmpty)
...stores.map(
(store) => _storeItem(store),
)
else
_aucunMagasin(),

const SizedBox(height: 12),

// ==========================================
// NOTE
// ==========================================

Text(
'Les prix sont indicatifs et peuvent varier selon le magasin.',
textAlign: TextAlign.center,

style:
GoogleFonts.plusJakartaSans(
color: secondaryText.withOpacity(0.38),
fontSize: 9,
height: 1.5,
),
),
],
),
),
),

// ==================================================
// BAS DE PAGE
// ==================================================

Padding(
padding: const EdgeInsets.only(
bottom: 18,
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
'Une sélection adaptée à votre intérieur',
style:
GoogleFonts.plusJakartaSans(
color:
secondaryText.withOpacity(0.45),
fontSize: 9,
letterSpacing: 0.35,
),
),
],
),
),
],
),
),
);
}

// ============================================================
// INFORMATIONS
// ============================================================

Widget _infosCard() {
return Container(
padding: const EdgeInsets.symmetric(
vertical: 17,
horizontal: 8,
),

decoration: BoxDecoration(
color: cardColor.withOpacity(0.32),

borderRadius:
BorderRadius.circular(18),

border: Border.all(
color: borderColor.withOpacity(0.8),
),
),

child: Row(
children: [

_info(
'PIÈCE',
widget.piece,
),

_verticalDivider(),

_info(
'STYLE',
widget.style,
),

_verticalDivider(),

_info(
'COULEUR',
widget.couleur,
),
],
),
);
}

Widget _verticalDivider() {
return Container(
width: 1,
height: 30,
color: borderColor.withOpacity(0.8),
);
}

Widget _info(
String titre,
String valeur,
) {
return Expanded(
child: Column(
children: [

Text(
titre,

style:
GoogleFonts.plusJakartaSans(
color:
secondaryText.withOpacity(0.45),
fontSize: 8,
fontWeight: FontWeight.w600,
letterSpacing: 1.2,
),
),

const SizedBox(height: 6),

Text(
valeur,

maxLines: 1,
overflow: TextOverflow.ellipsis,
textAlign: TextAlign.center,

style:
GoogleFonts.plusJakartaSans(
color: creamColor,
fontSize: 11,
fontWeight: FontWeight.w600,
),
),
],
),
);
}

// ============================================================
// IMAGE DU MEUBLE
// ============================================================

Widget _imageMeuble() {
final imagePath =
_getImagePath(widget.meuble);

return Container(
width: double.infinity,
height: 300,

decoration: BoxDecoration(
color: cardColor,

borderRadius:
BorderRadius.circular(22),

border: Border.all(
color: borderColor,
width: 1,
),

boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.18),
blurRadius: 25,
offset: const Offset(0, 12),
),
],
),

child: ClipRRect(
borderRadius:
BorderRadius.circular(22),

child: Stack(
fit: StackFit.expand,

children: [

// IMAGE
Image.asset(
imagePath,

width: double.infinity,
height: double.infinity,

// IMPORTANT :
// L'image remplit maintenant
// entièrement le carré.
fit: BoxFit.cover,

errorBuilder:
(context, error, stackTrace) {
debugPrint(
'ERREUR IMAGE : $error',
);

debugPrint(
'CHEMIN : $imagePath',
);

return _imageMeublePlaceholder();
},
),

// VOILE TRÈS LÉGER
Container(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,

colors: [
Colors.transparent,
Colors.black.withOpacity(0.18),
],
),
),
),

// LABEL IMAGE
Positioned(
left: 14,
top: 14,

child: Container(
padding:
const EdgeInsets.symmetric(
horizontal: 10,
vertical: 6,
),

decoration: BoxDecoration(
color: backgroundColor.withOpacity(0.75),

borderRadius:
BorderRadius.circular(20),

border: Border.all(
color: creamColor.withOpacity(0.12),
),
),

child: Row(
mainAxisSize: MainAxisSize.min,

children: [

const Icon(
Icons.auto_awesome_rounded,
color: accentYellow,
size: 11,
),

const SizedBox(width: 6),

Text(
'INSPIRATION',
style:
GoogleFonts.plusJakartaSans(
color: creamColor,
fontSize: 8,
fontWeight: FontWeight.w600,
letterSpacing: 1,
),
),
],
),
),
),
],
),
),
);
}

// ============================================================
// CHEMIN IMAGE
// ============================================================

String _getImagePath(String meuble) {
final nom =
meuble.toLowerCase().trim();

if (nom.contains('canapé') ||
nom.contains('canape')) {
return 'assets/meubles/canape.jpg';
}

if (nom.contains('fauteuil')) {
return 'assets/meubles/fauteuil.jpg';
}

if (nom.contains('table basse')) {
return 'assets/meubles/table_basse.jpg';
}

if (nom.contains('meuble tv')) {
return 'assets/meubles/meuble_tv.jpg';
}

if (nom == 'lit') {
return 'assets/meubles/lit.jpg';
}

if (nom.contains('table de chevet')) {
return 'assets/meubles/table_chevet.jpg';
}

if (nom.contains('armoire')) {
return 'assets/meubles/armoire.jpg';
}

if (nom.contains('commode')) {
return 'assets/meubles/commode.jpg';
}

if (nom.contains('bureau')) {
return 'assets/meubles/bureau.jpg';
}

if (nom.contains('bibliothèque') ||
nom.contains('bibliotheque')) {
return 'assets/meubles/bibliotheque.jpg';
}

if (nom.contains('étagère') ||
nom.contains('etagere')) {
return 'assets/meubles/etagere.jpg';
}

if (nom.contains('îlot') ||
nom.contains('ilot')) {
return 'assets/meubles/ilot.jpg';
}

if (nom.contains('table à manger') ||
nom.contains('table a manger')) {
return 'assets/meubles/table_a_manger.jpg';
}

if (nom.contains('meuble de rangement')) {
return 'assets/meubles/meuble_rangement.jpg';
}

if (nom.contains('tabouret')) {
return 'assets/meubles/tabouret.jpg';
}

if (nom.contains('chaise')) {
return 'assets/meubles/chaise.jpg';
}

if (nom.contains('table')) {
return 'assets/meubles/table.jpg';
}

return 'assets/meubles/default.jpg';
}

// ============================================================
// PLACEHOLDER
// ============================================================

Widget _imageMeublePlaceholder() {
return Container(
width: double.infinity,
height: double.infinity,

color: backgroundColor,

child: Column(
mainAxisAlignment:
MainAxisAlignment.center,

children: [

Icon(
_getMeubleIcon(),
color: accentYellow,
size: 50,
),

const SizedBox(height: 14),

Text(
'Image indisponible',

style:
GoogleFonts.plusJakartaSans(
color: creamColor,
fontSize: 12,
fontWeight: FontWeight.w500,
),
),
],
),
);
}

// ============================================================
// CARTE PRIX
// ============================================================

Widget _cartePrix() {
return Container(
width: double.infinity,

padding: const EdgeInsets.all(18),

decoration: BoxDecoration(
color: cardColor.withOpacity(0.38),

borderRadius:
BorderRadius.circular(18),

border: Border.all(
color: borderColor,
),
),

child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Container(
width: 46,
height: 46,

decoration: BoxDecoration(
shape: BoxShape.circle,

color: accentYellow.withOpacity(0.09),

border: Border.all(
color: accentYellow.withOpacity(0.22),
),
),

child: const Icon(
Icons.sell_outlined,
color: accentYellow,
size: 20,
),
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Text(
'PRIX ESTIMÉ',

style:
GoogleFonts.plusJakartaSans(
color:
secondaryText.withOpacity(0.48),
fontSize: 8,
fontWeight: FontWeight.w600,
letterSpacing: 1.3,
),
),

const SizedBox(height: 7),

Text(
prix,

style:
GoogleFonts.plusJakartaSans(
color: creamColor,
fontSize: 13,
height: 1.5,
fontWeight: FontWeight.w500,
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
// AUCUN MAGASIN
// ============================================================

Widget _aucunMagasin() {
return Container(
width: double.infinity,

padding: const EdgeInsets.all(22),

decoration: BoxDecoration(
color: cardColor.withOpacity(0.35),

borderRadius:
BorderRadius.circular(18),

border: Border.all(
color: borderColor,
),
),

child: Column(
children: [

Icon(
Icons.storefront_outlined,
color:
secondaryText.withOpacity(0.45),
size: 30,
),

const SizedBox(height: 10),

Text(
'Aucun site disponible pour ce meuble.',

textAlign: TextAlign.center,

style:
GoogleFonts.plusJakartaSans(
color:
secondaryText.withOpacity(0.62),
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
(store['title'] ??
store['name'] ??
store['store'] ??
'Magasin')
    .toString()
    .trim();

final String url =
(store['url'] ??
store['website'] ??
store['link'] ??
'')
    .toString()
    .trim();

return Container(
margin: const EdgeInsets.only(
bottom: 10,
),

decoration: BoxDecoration(
color: cardColor.withOpacity(0.38),

borderRadius:
BorderRadius.circular(17),

border: Border.all(
color: borderColor,
),
),

child: Material(
color: Colors.transparent,

child: InkWell(
borderRadius:
BorderRadius.circular(17),

onTap: url.isEmpty
? null
    : () async {
Uri? uri =
Uri.tryParse(url);

if (uri == null) {
return;
}

if (!uri.hasScheme) {
uri = Uri.tryParse(
'https://$url',
);
}

if (uri == null) {
return;
}

try {
final success =
await launchUrl(
uri,
mode:
LaunchMode.externalApplication,
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
} catch (e) {
debugPrint(
'ERREUR SITE : $e',
);

if (!mounted) {
return;
}

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
padding: const EdgeInsets.symmetric(
horizontal: 14,
vertical: 12,
),

child: Row(
children: [

// ICÔNE MAGASIN
Container(
width: 42,
height: 42,

decoration: BoxDecoration(
shape: BoxShape.circle,

color:
accentYellow.withOpacity(0.08),

border: Border.all(
color:
accentYellow.withOpacity(0.16),
),
),

child: const Icon(
Icons.storefront_rounded,
color: accentYellow,
size: 18,
),
),

const SizedBox(width: 13),

// NOM + ACTION
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Text(
title.isEmpty
? 'Magasin'
    : title,

maxLines: 2,

overflow:
TextOverflow.ellipsis,

style:
GoogleFonts.plusJakartaSans(
color: creamColor,
fontSize: 11,
height: 1.35,
fontWeight: FontWeight.w600,
),
),

const SizedBox(height: 5),

Row(
children: [

Text(
url.isEmpty
? 'Site indisponible'
    : 'Visiter le site',

style:
GoogleFonts.plusJakartaSans(
color: url.isEmpty
? secondaryText
    .withOpacity(0.4)
    : accentYellow,
fontSize: 9,
fontWeight:
FontWeight.w600,
),
),

if (url.isNotEmpty) ...[
const SizedBox(width: 5),

const Icon(
Icons
    .north_east_rounded,
color: accentYellow,
size: 10,
),
],
],
),
],
),
),

const SizedBox(width: 8),

// FLÈCHE
Container(
width: 30,
height: 30,

decoration: BoxDecoration(
shape: BoxShape.circle,

color:
creamColor.withOpacity(0.04),
),

child: const Icon(
Icons.arrow_forward_ios_rounded,
color: secondaryText,
size: 11,
),
),
],
),
),
),
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
horizontal: 13,
),

child: Text(
titre,

style:
GoogleFonts.plusJakartaSans(
color:
creamColor.withOpacity(0.72),
fontSize: 12,
fontWeight: FontWeight.w600,
letterSpacing: 1.7,
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
// ICÔNE
// ============================================================

IconData _getMeubleIcon() {
final nom =
widget.meuble.toLowerCase();

if (nom.contains('canapé') ||
nom.contains('canape')) {
return Icons.weekend_rounded;
}

if (nom.contains('fauteuil')) {
return Icons.chair_rounded;
}

if (nom.contains('table')) {
return Icons.table_restaurant_rounded;
}

if (nom.contains('lit')) {
return Icons.bed_rounded;
}

if (nom.contains('armoire')) {
return Icons.door_sliding_rounded;
}

if (nom.contains('bureau')) {
return Icons.desk_rounded;
}

if (nom.contains('bibliothèque') ||
nom.contains('bibliotheque') ||
nom.contains('étagère') ||
nom.contains('etagere')) {
return Icons.shelves;
}

if (nom.contains('cuisine')) {
return Icons.kitchen_rounded;
}

if (nom.contains('chaise') ||
nom.contains('tabouret')) {
return Icons.chair_rounded;
}

return Icons.chair_alt_rounded;
}
}

