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
                        DispatchQueue.main.async(execute: { () -> Void in
                            let formatedResult = self.getFormated(sample: result, forValue: HealthValue.hearth)
                            print("formatedResult is : \(formatedResult)") // 이 변수를 가지고 평균 심박수를 만들면 됨.
//                            let primaryKey = "\(result.startDate)\(result.endDate)"
//                            if self.realm?.object(ofType: HearthRecord.self, forPrimaryKey: primaryKey) == nil {
//                                do {
//                                    try? self.realm?.write {
//                                        patient.hearthRecords.append(hearthRecord)
//                                    }
//                                }
//                            }
                        })
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
    
    func getFormated(sample: HKQuantitySample, forValue: HealthValue) -> AnyObject {
        var toFormat = "\(sample.quantity)"
        switch forValue {
        case .hearth:
            toFormat = toFormat.replacingOccurrences(of: " count/min", with: "")
            if let formated = Int(toFormat) {
                return formated as AnyObject
            } else {
                return 0.0 as AnyObject
            }
        case .height:
            toFormat = toFormat.replacingOccurrences(of: " cm", with: "")
            toFormat = toFormat.replacingOccurrences(of: " m", with: "")
            if let formated = Double(toFormat) {
                return formated as AnyObject
            } else {
                return 0.0 as AnyObject
            }
        case .weight:
            if toFormat.contains("lb") {
                toFormat = toFormat.replacingOccurrences(of: " lb", with: "")
                if let formated = Double(toFormat) {
                    return formated as AnyObject
                } else {
                    return 0.0 as AnyObject
                }
            } else if toFormat.contains("g") {
                toFormat = toFormat.replacingOccurrences(of: " g", with: "")
                if let formated = Double(toFormat) {
                    return formated as AnyObject
                } else {
                    return 0.0 as AnyObject
                }
            } else {
                if (Double(toFormat) != nil) {
                    return toFormat as AnyObject
                } else {
                    return 0.0 as AnyObject
                }
            }
            
        }
    }
    
}
