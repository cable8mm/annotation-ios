//
//  LabelTableViewController.swift
//  Doano
//
//  Created by 이삼구 on 20/05/2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit

class DiseaseTableViewController: UITableViewController {

  var pictureTypeId: Int = 1
  var osAllRawLabels: JSON = []

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem

    AF.request(
      K.API_SERVER_PREFIX + "os_picture_type_diseases.json?os_picture_type_id="
        + String(self.pictureTypeId)
    ).responseJSON { response in
      switch response.result {
      case let .success(value):
        // {"OsPictureTypeDisease":{"id":2,"os_picture_type_id":2,"name":"GON","is_active":true,"created":null}}
        self.osAllRawLabels = JSON(value)["data"]
        self.tableView.reloadData()
        break
      case let .failure(error):
        print(error)
        break
      }
    }

    //        guard let rawPictureLabels = UserDefaults.standard.value(forKey: "UDRawPictureLabels" + String(pictureTypeId)) as? Data else { return }
    //        self.osAllRawLabels = JSON(rawPictureLabels)
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.osAllRawLabels.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "labelTableReuseIdentifier", for: indexPath)

    // Configure the cell...
    cell.textLabel?.text =
      self.osAllRawLabels[indexPath.row]["OsPictureTypeDisease"]["name"].stringValue

    return cell
  }

  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    if let cell = tableView.cellForRow(at: indexPath) {
      cell.accessoryType = .none
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let cell = tableView.cellForRow(at: indexPath) {
      cell.accessoryType = .checkmark

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
