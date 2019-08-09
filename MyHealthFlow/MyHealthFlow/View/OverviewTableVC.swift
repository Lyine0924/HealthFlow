//
//  OverviewTableVC.swift
//  MyHealthFlow
//
//  Created by MyeongSoo-Linne on 08/08/2019.
//  Copyright © 2019 MyeongSoo-Linne. All rights reserved.
//

import UIKit
import HealthKit

class OverviewTableVC: UITableViewController {
    
    var todaySteps = 0
    var heartRate = 0
    
    var items = NSMutableDictionary()
    
    
    func hoursAgo(to: Int)-> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
        let strDate = dateFormatter.string(from: Date())//오늘 날짜를 string 타입으로 변경
          
                
        dateFormatter.timeZone = NSTimeZone(name: "GMT") as TimeZone?
        let dateStr = dateFormatter.date(from: strDate)
        
        let cal = NSCalendar.current
                
        guard let hoursAgo = cal.date(byAdding: .day, value: -to, to: dateStr!) else { return Date() }
        return hoursAgo
    }
    
    func nowTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = NSLocale(localeIdentifier: "ko_KR") as Locale
        
        let strDate = dateFormatter.string(from: Date())//오늘 날짜를 string 타입으로 변경
          
        return strDate
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        HealthKitService.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                return
            }
        }
        print("HealthKit Successfully Authorized.")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.setAllDetails()
        
        
    }

    
    // 이부분도 참고 필요
    func setAllDetails() {
        let today = Date()
        let initialDate = hoursAgo(to:2)
        //let initialDate = Date(timeIntervalSince1970: TimeInterval())
        HealthKitService.shared.getStepsCount(forSpecificDate: today) { (steps) in
            self.todaySteps = Int(steps)
            print("todaySteps is : \(self.todaySteps)")
            self.items.setValue(steps, forKey: "steps")
        }
        HealthKitService.shared.getHearthRate(from: initialDate, to: today) { (heartRate) in
            self.heartRate = Int(heartRate)
            print("heartRate now is : \(self.heartRate)")
            self.items.setValue(heartRate, forKey: "bpm")
        }
        
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsCell", for: indexPath) as! RecordCell
            cell.title.text = "걸음수"
            cell.Record.text = "\(self.items["steps"] ?? 0) 회"
            cell.lastRecordTime.text = "\(nowTime())"
            
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsCell", for: indexPath) as! RecordCell
            cell.title.text = "심박수"
            cell.Record.text = "\(self.items["bpm"] ?? 0) bpm"
            cell.lastRecordTime.text = "\(nowTime())"
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsCell", for: indexPath) as! RecordCell
            cell.title.text = "항목없음"
            cell.Record.text = ""
            cell.lastRecordTime.text = "\(nowTime())"
            
            return cell
        }
        
        // Configure the cell...
    }
    
    //didSelectRowAt 보다 먼저 실행됨
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailRecord", let dest = segue.destination as? RecordDetailVC {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let navTitle = items[indexPath.row]
                dest.navigationItem.title = "\(navTitle)"
                print("perform segue!")
            }
        }
    }
    
//    // 걸음 수를 가져오는 함수
//    func getSteps(for Date:Date,completion:@escaping (Double) -> Void) {
//        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
//
//        let startOfDay = Calendar.current.startOfDay(for: Date)
//        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)
//        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
//
//        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _ , result , error in
//            guard let result = result, let sum = result.sumQuantity() else {
//                print("there is a query error : \(error)")
//                completion(0.0)
//                return
//            }
//            completion(sum.doubleValue(for: HKUnit.count()))
//        }
//        HKHealthStore().execute(query)
//    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
