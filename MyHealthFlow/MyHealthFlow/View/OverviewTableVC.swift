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
    
    var steps = 1000
    var heartRate = 80
    
    var items = [String]()
    
    
    func nowTime()-> String{
        let now = Date()
        let dateFormatter = DateFormatter()
        // Locale
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: now)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
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
    }

    // MARK: - Table view data source

    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return self.tableView.numberOfSections
//    }
 

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsCell", for: indexPath) as! RecordCell
            cell.title.text = "걸음수"
            cell.Record.text = "\(self.steps) 회"
            cell.lastRecordTime.text = "\(nowTime())"
            items.append(cell.title.text!)
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsCell", for: indexPath) as! RecordCell
            cell.title.text = "심박수"
            cell.Record.text = "\(self.heartRate) bpm"
            cell.lastRecordTime.text = "\(nowTime())"
            items.append(cell.title.text!)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsCell", for: indexPath) as! RecordCell
            cell.title.text = "항목없음"
            cell.Record.text = ""
            cell.lastRecordTime.text = "\(nowTime())"
            items.append(cell.title.text!)
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
