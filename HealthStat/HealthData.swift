//
//  HealthData.swift
//  HealthStat
//
//  Created by Tobias Schweizer on 27.02.24.
//

import Foundation
import HealthKit

class HealthData {
    private let healthKitManager = HealthKitManager()
    var workouts: [HKWorkout] = []
    var stepCount: Int = 0
    var distanceWalkingRunningOverall: Int = 0
    var distanceWalkingRunningToday: Int = 0
    var distanceTrainings: Int = 0
    var numberOfWorkouts: Int = 0
    var numberOfDaysWithWorkouts: Int = 0
    
    init() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                Task {
                    await self.updateData()
                }
            } else {
                // Handle error
            }
        }
    }
    
    func updateData() async {
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
        
        await healthKitManager.fetchAllWorkouts(startDate: NSCalendar(calendarIdentifier: .gregorian)!.startOfDay(for: Date(timeIntervalSince1970: 0)), completion: { workouts, error in
            self.workouts = workouts ?? []
            if let count = workouts?.count {
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
