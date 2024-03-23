//
//  WorkoutStatView.swift
//  HealthStat
//
//  Created by Tobias Schweizer on 18.02.24.
//

import SwiftUI
import HealthKit
import Charts

struct WorkoutCount: Identifiable {
    let id = UUID()
    var type: HKWorkoutActivityType
    var value: Double
    var name: String
}

struct WorkoutStatView: View {
    var workouts: [HKWorkout]
    private var firstYear: Int
    private var workoutsPerYear: [Int]
    private var workoutsPerMonth: [Int]
    private var workoutDaysPerMonth: [Int]
    private var workoutDaysPerMonthPercentage: [Float]
    private var workoutTypeCount: [WorkoutCount]
    private var workoutTypeDuration: [WorkoutCount]
    private var workoutTypeCalories: [WorkoutCount]
    @State var WorkoutChartSelection = "Count"
    private let WorkoutChartSelectionItems = ["Count", "Duration", "Calories"]
    private let daysPerMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    
    init(myWorkouts: [HKWorkout]) {
        workouts = myWorkouts
        firstYear = 0
        self.workoutsPerYear = [Int]()
        self.workoutsPerMonth = [Int]()
        self.workoutDaysPerMonth = [Int]()
        self.workoutDaysPerMonthPercentage = [Float]()
        self.workoutTypeCount = [WorkoutCount]()
        self.workoutTypeDuration = [WorkoutCount]()
        self.workoutTypeCalories = [WorkoutCount]()
        self.CountWorkoutsPerYear()
        self.CountWorkoutsPerMonth()
        self.CountWorkoutDaysPerMonth()
        self.CalcDaysPerMonthPercentage()
        self.CreateWorkoutTypesStatistics()
    }
    
    mutating func CountWorkoutsPerMonth() {
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        
        self.workoutsPerMonth = [Int](repeating: 0, count: 12)
        
        for workout in workouts {
            if (currentYear == Calendar.current.component(.year, from: workout.startDate)) {
                // This workaround is from this year and needs to be counted
                self.workoutsPerMonth[Calendar.current.component(.month, from: workout.startDate) - 1] = self.workoutsPerMonth[Calendar.current.component(.month, from: workout.startDate) - 1] + 1
            }
        }
    }
    
    mutating func CountWorkoutDaysPerMonth() {
        var lastDate = Date()
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        
        self.workoutDaysPerMonth = [Int](repeating: 0, count: 12)
        
        for workout in workouts {
            if (currentYear == Calendar.current.component(.year, from: workout.startDate)) {
                // This workaround is from this year and needs to be counted
                
                if !Calendar.current.isDate(lastDate, equalTo: workout.startDate, toGranularity: .day) {
                    self.workoutDaysPerMonth[Calendar.current.component(.month, from: workout.startDate) - 1] = self.workoutDaysPerMonth[Calendar.current.component(.month, from: workout.startDate) - 1] + 1
                }
                lastDate = workout.startDate
            }
        }
    }
    
    mutating func CountWorkoutsPerYear() {
        if (workouts.count > 0) {
            self.firstYear = Calendar.current.component(.year, from: workouts[0].startDate)
            self.workoutsPerYear = [Int](repeating: 0, count: (self.firstYear - Calendar.current.component(.year, from: Date())) + 1)

            for workout in workouts {
                let year = Calendar.current.component(.year, from: workout.startDate)
                self.workoutsPerYear[year - self.firstYear] = self.workoutsPerYear[year - self.firstYear] + 1
            }
        }
    }
    
    mutating func CreateWorkoutTypesStatistics() {
        var workoutTypeFound: Bool
        
        for workout in workouts {
            workoutTypeFound = false
            for i in workoutTypeCount.indices {
                if (workoutTypeCount[i].type == workout.workoutActivityType) {
                    workoutTypeCount[i].value = workoutTypeCount[i].value + 1
                    workoutTypeFound = true
                }
            }
            
            for i in workoutTypeDuration.indices {
                if (workoutTypeDuration[i].type == workout.workoutActivityType) {
                    workoutTypeDuration[i].value = workoutTypeDuration[i].value + workout.duration.rounded()
                    workoutTypeFound = true
                }
            }
            
            for i in workoutTypeCalories.indices {
                if (workoutTypeCalories[i].type == workout.workoutActivityType) {
                    workoutTypeCalories[i].value = workoutTypeCalories[i].value + (workout.statistics(for: HKQuantityType(.activeEnergyBurned))?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0.0)
                    workoutTypeFound = true
                }
            }
            
            if (workoutTypeFound == false) {
                self.workoutTypeCount.append(WorkoutCount(type: workout.workoutActivityType, value: 1, name: workout.workoutActivityType.name))
                self.workoutTypeDuration.append(WorkoutCount(type: workout.workoutActivityType, value: workout.duration.rounded(), name: workout.workoutActivityType.name))
                self.workoutTypeCalories.append(WorkoutCount(type: workout.workoutActivityType, value: workout.statistics(for: HKQuantityType(.activeEnergyBurned))?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0.0, name: workout.workoutActivityType.name))
            }
        }
    }
    
    mutating func CalcDaysPerMonthPercentage() {
        self.workoutDaysPerMonthPercentage = [Float](repeating: 0.5, count: 12)
        for i in 0...11 {
            self.workoutDaysPerMonthPercentage[i] = Float(self.workoutDaysPerMonth[i]) / Float(daysPerMonth[i])
        }
    }
    
    func timeFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
     }
    
    var body: some View {
        ScrollView {
            VStack{
                // Year overview
                Text("Workouts per Year")
                    .font(.title2)
                    .padding(.top, 20.0)
                if (workoutsPerYear.count > 0)
                {
                    /*ForEach (0..<workoutsPerYear.count)
                    { i in
                        Text(String(self.firstYear + i) + ": " + String(workoutsPerYear[i]) + " Workouts")
                    }*/
                    
                    Chart {
                            BarMark(
                                x: .value("Year", String(self.firstYear + 0)),
                                y: .value("Number of Workouts", workoutsPerYear[0])
                            ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    }.frame(height: 250)
                }
                
                Spacer()
                
                // Monthly overview of the current year
                Text("Workouts per Month")
                    .font(.title2)
                    .padding(.top, 20.0)
                Chart {
                    BarMark(
                        x: .value("Month", "Jan"),
                        y: .value("Number of Workouts", workoutsPerMonth[0])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Feb"),
                        y: .value("Number of Workouts", workoutsPerMonth[1])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Mar"),
                        y: .value("Number of Workouts", workoutsPerMonth[2])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Apr"),
                        y: .value("Number of Workouts", workoutsPerMonth[3])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "May"),
                        y: .value("Number of Workouts", workoutsPerMonth[4])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Jun"),
                        y: .value("Number of Workouts", workoutsPerMonth[5])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Jul"),
                        y: .value("Number of Workouts", workoutsPerMonth[6])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Aug"),
                        y: .value("Number of Workouts", workoutsPerMonth[7])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Sep"),
                        y: .value("Number of Workouts", workoutsPerMonth[8])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Oct"),
                        y: .value("Number of Workouts", workoutsPerMonth[9])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Nov"),
                        y: .value("Number of Workouts", workoutsPerMonth[10])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Dec"),
                        y: .value("Number of Workouts", workoutsPerMonth[11])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                }.frame(height: 250)
                
                Spacer()
                
                // Days with workouts of the current year
                Text("Days with workouts per Month")
                    .font(.title2)
                    .padding(.top, 20.0)
                /*
                Chart {
                    BarMark(
                        x: .value("Month", "Jan"),
                        y: .value("Number of Workout days", workoutDaysPerMonth[0])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Jan"),
                        y: .value("Number of Workout days", daysPerMonth[0] - workoutDaysPerMonth[0])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Feb"),
                        y: .value("Number of Workout days", workoutDaysPerMonth[1])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Feb"),
                        y: .value("Number of Workout days", daysPerMonth[1] - workoutDaysPerMonth[1])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Mar"),
                        y: .value("Number of Workout days", workoutDaysPerMonth[2])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Mar"),
                        y: .value("Number of Workout days", daysPerMonth[2] - workoutDaysPerMonth[2])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Apr"),
                        y: .value("Number of Workout days", workoutDaysPerMonth[3])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Apr"),
                        y: .value("Number of Workout days", daysPerMonth[3] - workoutDaysPerMonth[3])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "May"),
                        y: .value("Number of Workout days", workoutDaysPerMonth[4])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "May"),
                        y: .value("Number of Workout days", daysPerMonth[04] - workoutDaysPerMonth[4])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Jun"),
                        y: .value("Number of Workout days", workoutDaysPerMonth[5])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Jun"),
                        y: .value("Number of Workout days", daysPerMonth[5] - workoutDaysPerMonth[5])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Jul"),
                        y: .value("Number of Workout days", workoutDaysPerMonth[6])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Jul"),
                        y: .value("Number of Workout days", daysPerMonth[6] - workoutDaysPerMonth[6])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Aug"),
                        y: .value("Number of Workout days", workoutDaysPerMonth[7])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Aug"),
                        y: .value("Number of Workout days", daysPerMonth[7] - workoutDaysPerMonth[7])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Sep"),
                        y: .value("Number of Workout days", workoutDaysPerMonth[8])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Sep"),
                        y: .value("Number of Workout days", daysPerMonth[8] - workoutDaysPerMonth[8])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Oct"),
                        y: .value("Number of Workout days", workoutDaysPerMonth[9])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Oct"),
                        y: .value("Number of Workout days", daysPerMonth[9] - workoutDaysPerMonth[9])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Nov"),
                        y: .value("Number of Workout days", workoutDaysPerMonth[10])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Nov"),
                        y: .value("Number of Workout days", daysPerMonth[10] - workoutDaysPerMonth[10])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Dec"),
                        y: .value("Number of Workout days", workoutDaysPerMonth[11])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Dec"),
                        y: .value("Number of Workout days", daysPerMonth[11] - workoutDaysPerMonth[11])
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                }.frame(height: 250)
                */
                Chart {
                    BarMark(
                        x: .value("Month", "Jan"),
                        y: .value("Number of Workout days", workoutDaysPerMonthPercentage[0] * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Jan"),
                        y: .value("Number of Workout days", (1.0 - workoutDaysPerMonthPercentage[0]) * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Feb"),
                        y: .value("Number of Workout days", workoutDaysPerMonthPercentage[1] * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Feb"),
                        y: .value("Number of Workout days", (1.0 - workoutDaysPerMonthPercentage[1]) * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Mar"),
                        y: .value("Number of Workout days", workoutDaysPerMonthPercentage[2] * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Mar"),
                        y: .value("Number of Workout days", (1.0 - workoutDaysPerMonthPercentage[2]) * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Apr"),
                        y: .value("Number of Workout days", workoutDaysPerMonthPercentage[3] * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Apr"),
                        y: .value("Number of Workout days", (1.0 - workoutDaysPerMonthPercentage[3]) * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "May"),
                        y: .value("Number of Workout days", workoutDaysPerMonthPercentage[4] * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "May"),
                        y: .value("Number of Workout days", (1.0 - workoutDaysPerMonthPercentage[4]) * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Jun"),
                        y: .value("Number of Workout days", workoutDaysPerMonthPercentage[5] * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Jun"),
                        y: .value("Number of Workout days", (1.0 - workoutDaysPerMonthPercentage[5]) * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Jul"),
                        y: .value("Number of Workout days", workoutDaysPerMonthPercentage[6] * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Jul"),
                        y: .value("Number of Workout days", (1.0 - workoutDaysPerMonthPercentage[6]) * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Aug"),
                        y: .value("Number of Workout days", workoutDaysPerMonthPercentage[7] * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Aug"),
                        y: .value("Number of Workout days", (1.0 - workoutDaysPerMonthPercentage[7]) * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Sep"),
                        y: .value("Number of Workout days", workoutDaysPerMonthPercentage[8] * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Sep"),
                        y: .value("Number of Workout days", (1.0 - workoutDaysPerMonthPercentage[8]) * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Oct"),
                        y: .value("Number of Workout days", workoutDaysPerMonthPercentage[9] * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Oct"),
                        y: .value("Number of Workout days", (1.0 - workoutDaysPerMonthPercentage[9]) * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Nov"),
                        y: .value("Number of Workout days", workoutDaysPerMonthPercentage[10] * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Nov"),
                        y: .value("Number of Workout days", (1.0 - workoutDaysPerMonthPercentage[10]) * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                    BarMark(
                        x: .value("Month", "Dec"),
                        y: .value("Number of Workout days", workoutDaysPerMonthPercentage[11] * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor1)
                    BarMark(
                        x: .value("Month", "Dec"),
                        y: .value("Number of Workout days", (1.0 - workoutDaysPerMonthPercentage[11]) * 100)
                    ).foregroundStyle(Constants.Colors.TrainingRingColor2.opacity(0.25))
                    
                }.frame(height: 250)
                .chartYScale(domain: 0...100)
                .chartYAxis {
                   AxisMarks() {
                       let value = $0.as(Int.self)!
                       AxisValueLabel {
                           Text("\(value)%")
                       }
                   }
                }
            }
            Spacer()
            
            // Workout type statstics
            Text("Workouts types (\(WorkoutChartSelection))")
                .font(.title2)
                .padding(.top, 20.0)
            
            Picker("Criteria", selection: $WorkoutChartSelection) {
                ForEach(WorkoutChartSelectionItems, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.menu)
            
            switch (WorkoutChartSelection)
            {
            case "Count":
                Chart(workoutTypeCount) { workoutType in
                    SectorMark(
                        angle: .value(
                            Text(verbatim: workoutType.name),
                            workoutType.value
                        ),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(
                        by: .value(
                            Text(verbatim: workoutType.name),
                            workoutType.name
                        )
                    )
                    .annotation(position: .overlay, alignment: .center, spacing: 0) {
                        Text(verbatim: String(Int(workoutType.value)))
                            .font(.caption)
                    }
                }
                .frame(height: 250)
                
                Spacer()
                
            case "Duration":
                Chart(workoutTypeDuration) { workoutType in
                    SectorMark(
                        angle: .value(
                            Text(verbatim: workoutType.name),
                            workoutType.value
                        ),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(
                        by: .value(
                            Text(verbatim: workoutType.name),
                            workoutType.name
                        )
                    )
                    .annotation(position: .overlay, alignment: .center, spacing: 0) {
                        Text(verbatim: timeFormatted(totalSeconds: Int(workoutType.value)))
                            .font(.caption)
                    }
                }
                .frame(height: 250)
                
            case "Calories":
                Chart(workoutTypeCalories) { workoutType in
                    SectorMark(
                        angle: .value(
                            Text(verbatim: workoutType.name),
                            workoutType.value
                        ),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(
                        by: .value(
                            Text(verbatim: workoutType.name),
                            workoutType.name
                        )
                    )
                    .annotation(position: .overlay, alignment: .center, spacing: 0) {
                        Text(verbatim: String(Int(workoutType.value)))
                            .font(.caption)
                    }
                }
                .frame(height: 250)
            default:
                Text("Nothing selected")
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    WorkoutStatView(myWorkouts: [HKWorkout]())
}
