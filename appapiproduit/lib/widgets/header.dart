import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    // Taille écran
    final isMobile = MediaQuery.of(context).size.width < 600;

    if(isMobile){
      // --- Mobile : Drawer Menu ---
      return AppBar(
        title: const Text("Mon App"),
        backgroundColor: Colors.green[700],
        actions:[],
      );
    } else{
      // --- Desktop / Tablet: liens visibles ---
      return AppBar(
        title: const Text("Mon App"),
        backgroundColor: Colors.green[700],
        actions:[
      
                _headerButton(context, "Home", '/home'),
                _headerButton(context, "About", '/about'),
                _headerButton(context, "Contact", '/contact'),
                _headerButton(context, "Login", '/login'),
                _headerButton(context, "Signin", '/signin'),           
        ],
      );
    }
  }

  Widget _headerButton(BuildContext context, String title, String route){
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, route),
      child: Text(title, style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}