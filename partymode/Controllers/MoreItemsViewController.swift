//
//  MoreItemsViewController.swift
//  partymode
//
//  Created by Nikita on 1/14/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class MoreItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tbl_MoreItems: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfGotoHomeView(_:)), name:NSNotification.Name(rawValue: "notificationId_gotoPartyPeopleTab"), object: nil)
    }
    func methodOfGotoHomeView(_ notification: Notification){
        //Take Action on Notification
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = NSLocalizedString("more", comment: "")
        UserDefaults.standard.set("false", forKey: "shouldgotoPartypeopleTab")
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.isHidden = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "moreItemCell", for: indexPath)
        let lineFrame = CGRect(x:0, y:43.5, width:tbl_MoreItems.bounds.size.width, height:0.5)
        let line = UIView(frame: lineFrame)
        line.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        cell.addSubview(line)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("settings", comment: "")//"Settings"
            
            break
        case 1:
            cell.textLabel?.text = NSLocalizedString("impressum", comment: "")//"Imprint"
            
            break
        case 2:
            cell.textLabel?.text = NSLocalizedString("feedback", comment: "")//"Feedback"
            
            break
        case 3:
            cell.textLabel?.text = NSLocalizedString("menu_faq", comment: "")//"Feedback"
            
            break
        default:
            
            break
           
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            viewController.title = NSLocalizedString("settings", comment: "")
            self.navigationController?.pushViewController(viewController, animated: true)
        case 1:
            let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "ImprintViewController") as! ImprintViewController
            viewController.title = NSLocalizedString("impressum", comment: "")
            self.navigationController?.pushViewController(viewController, animated: true)
        case 2:
            let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
            viewController.title = NSLocalizedString("feedback", comment: "")
            self.navigationController?.pushViewController(viewController, animated: true)
        case 3:
            let url = URL(string: Constants.SupportFAQ_LINK)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        default: break
            
        }
    }

}
