import 'package:flutter/material.dart';
import '../widgets/header.dart'; //importer le header commun

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    //Détecter si écran mobile pour Drawer
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: const Header(), // <-- appBar commun
      drawer: isMobile
         ? Drawer(
             child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.green),
                  child: Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ), // Text
                ), // DrawerHeader
                _drawerItem(context, "Home", '/home'),
                _drawerItem(context, "About", '/about'),
                _drawerItem(context, "Contact", '/contact'),
                _drawerItem(context, "Login", '/login'),
                _drawerItem(context, "Signin", '/signin'),                                                                
              ],
             ), // ListView
         ) // Drawer
       : null,
    body: const Center(child: Text("Bienvenue à ContactPage!")),
    );    
  }

  // Fonction pour créer les liens du Drawer
  Widget _drawerItem(BuildContext context, String title, String route) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Fermer le Drawer     
        Navigator.pushNamed(context, route);
      },
    );
  }
}