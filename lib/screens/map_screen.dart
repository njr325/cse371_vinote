import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Le nouveau package de carte
import 'package:latlong2/latlong.dart'; // Pour les coordonnées LatLng
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Position initiale par défaut (ex: Paris)
  static const LatLng _defaultLocation = LatLng(48.8566, 2.3522);
  final MapController _mapController = MapController();
  LatLng _currentPosition = _defaultLocation;
  final LocationService _locationService = LocationService();
  String _loadingMessage = 'Chargement de la carte OpenStreetMap et de votre position...';

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  void _loadUserLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      final newPosition = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _currentPosition = newPosition;
        _loadingMessage = '';
      });

      // Animer la caméra de FlutterMap sur la nouvelle position
      _mapController.move(
              newPosition, // Le LatLng cible
              _mapController.camera.zoom, // Conserver le niveau de zoom actuel
          );
      
    } catch (e) {
      setState(() {
        _loadingMessage = 'Erreur de localisation: ${e.toString()}';
      });
      print('Erreur lors du chargement de la position: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_loadingMessage, textAlign: TextAlign.center),
            ),
          ],
        ),
      );
    }
    
    // Le widget FlutterMap remplace GoogleMap
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition,
        initialZoom: 14.0, // Zoom initial
      ),
      children: [
        // 1. La couche de tuiles (le fond de carte OSM)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.vinote.app', // Obligatoire pour les API OSM
        ),

        // 2. Les Marqueurs (y compris l'utilisateur)
        MarkerLayer(
          markers: [
            // Marqueur pour la position de l'utilisateur
            Marker(
              point: _currentPosition,
              width: 80,
              height: 80,
              child: const Icon(
                Icons.location_pin,
                color: Colors.blue,
                size: 40.0,
              ),
            ),
            // AJOUTER D'AUTRES MARQUEURS ICI (Vignobles, etc.)
          ],
        ),

        // 3. Bouton pour recentrer sur la position de l'utilisateur (Optionnel)
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              heroTag: 'recenterMap',
              backgroundColor: Colors.purple,
              onPressed: _loadUserLocation,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}