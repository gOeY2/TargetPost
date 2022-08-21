//
//  FitnessSharingApp.swift
//  FitnessSharing
//
//  Created by Krish on 8/19/22.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct FitnessSharingApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var habitat = Habitat()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(habitat)
        }
    }
}
