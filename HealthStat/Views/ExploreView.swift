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
    @State private var distanceTrainings: Int = 0
    @State private var numberOfWorkouts: Int = 0
    @State private var numberOfDaysWithWorkouts: Int = 0
    
    private let healthKitManager = HealthKitManager()
    
    var body: some View {
        VStack {
            Spacer()
            Text("Step Count: \(stepCount)")
            Spacer()
            Text("Distance today: \(distanceWalkingRunningToday) m")
            Spacer()
            Text("Distance overall: \(distanceWalkingRunningOverall) m")
            Spacer()
            Text("Distance Trainings: \(distanceTrainings) m")
            Spacer()
            Text("Total Workouts: \(numberOfWorkouts)")
            Spacer()
            Text("Days with Workouts: \(numberOfDaysWithWorkouts)")
            Spacer()
            }.onAppear {
                healthKitManager.requestAuthorization { success, error in
                    if success {
                        Task {
                            await updateData()
                        }
                    } else {
                        // Handle error
                    }
                }
        }
    }
    
    private func updateData() async {
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
        
        await healthKitManager.fetchRunningWorkoutDistance(startDate: NSCalendar(calendarIdentifier: .gregorian)!.startOfDay(for: Date(timeIntervalSince1970: 0)), completion: { count, error in
            if let count = count {
                DispatchQueue.main.async {
                    self.distanceTrainings = Int(count)
                }
            } else {
                // Handle error
                print("Error")
            }
        });
        
        await healthKitManager.fetchAllWorkouts(startDate: NSCalendar(calendarIdentifier: .gregorian)!.startOfDay(for: Date(timeIntervalSince1970: 0)), completion: { count, error in
            if let count = count {
                DispatchQueue.main.async {
                    self.numberOfWorkouts = Int(count)
                }
            } else {
                // Handle error
                print("Error")
            }
        });
        
        await healthKitManager.fetchDaysWithWorkouts(startDate: NSCalendar(calendarIdentifier: .gregorian)!.startOfDay(for: Date(timeIntervalSince1970: 0)), completion: { count, error in
            if let count = count {
                DispatchQueue.main.async {
                    self.numberOfDaysWithWorkouts = Int(count)
                }
            } else {
                // Handle error
                print("Error")
            }
        });
    }
}

#Preview {
    ExploreView()
}
