//
//  File.swift
//  MyHealthFlow
//
//  Created by MyeongSoo-Linne on 08/08/2019.
//  Copyright © 2019 MyeongSoo-Linne. All rights reserved.
//

import HealthKit

class HealthKitSetupAssistant {
    
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
        //let healthKitTypesToWrite: Set<HKSampleType> = [] //추후 작성을 위해 코드만 추가함
        let healthKitTypesToRead: Set<HKSampleType> = [step,heartRate]
        
        // 4. HealthKit 인증하기
        HKHealthStore().requestAuthorization(toShare: [], read: healthKitTypesToRead) { (success, error) in
            completion(success,error)
        }
    }
    
    
}
