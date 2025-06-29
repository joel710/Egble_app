import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191919),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Politique de confidentialité',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Politique de confidentialité',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Dernière mise à jour : ${DateTime.now().year}',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            SizedBox(height: 24),
            
            _buildSection(
              '1. Informations que nous collectons',
              'Nous collectons les informations que vous nous fournissez directement, telles que :\n'
              '• Vos informations de profil (nom, email, photo de profil)\n'
              '• Le contenu que vous publiez (vidéos, descriptions, commentaires)\n'
              '• Vos interactions avec d\'autres utilisateurs (likes, partages)\n'
              '• Les données d\'utilisation de l\'application',
            ),
            
            _buildSection(
              '2. Comment nous utilisons vos informations',
              'Nous utilisons vos informations pour :\n'
              '• Fournir et améliorer nos services\n'
              '• Personnaliser votre expérience\n'
              '• Vous connecter avec d\'autres utilisateurs\n'
              '• Assurer la sécurité de la plateforme\n'
              '• Vous envoyer des notifications importantes',
            ),
            
            _buildSection(
              '3. Partage de vos informations',
              'Nous ne vendons pas vos informations personnelles. Nous pouvons partager vos informations dans les cas suivants :\n'
              '• Avec votre consentement explicite\n'
              '• Pour respecter les obligations légales\n'
              '• Pour protéger nos droits et notre sécurité\n'
              '• Avec des prestataires de services de confiance',
            ),
            
            _buildSection(
              '4. Sécurité des données',
              'Nous mettons en œuvre des mesures de sécurité appropriées pour protéger vos informations contre l\'accès non autorisé, la modification, la divulgation ou la destruction.',
            ),
            
            _buildSection(
              '5. Vos droits',
              'Vous avez le droit de :\n'
              '• Accéder à vos informations personnelles\n'
              '• Corriger vos informations inexactes\n'
              '• Supprimer votre compte et vos données\n'
              '• Contrôler vos paramètres de confidentialité\n'
              '• Vous opposer au traitement de vos données',
            ),
            
            _buildSection(
              '6. Cookies et technologies similaires',
              'Nous utilisons des cookies et des technologies similaires pour améliorer votre expérience, analyser l\'utilisation de l\'application et personnaliser le contenu.',
            ),
            
            _buildSection(
              '7. Conservation des données',
              'Nous conservons vos informations aussi longtemps que nécessaire pour fournir nos services, respecter nos obligations légales, résoudre les litiges et faire respecter nos accords.',
            ),
            
            _buildSection(
              '8. Modifications de cette politique',
              'Nous pouvons mettre à jour cette politique de confidentialité de temps à autre. Nous vous informerons de tout changement important en publiant la nouvelle politique sur cette page.',
            ),
            
            _buildSection(
              '9. Nous contacter',
              'Si vous avez des questions concernant cette politique de confidentialité, contactez-nous à :\n'
              'Email : privacy@egble-app.com\n'
              'Adresse : Lomé, Togo',
            ),
            
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
