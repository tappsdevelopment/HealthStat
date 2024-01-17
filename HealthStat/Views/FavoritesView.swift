//
//  FavoritesView.swift
//  HealthStat
//
//  Created by Tobias Schweizer on 17.01.24.
//

import SwiftUI

struct FavoritesView: View {
    @State private var stepCount: Int = 0
    private let healthKitManager = HealthKitManager()
    
    var body: some View {
        VStack {
            Text("Step Count: \(stepCount)")
            Button("Request HealthKit Authorization") {
                healthKitManager.requestAuthorization { success, error in
                    if success {
                        updateStepCount()
                    } else {
                        // Handle error
                    }
                }
            }
        }
    }
    
    
    private func updateStepCount() {
            healthKitManager.fetchStepCount { count, error in
                if let count = count {
                    DispatchQueue.main.async {
                        self.stepCount = Int(count)
                    }
                } else {
                    // Handle error
                }
            }
        }
}

#Preview {
    FavoritesView()
}
