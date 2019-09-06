//
//  LabelViewController.swift
//  Doano
//
//  Created by 이삼구 on 04/07/2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import SwiftyJSON

class LabelViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var pictureTypeId:Int   = 0
    var labelTableViewController: LabelTableViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    func resetSegmentedControl(rawLabels: JSON) -> Void {
        self.segmentedControl.removeAllSegments()

        var index = 0

        for (_, json) in rawLabels {
            self.segmentedControl.insertSegment(withTitle: json["name"].stringValue as String?, at: index, animated: false)
            index += 1
        }
        
        self.segmentedControl.selectedSegmentIndex = 0;
    }
    
    // MARK: - Actions
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        self.labelTableViewController?.groupChanged(sender)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "embedLabelTableViewControllerSegue",
            let vc = segue.destination as? LabelTableViewController {
            self.labelTableViewController = vc
        }
    }

    @IBAction func cancel(_ sender: Any) {
        guard let parent = self.presentingViewController?.children[0] as? ViewController else {
            return
        }
        parent.removeLastLine()
        dismiss(animated: true, completion: nil)
    }
}
