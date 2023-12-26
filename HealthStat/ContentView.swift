//
//  ContentView.swift
//  HealthStat
//
//  Created by Tobias Schweizer on 22.12.23.
//

import SwiftUI

struct ContentView: View {
    @State private var stepCount: Int = 0
    private let healthKitManager = HealthKitManager()
    
    var body: some View {
        TabView {
            // Tab 1
            Text("Step Count: \(stepCount)")
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Favorites")
            }

            // Tab 2
            NavigationView {
                List {
                    ForEach(1...4, id: \.self) { index in
                        Text("Item \(index)")
                    }
                }
                .navigationTitle("Explore")
            }
            .tabItem {
                Image(systemName: "globe.europe.africa.fill")
                Text("Explore")
            }
            Text("Second View")
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
