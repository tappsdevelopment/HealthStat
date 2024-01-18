//
//  FavoritesView.swift
//  HealthStat
//
//  Created by Tobias Schweizer on 17.01.24.
//

import SwiftUI

struct FavoritesView: View {
    @State private var stepCount: Int = 0
    @State private var distanceWalkingRunning: Int = 0
    private let healthKitManager = HealthKitManager()
    
    var body: some View {
        VStack {
            Text("Step Count: \(stepCount)")
            Text("Distance: \(distanceWalkingRunning)")
            }.onAppear {
                healthKitManager.requestAuthorization { success, error in
                    if success {
                        updateData()
                    } else {
                        // Handle error
                    }
                }
        }
    }
    
    
    private func updateData() {
        healthKitManager.fetchStepCount { count, error in
            if let count = count {
                DispatchQueue.main.async {
                    self.stepCount = Int(count)
                }
            } else {
                // Handle error
            }
        }
        
        healthKitManager.fetchDistanceWalkingRunning { count, error in
            if let count = count {
                DispatchQueue.main.async {
                    self.distanceWalkingRunning = Int(count)
                }
            } else {
                // Handle error
                print("Error")
            }
        }
    }
}

#Preview {
    FavoritesView()
}
