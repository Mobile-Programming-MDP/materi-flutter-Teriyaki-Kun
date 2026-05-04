import 'package:cepu_app/models/models.dart';
import 'package:flutter/material.dart';

class MapDetailScreen extends StatelessWidget {
  final Post post;
  
  const MapDetailScreen({super.key, required this.post});
  
  @override
  Widget build(BuildContext context) {
    final lat = double.tryParse(post.latitude ?? '' );
    final lng = double.tryParse(post.longitude ?? '');
    final hasLocation = lat != null && lng != null;
    final point = hasLocation ? LatLng(lat, lng) : const LatLng(0,0);
    return Scaffold();
  }
}