//
//  StationStatusDetailViewController.swift
//  FindStations
//
//  Created by Cameron Erdogan on 10/1/16.
//  Copyright © 2016 Cameron Erdogan. All rights reserved.
//

import UIKit

class StationStatusDetailViewController: UIViewController {

    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var capacity: UILabel!
    @IBOutlet weak var is_renting: UILabel!
    @IBOutlet weak var is_installed: UILabel!
    @IBOutlet weak var is_returning: UILabel!
    @IBOutlet weak var bikes_available: UILabel!
    @IBOutlet weak var bikes_disabled: UILabel!
    @IBOutlet weak var docks_available: UILabel!
    @IBOutlet weak var docks_disabled: UILabel!
    
    var station : Station?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let s = station{
            name.text = s.name
            capacity.text = "\(s.capacity)"
            
//            let rent_text = s.status!.is_renting ? "YES" : "NO"
//            is_renting.text = "\(rent_text)"
//            let installed_text = s.status!.is_installed ? "YES" : "NO"
//            is_installed.text = "\(installed_text)"
//            let returning_text = s.status!.is_returning ? "YES" : "NO"
//            is_returning.text = "\(returning_text)"
            let rent_text = s.is_renting ? "YES" : "NO"
            is_renting.text = "\(rent_text)"
            let installed_text = s.is_installed ? "YES" : "NO"
            is_installed.text = "\(installed_text)"
            let returning_text = s.is_returning ? "YES" : "NO"
            is_returning.text = "\(returning_text)"
            
//            bikes_available.text = "\(s.status!.num_bikes_available)"
//            bikes_disabled.text = "\(s.status!.num_bikes_disabled)"
//            docks_available.text = "\(s.status!.num_docks_available)"
//            docks_disabled.text = "\(s.status!.num_docks_disabled)"
            bikes_available.text = "\(s.num_bikes_available)"
            bikes_disabled.text = "\(s.num_bikes_disabled)"
            docks_available.text = "\(s.num_docks_available)"
            docks_disabled.text = "\(s.num_docks_disabled)"
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backToMap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
