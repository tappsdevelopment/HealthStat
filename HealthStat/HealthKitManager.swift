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
             HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!]

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
    
    func fetchDistanceWalkingRunning(completion: @escaping (Double?, Error?) -> Void) {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        
        let date = Date()

        let cal = NSCalendar(calendarIdentifier: .gregorian)!

        let today = cal.startOfDay(for: date)

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
}
