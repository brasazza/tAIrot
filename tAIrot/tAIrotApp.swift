//
//  tAIrotApp.swift
//  tAIrot
//
//  Created by Brandon Ramírez Casazza on 17/05/23.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      
    RemoteConfigService.shared.fetchRemoteConfig()
      
    return true
  }
}

@main
struct TheSeerApp: App {
    @StateObject var predictionCounter = PredictionCounter()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
            WindowGroup {
                ContentView()
                    .environmentObject(IAPManager.shared)
                    .environmentObject(PredictionCounter.shared)
            }
        }
    }
