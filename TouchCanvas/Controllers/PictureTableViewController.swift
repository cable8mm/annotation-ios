//
//  PictureTableViewController.swift
//  Doano
//
//  Created by 이삼구 on 07/05/2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import Alamofire
import SDWebImage
import SwiftyJSON
import UIKit

class PictureTableViewController: UITableViewController, UIGestureRecognizerDelegate {

  @IBOutlet weak var titleSegmentedControl: UISegmentedControl!

  var rowCount = 0
  var osAllRawPictures: JSON = []
  var jsonPictureTypes: JSON = []

  // https://stackoverflow.com/questions/39943265/how-to-dismiss-modal-form-sheet-when-clicking-outside-of-view
  var tap: UITapGestureRecognizer!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem

    guard let rawPictureTypes = UserDefaults.standard.value(forKey: "UDRawPictureTypes") as? Data
    else { return }
    self.jsonPictureTypes = JSON(rawPictureTypes)

    self.titleSegmentedControl.removeAllSegments()

    for (k, osPictureType) in self.jsonPictureTypes {
      let name = osPictureType["OsPictureType"]["name"].rawString() ?? "No Name"
      //            let index = osPictureType["OsPictureType"]["id"].int ?? 10000
      guard let index = Int(k) else {
        continue
      }
      self.titleSegmentedControl.insertSegment(withTitle: name, at: index, animated: false)
    }

    self.titleSegmentedControl.addTarget(
      self, action: #selector(segmentSelected(sender:)), for: UIControl.Event.valueChanged)
    self.titleSegmentedControl.selectedSegmentIndex = 0
    self.segmentSelected(sender: self.titleSegmentedControl)
  }

  override func viewDidAppear(_ animated: Bool) {

    tap = UITapGestureRecognizer(target: self, action: #selector(onTap(sender:)))
    tap.numberOfTapsRequired = 1
    tap.numberOfTouchesRequired = 1
    tap.cancelsTouchesInView = false
    tap.delegate = self
    self.view.window?.addGestureRecognizer(tap)
  }

  internal func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    return true
  }

  internal func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch
  ) -> Bool {
    let location = touch.location(in: self.navigationController?.view)

    if self.view.point(inside: location, with: nil) {
      return false
    } else {
      return true
    }
  }

  @objc private func onTap(sender: UITapGestureRecognizer) {

    self.view.window?.removeGestureRecognizer(sender)
    self.dismiss(animated: true, completion: nil)
  }

  @objc func segmentSelected(sender: UISegmentedControl) {
    // https://os.doai.ai/os_raw_pictures.json?page=1&os_picture_type_id=1
    //        {"code":0,"name":"Response Success","message":"Response Success","url":"\/os_raw_pictures.json","data":[{"OsRawPicture":{"id":24,"os_picture_type_id":1,"display_name":"00025849","original_name":"\/uploads\/00025849_043_1.png","width":null,"height":null,"ext":null,"byte":null,"created":"2019-02-11 05:53:22","modified":"2019-02-11 05:53:22"},"OsPictureType":{"id":1,"name":"Chest ... X-ray","code":"CXR","is_polygon_type":true,"is_check_type":false,"is_active":true}}]}

    guard sender.selectedSegmentIndex >= 0 else {
      return
    }

    AF.request(
      K.API_SERVER_PREFIX + "os_raw_pictures.json?page=1&os_picture_type_id="
        + self.jsonPictureTypes[sender.selectedSegmentIndex]["OsPictureType"]["id"].stringValue
    ).responseJSON { response in
      switch response.result {
      case let .success(value):
        let osRawPictures = JSON(value)["data"]

        self.osAllRawPictures = JSON(value)["data"]
        self.rowCount = osRawPictures.count

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
    return self.rowCount
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

    // Configure the cell...
    cell.textLabel?.text =
      self.osAllRawPictures[indexPath.row]["OsRawPicture"]["display_name"].stringValue

    let imageUrl =
      K.API_SERVER_PREFIX
      + self.osAllRawPictures[indexPath.row]["OsRawPicture"]["original_name"].stringValue
    cell.imageView?.sd_setImage(
      with: URL(string: imageUrl), placeholderImage: UIImage(named: "default-thumbnail.jpg"),
      options: SDWebImageOptions(rawValue: 0),
      completed: { (image, error, cacheType, imageURL) in
        // Perform operation.
      })
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let parent = self.presentingViewController?.children[0] as? ViewController else {
      return
    }

    //        parent.viewPicture(url: K.API_SERVER_PREFIX + self.osAllRawPictures[indexPath.row]["OsRawPicture"]["original_name"].stringValue)
    parent.viewPicture(data: self.osAllRawPictures[indexPath.row])
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

  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
  }
}
