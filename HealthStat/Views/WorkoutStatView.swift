//
//  WorkoutStatView.swift
//  HealthStat
//
//  Created by Tobias Schweizer on 18.02.24.
//

import SwiftUI
import HealthKit

struct WorkoutStatView: View {
    var workouts: [HKWorkout]
    private var workoutsPerYear: [[Int]]
    
    init(myWorkouts: [HKWorkout]) {
        workouts = myWorkouts
        workoutsPerYear = [[Int]]()
        workoutsPerYear = CountWorkoutsPerYear()
        
    }
    
    func CountWorkoutsPerYear() -> [[Int]] {
        var result = [[Int]]()
        for workout in workouts {
            
        }
        return result
    }
    
    var body: some View {
        Text(String(workouts.count))
    }
}

#Preview {
    WorkoutStatView(myWorkouts: [HKWorkout]())
}
