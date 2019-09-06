//
//  LabelTableViewController.swift
//  Doano
//
//  Created by 이삼구 on 20/05/2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class LabelTableViewController: UITableViewController {

    var pictureTypeId:Int   = 1

    var checkCount:Int = 0 {
        didSet {
            if checkCount > 0 {
                self.saveButton.title = "Save(\(checkCount))"
                self.saveButton.isEnabled = true
            } else {
                self.saveButton.title = "Save"
                self.saveButton.isEnabled = false
            }
        }
    }
    
    /// 서버에서 읽어온 라벨
    /// - return: JSON
    var osAllRawLabels:JSON = [];

    /// 서버에서 읽어온 섹션 리스트
    /// - return: [String]
    var osSectionNames = [String]()
    
    /// 이용자가 선택한 라벨
    /// - return: [Int]
    var selectedLabels = [Int]()
    
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var sectionSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.saveButton.isEnabled = false
        
        AF.request(K.API_SERVER_PREFIX + "os_picture_labels/index_compact.json?os_picture_type_id=" + String(self.pictureTypeId)).responseJSON {response in
            switch response.result {
            case let .success(value):
                // [{"id":null,"name":"Cataract","values":[{"id":33,"name":"Cataract"}]}...
                self.osAllRawLabels = JSON(value)["data"]
                // sectionSegmentedControl
                if(JSON(value)["section_names"].exists()) {
                    self.osSectionNames = JSON(value)["section_names"].arrayValue.map { $0.stringValue}
                    self.sectionSegmentedControl.updateTitle(array: self.osSectionNames)
                } else {
                    self.sectionSegmentedControl.removeFromSuperview();
                }
                self.tableView.reloadData()
                guard let parent = self.parent as? LabelViewController else {
                    return
                }
                parent.resetSegmentedControl(rawLabels: self.osAllRawLabels)

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
        return self.osAllRawLabels.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.osAllRawLabels[section]["values"].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelTableReuseIdentifier", for: indexPath)
        // Configure the cell...
        cell.textLabel?.text = self.osAllRawLabels[indexPath.section]["values"][indexPath.row]["name"].stringValue

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.osAllRawLabels[section]["name"].stringValue
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = cell.accessoryType == .checkmark ? .none : .checkmark

            if cell.accessoryType == .none {
                self.checkCount -= 1
                self.selectedLabels.removeAll(where: { $0 == indexPath.row})
            } else {
                self.checkCount += 1
                self.selectedLabels.append(indexPath.row)
            }
        }
        tableView.deselectRow(at:indexPath, animated: true)
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.osSectionNames
    }

    // MARK: - Actions
    
    @IBAction func save(_ sender: Any) {
        guard let parent = self.presentingViewController?.children[0] as? ViewController else {
            return
        }
        parent.saveLabels(self.selectedLabels)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        guard let parent = self.presentingViewController?.children[0] as? ViewController else {
            return
        }
        parent.removeLastLine()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectSection(_ sender: UISegmentedControl) {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: sender.selectedSegmentIndex), at: .top, animated: true)
    }
    
    func groupChanged(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: sender.selectedSegmentIndex), at: .top, animated: true)
    }
}

extension UISegmentedControl {
    
    func updateTitle(array titles: [String]) {
        
        removeAllSegments()
        
        var k=0

        for title in titles {
            insertSegment(withTitle: title, at: k, animated: false)
            k += 1
        }
     
        self.selectedSegmentIndex = 0
    }
}
