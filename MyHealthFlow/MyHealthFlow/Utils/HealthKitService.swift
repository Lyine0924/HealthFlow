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
    
    @available(iOS 12.0, *)
    // 심박수에 관한 정보 가져오는 부분 -> 현재는 최근 심박수를 가져오는 기능을 담당함
    func getHearthRate(from: Date, to: Date, completion: @escaping (Double) -> Void) {
        let hearthRateType = HKSampleType.quantityType(forIdentifier: .heartRate)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for:now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
    
        // replaced options parameter with .discreteMostRecent
        let query = HKStatisticsQuery(quantityType: hearthRateType, quantitySamplePredicate: predicate, options: .discreteMostRecent){
             (_,result,error) in
            var resultCount = 0
            guard let result = result else {
                print("Failed to fetch heart rate")
                completion(Double(resultCount))
                return
            }
            
            // More cahanges here in order to get bpm value
            guard let beatsPerMinute: Double = result.mostRecentQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) else { return }
            
            DispatchQueue.main.async {
                resultCount = Int(beatsPerMinute)
                print("resultCount is : \(resultCount)")
            }
        }
        healthKitStore.execute(query)
    }
    /*
    func createAndExecuteQueries(Type:Qu ,predicate: NSPredicate, option: HKStatisticsOptions, handler: (HKStatisticsQuery, HKStatistics?, NSError?) -> Void) {

        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options:[option], completionHandler: handler)

        healthKitStore.executeQuery(query)

    }
    */
    
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
    
    
    func getFormated(sample:HKQuantity, forValue: HealthValue) -> AnyObject {
        var toFormat = "\(sample)"
        if forValue == .hearth {
            toFormat = toFormat.replacingOccurrences(of: " count/s", with: "")
            if let formated = Int(toFormat) {
                return formated as AnyObject
            } else {
                return 0.0 as AnyObject
            }
        }
        else {
            return 0.0 as AnyObject
        }
    }
    
    
    
}
