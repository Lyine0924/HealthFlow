//
//  File.swift
//  MyHealthFlow
//
//  Created by MyeongSoo-Linne on 08/08/2019.
//  Copyright © 2019 MyeongSoo-Linne. All rights reserved.
//

import HealthKit

class HealthKitService {
    
    private static let _shared = HealthKitService()
    
    let healthKitStore: HKHealthStore = HKHealthStore()
    static var shared: HealthKitService {
        return _shared
    }
    
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        // 1. Check to see if HealthKit Is Available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false,HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        // 2. 데이터 타입 준비하기
        guard let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
              let step = HKObjectType.quantityType(forIdentifier: .stepCount) else {
              completion(false,HealthkitSetupError.dataTypeNotAvailable)
              return
        }
        
        // 3. 읽고 쓰기 위한 데이터 타입 목록 준비하기
        let healthKitTypesToWrite: Set<HKSampleType> = [] //추후 작성을 위해 코드만 추가함
        let healthKitTypesToRead: Set<HKSampleType> = [step,heartRate]
        
        // 4. HealthKit 인증하기
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
            completion(success,error)
        }
    }
    
    // 걸음수와 관련된 기능
    func getStepsCount(forSpecificDate: Date, completion: @escaping (Double) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let (start, end) = getWholeDate(date: forSpecificDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        
        healthKitStore.execute(query)
    }
    
    // 심박수에 관한 정보 가져오는 부분
    func getHearthRate(from: Date, to: Date) {
        let hearthRateSample = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let query = HKSampleQuery(sampleType: hearthRateSample!, predicate: .none, limit: 0, sortDescriptors: nil) { query, results, error in
            if results?.count ?? 0 > 0 {
                for result in results as! [HKQuantitySample] {
                    if result.startDate >= from && result.endDate <= to {
                        let rate = result.quantity.
                    }
                }
            }
        }
        healthKitStore.execute(query)
    }
    
    func getWholeDate(date: Date) -> (startDate:Date, endDate: Date) {
        var startDate = date
        var length = TimeInterval()
        _ = Calendar.current.dateInterval(of: .day, start: &startDate, interval: &length, for: startDate)
        let endDate:Date = startDate.addingTimeInterval(length)
        return (startDate, endDate)
    }
    
    
}
