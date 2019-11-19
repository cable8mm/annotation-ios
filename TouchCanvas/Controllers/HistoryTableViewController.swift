//
//  HistoryTableViewController.swift
//  Doano
//
//  Created by 이삼구 on 2019/11/19.
//  Copyright © 2019 Doai. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class HistoryTableViewController: UITableViewController {

    var osHistories:JSON = [];

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let deviceId = UIDevice.current.identifierForVendor else {
            return
        }
        
        AF.request(K.API_SERVER_PREFIX + "os_findings.json?os_app_user_id=" + deviceId.uuidString).responseJSON { response in
            switch response.result {
            case let .success(value):
                self.osHistories = JSON(value)["data"]
                self.tableView.reloadData()
                break
            case let .failure(error):
                print(error)
                break
            }
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.osHistories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = self.osHistories[indexPath.row]["OsFinding"]["created"].stringValue
        
        return cell
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
