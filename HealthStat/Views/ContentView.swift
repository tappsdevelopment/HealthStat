//
//  ContentView.swift
//  HealthStat
//
//  Created by Tobias Schweizer on 22.12.23.
//

import SwiftUI

struct ContentView: View {
    private var healthData = HealthData()
    var body: some View {
        TabView {
            // Tab "Browse"
            NavigationView {
                ExploreView(healthData: healthData)
                .navigationTitle("Browse")
            }
            .tabItem {
                Image(systemName: "square.grid.2x2.fill")
                Text("Browse")
            }
            
            // Tab "Favorites"
            FavoritesView()
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Favorites")
            }
            
            // Tab "Settings"
            NavigationView {
                SettingsView()
                .navigationTitle("Settings")
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }

            // Add more tabs as needed
            }
    }
}

#Preview {
    ContentView()
}
