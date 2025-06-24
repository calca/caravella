import 'package:flutter/material.dart';
import '../../trips_storage.dart';
import '../../trip/detail_page/trip_detail_page.dart';
import 'base_flat_card.dart';

class InfoCard extends StatelessWidget {
  final Trip trip;
  const InfoCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return BaseFlatCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TripDetailPage(trip: trip),
          ),
        );
      },
      child: const Center(child: Text('Info')), // Personalizza qui
    );
  }
}
