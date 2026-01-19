import 'package:flutter/material.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialBtn(context, Icons.apple, "Apple"),
        const SizedBox(width: 20),
        _socialBtn(context, Icons.g_mobiledata, "Google"),
      ],
    );
  }

  Widget _socialBtn(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$label Login coming soon!")),
        );
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white10,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
