//
//  ContentView.swift
//  FitnessSharing
//
//  Created by Krish on 8/19/22.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var habitat: Habitat
    
    var body: some View {
        if habitat.account != nil {
            NavigationView {
                HomeView()
                    .environmentObject(habitat)
                    .navigationTitle("Home")
            }
        } else {
            LoginView()
                .environmentObject(habitat)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
