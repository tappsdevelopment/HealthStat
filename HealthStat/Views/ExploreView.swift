//
//  ExploreView.swift
//  HealthStat
//
//  Created by Tobias Schweizer on 27.12.23.
//

import SwiftUI
import HealthKit

// Color movement ring: 250/17/79 -> 249/56/133
// Color training ring: 142/236/1 -> 200/236/0
// Color standing ring: 0/216/254 -> 2/255/169

struct ExploreView: View {
    var healthData: HealthData    
    
    var body: some View {
        VStack {
            NavigationLink {
                WorkoutStatView(myWorkouts: healthData.workouts)
            } label: {
                BrowseListElementView(name: "Movement", picture: "Walk", color1: Constants.Colors.MovementRingColor1, color2: Constants.Colors.MovementRingColor2)
            }
            NavigationLink {
                WorkoutStatView(myWorkouts: healthData.workouts)
            } label: {
                BrowseListElementView(name: "Workouts", picture: "Workout", color1: Constants.Colors.TrainingRingColor1, color2: Constants.Colors.TrainingRingColor2)
            }
            NavigationLink {
                WorkoutStatView(myWorkouts: healthData.workouts)
            } label: {
                BrowseListElementView(name: "Standing", picture: "Office", color1: Constants.Colors.StandingRingColor1, color2: Constants.Colors.StandingRingColor2)
            }
            
            List {
                ExploreListElementView(elementLabel: "Step count", elementValue: String(healthData.stepCount), elementColor: .white)
                ExploreListElementView(elementLabel: "Distance today", elementValue: String(healthData.distanceWalkingRunningToday), elementColor: .white)
                ExploreListElementView(elementLabel: "Distance overall", elementValue: String(healthData.distanceWalkingRunningOverall), elementColor: .white)
                ExploreListElementView(elementLabel: "Distance Trainings", elementValue: String(healthData.distanceTrainings), elementColor: .white)
                ExploreListElementView(elementLabel: "Days with Workouts", elementValue: String(healthData.numberOfDaysWithWorkouts), elementColor: .white)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ExploreView(healthData: HealthData())
}
