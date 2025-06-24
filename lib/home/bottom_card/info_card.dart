import 'package:flutter/material.dart';
import 'base_flat_card.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseFlatCard(
      child: const Center(child: Text('Info')), // Personalizza qui
    );
  }
}
