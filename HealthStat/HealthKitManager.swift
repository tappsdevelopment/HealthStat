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
        let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .stepCount)!]

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
}
