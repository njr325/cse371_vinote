import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart'; // Pour obtenir la position initiale
import '../services/winery_api_service.dart';
import '../models/winery.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final WineryApiService _apiService = WineryApiService();
  
  // Ensemble pour stocker les marqueurs de la carte
  Set<Marker> _markers = {};
  
  // Position initiale de la caméra
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(48.8566, 2.3522), // Paris (position par défaut)
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
    _loadUserLocationAndWineries();
  }

  // Charge la position de l'utilisateur et les lieux proches
  void _loadUserLocationAndWineries() async {
    // Récupérer la position utilisateur
    final userPosition = await _locationService.getCurrentPosition();
    
    // Si la position est disponible
    if (userPosition != null) {
      final userLatLng = LatLng(userPosition.latitude, userPosition.longitude);
      
      // Mettre à jour la caméra sur la position de l'utilisateur
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: userLatLng, zoom: 14.0)
        ),
      );
      
      // Afficher le marqueur de l'utilisateur
      _markers.add(Marker(
        markerId: const MarkerId('user_location'),
        position: userLatLng,
        infoWindow: const InfoWindow(title: 'Ma Position'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));

      // Récupérer les vignobles et bars à vin
      final wineries = await _apiService.fetchNearbyWineries(userLatLng);
      _addWineryMarkers(wineries);
    }
  }

  // Ajoute les marqueurs des vignobles à la carte
  void _addWineryMarkers(List<Winery> wineries) {
    final Set<Marker> wineryMarkers = wineries.map((winery) {
      return Marker(
        markerId: MarkerId(winery.id),
        position: winery.coordinates,
        infoWindow: InfoWindow(
          title: winery.name,
          snippet: '${winery.address} - Note: ${winery.rating}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet), // Couleur Vin
      );
    }).toSet();
    
    setState(() {
      _markers.addAll(wineryMarkers);
    });
  }
  
  GoogleMapController? _mapController;
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: _initialCameraPosition,
      markers: _markers, // Afficher tous les marqueurs
      myLocationEnabled: true, // Afficher le point bleu de l'utilisateur
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
    );
  }
}