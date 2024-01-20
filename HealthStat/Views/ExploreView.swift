//
//  ExploreView.swift
//  HealthStat
//
//  Created by Tobias Schweizer on 27.12.23.
//

import SwiftUI

struct ExploreView: View {
    @State private var stepCount: Int = 0
    @State private var distanceWalkingRunningOverall: Int = 0
    @State private var distanceWalkingRunningToday: Int = 0
    private let healthKitManager = HealthKitManager()
    
    var body: some View {
        VStack {
            Text("Step Count: \(stepCount)")
            Text("Distance today: \(distanceWalkingRunningToday)")
            Text("Distance overall: \(distanceWalkingRunningOverall)")
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
        
        healthKitManager.fetchDistanceWalkingRunning(startDate: Date(timeIntervalSince1970: TimeInterval()), completion: { count, error in
            if let count = count {
                DispatchQueue.main.async {
                    self.distanceWalkingRunningOverall = Int(count)
                }
            } else {
                // Handle error
                print("Error")
            }
        })
        
        healthKitManager.fetchDistanceWalkingRunning(startDate: NSCalendar(calendarIdentifier: .gregorian)!.startOfDay(for: Date()), completion: { count, error in
            if let count = count {
                DispatchQueue.main.async {
                    self.distanceWalkingRunningToday = Int(count)
                }
            } else {
                // Handle error
                print("Error")
            }
        })
    }
    
}

#Preview {
    ExploreView()
}
