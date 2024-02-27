//
//  ExploreView.swift
//  HealthStat
//
//  Created by Tobias Schweizer on 27.12.23.
//

import SwiftUI
import HealthKit

struct ExploreView: View {
    var healthData: HealthData
    
    var body: some View {
        List {
            ExploreListElementView(elementLabel: "Step count", elementValue: String(healthData.stepCount), elementColor: .white)
            ExploreListElementView(elementLabel: "Distance today", elementValue: String(healthData.distanceWalkingRunningToday), elementColor: .white)
            ExploreListElementView(elementLabel: "Distance overall", elementValue: String(healthData.distanceWalkingRunningOverall), elementColor: .white)
            ExploreListElementView(elementLabel: "Distance Trainings", elementValue: String(healthData.distanceTrainings), elementColor: .white)
            NavigationLink {
                WorkoutStatView(myWorkouts: healthData.workouts)
            } label: {
                ExploreListElementView(elementLabel: "Total Workouts", elementValue: String(healthData.numberOfWorkouts), elementColor: .white)
            }
            ExploreListElementView(elementLabel: "Days with Workouts", elementValue: String(healthData.numberOfDaysWithWorkouts), elementColor: .white)
        }
    }
}

#Preview {
    ExploreView(healthData: HealthData())
}
