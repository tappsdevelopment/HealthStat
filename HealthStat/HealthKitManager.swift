//
//  HealthKitManager.swift
//  HealthStat
//
//  Created by Tobias Schweizer on 26.12.23.
//

import HealthKit

class HealthKitManager {
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .stepCount)!,
                                              HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                              .workoutType(), HKSeriesType.workoutType()]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    func fetchStepCount(completion: @escaping (Double?, Error?) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let query = HKStatisticsQuery(quantityType: stepType,
                                      quantitySamplePredicate: nil,
                                      options: .cumulativeSum) { (_, result, error) in
            if let sum = result?.sumQuantity() {
                completion(sum.doubleValue(for: .count()), nil)
            } else {
                completion(nil, error)
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchDistanceWalkingRunning(startDate: Date, completion: @escaping (Double?, Error?) -> Void) {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        
        let cal = NSCalendar(calendarIdentifier: .gregorian)!
        
        let today = cal.startOfDay(for: startDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: today, end: NSDate() as Date, options: HKQueryOptions.strictStartDate)
        
        
        let query = HKSampleQuery(sampleType: distanceType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, results, error in
            
            
            var distance: Double = 0
            
            if results?.count ?? 0 > 0
            {
                for res in results as! [HKQuantitySample]
                {
                    distance += res.quantity.doubleValue(for: HKUnit.meterUnit(with: .none ))
                }
            }
            
            completion(distance, error)
        }
        
        healthStore.execute(query)
    }
    
    func fetchRunningWorkouts() async -> [HKWorkout]? {
        let running = HKQuery.predicateForWorkouts(with: .running)
        
        let samples = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            healthStore.execute(HKSampleQuery(sampleType: .workoutType(), predicate: running, limit: HKObjectQueryNoLimit,sortDescriptors: [.init(keyPath: \HKSample.startDate, ascending: false)], resultsHandler: { query, samples, error in
                if let hasError = error {
                    continuation.resume(throwing: hasError)
                    return
                }
                
                guard let samples = samples else {
                    fatalError("*** Invalid State: This can only fail if there was an error. ***")
                }
                
                continuation.resume(returning: samples)
            }))
        }
        
        guard let workouts = samples as? [HKWorkout] else {
            return nil
        }
        
        return workouts
    }
    
    func fetchRunningWorkoutDistance(startDate: Date, completion: @escaping (Double?, Error?) -> Void) async {
        let workouts = await fetchRunningWorkouts() as? [HKWorkout]
        var distance = 0.0
        
        if (workouts?.isEmpty == false) {
            for workout in workouts ?? [] {
                distance += workout.totalDistance?.doubleValue(for: .meter()) ?? 0.0;
            }
        }
        completion(distance, nil)
    }
    
    private func fetchWorkouts() async -> [HKWorkout]? {
        //let all = HKQuery.predicateForWorkouts(activityPredicate: .init())
        
        let samples = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            healthStore.execute(HKSampleQuery(sampleType: .workoutType(), predicate: .none, limit: HKObjectQueryNoLimit,sortDescriptors: [.init(keyPath: \HKSample.startDate, ascending: false)], resultsHandler: { query, samples, error in
                if let hasError = error {
                    continuation.resume(throwing: hasError)
                    return
                }
                
                guard let samples = samples else {
                    fatalError("*** Invalid State: This can only fail if there was an error. ***")
                }
                
                continuation.resume(returning: samples)
            }))
        }
        
        guard let workouts = samples as? [HKWorkout] else {
            return [HKWorkout]()
        }
        
        return workouts
    }
    
    func fetchAllWorkouts(startDate: Date, completion: @escaping ([HKWorkout]?, Error?) -> Void) async {
        guard let workouts = await fetchWorkouts() else {return}
        //completion(Double(workouts?.count ?? Int(0.0)), nil)
                completion(workouts ?? [HKWorkout](), nil)
    }
    
    func fetchDaysWithWorkouts(startDate: Date, completion: @escaping (Double?, Error?) -> Void) async {
        let workouts = await fetchWorkouts()
        var date = Date()
        var daysWithWorkouts = 0
        
        if (workouts?.isEmpty == false) {
            date = workouts?[0].startDate ?? Date()
            daysWithWorkouts += 1
            
            for workout in workouts ?? []
            {
                if !Calendar.current.isDate(date, equalTo: workout.startDate, toGranularity: .day)
                {
                    daysWithWorkouts += 1
                    date = workout.startDate
                }
            }
        }
        
        completion(Double(daysWithWorkouts), nil)
    }
    
}
