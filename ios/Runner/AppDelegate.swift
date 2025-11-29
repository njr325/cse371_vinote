// ios/Runner/AppDelegate.swift

import UIKit
import Flutter
import GoogleMaps // 1. Importer GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // 2. Initialiser Google Maps AVANT GeneratedPluginRegistrant
    // REMPLACEZ VOTRE_CLE_API_GOOGLE_MAPS_ICI par votre clé iOS
    GMSServices.provideAPIKey("VOTRE_CLE_API_GOOGLE_MAPS_ICI") 

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}