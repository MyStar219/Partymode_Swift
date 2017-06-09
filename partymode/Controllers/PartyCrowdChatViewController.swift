//
//  PartyCrowdChatViewController.swift
//  partymode
//
//  Created by Nikita on 1/16/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class PartyCrowdChatViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var container_chatView: UIView!
    @IBOutlet weak var container_friendsView: UIView!
    @IBOutlet weak var container_picView: UIView!
    
    
    @IBOutlet weak var partytimeLabel: UILabel!
    @IBOutlet weak var partyLocationLabel: UILabel!
    @IBOutlet weak var segmentcontrol: UISegmentedControl!
    
    @IBOutlet weak var AcceptCancelView: UIView!
    @IBOutlet weak var AcceptButton: UIView!
    @IBOutlet weak var CancelButton: UIView!
    
    @IBOutlet weak var regretAlertView: UIView!
    @IBOutlet weak var alert_title: UILabel!
    @IBOutlet weak var alert_text: UILabel!
    @IBOutlet weak var alert_havePlanButton: UIButton!
    @IBOutlet weak var alert_StatyHomeButton: UIButton!
    @IBOutlet weak var alert_textfield: UITextField!
    @IBOutlet weak var alert_AcceptButton: UIButton!
    @IBOutlet weak var alert_RegretButton: UIButton!
    
    @IBOutlet weak var darkBgView: UIView!
    
    var createdPartyCrowdItem: PartyCrowdCellData! = nil
    var sender:String = ""
    var backButton:UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.navigationItem.hidesBackButton = true
        backButton = UIBarButtonItem(image: UIImage(named: "ico_back"), style: .plain, target: self, action: #selector(PartyCrowdChatViewController.back(sender:)))
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfGotoHomeView(_:)), name:NSNotification.Name(rawValue: "notificationId_gotoPartyPeopleTab"), object: nil)
        self.navigationItem.leftBarButtonItem = backButton
    }
    func back(sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_reloadTab3Screen"), object: nil)
        UserDefaults.standard.set("", forKey: "currentScreen")
        //if self.sender == "crowdeditView" {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 4], animated: true);
//        }
//        else {
//            _ = navigationController?.popViewController(animated: true)
//        }
    }
    func methodOfGotoHomeView(_ notification: Notification){
        //Take Action on Notification
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_reloadTab3Screen"), object: nil)
        UserDefaults.standard.set("", forKey: "currentScreen")
        let isFromPartyHistory = UserDefaults.standard.string(forKey: "isFromPartyHistory")
        if isFromPartyHistory == "YES" {
            let when = DispatchTime.now() + 0.0
            DispatchQueue.main.asyncAfter(deadline: when) {
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 4], animated: false);
            }
        }
        else {
            let when = DispatchTime.now() + 0.0
            DispatchQueue.main.asyncAfter(deadline: when) {
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: false);
            }
            
            
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set("crowdchat", forKey: "currentScreen")
        
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        navigationController?.navigationBar.barTintColor = Constants.tab_color_partycrowds
        self.title = self.createdPartyCrowdItem.title
        partytimeLabel.text = TimeStampClass().checkTimeStamp(stamp: self.createdPartyCrowdItem.partyTimeStamp, time: self.createdPartyCrowdItem.partyTime)
        partyLocationLabel.text = self.createdPartyCrowdItem.location
        
        UserDefaults.standard.set(self.createdPartyCrowdItem.id, forKey: "currentChatScreen_CrowdId")
        
        if self.createdPartyCrowdItem.status == Constants.CROWD_STATUS_PENDING || self.createdPartyCrowdItem.status == Constants.CROWD_STATUS_DECLINED {
        
            segmentcontrol.selectedSegmentIndex = 1
            self.container_chatView.alpha = 0
            self.container_friendsView.alpha = 1
            self.container_picView.alpha = 0
            
        }
        else if self.createdPartyCrowdItem.status == Constants.CROWD_STATUS_DO_NO_CHANGE_STATUS {
            setupRightItemButton()
        }
        
        //AcceptCancelView.isHidden = false
        //self.createdPartyCrowdItem = PartyCrowdCellData(id:createdPartyCrowdItem.id, title: createdPartyCrowdItem.title, location: createdPartyCrowdItem.location, partyTimeStamp: createdPartyCrowdItem.partyTimeStamp, partyTime: createdPartyCrowdItem.partyTime, invite_friends: createdPartyCrowdItem.invite_friends, color: createdPartyCrowdItem.color, members: [])
//        let isInserted = DBManager.getInstance().updateCrowdData(self.createdPartyCrowdItem)//.addCrowdData(self.createdPartyCrowdItem)
//        if isInserted {
//            DBUtil.invokeAlertMethod("", strBody: "Record Inserted successfully.", delegate: nil)
//        } else {
//            DBUtil.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
//        }
        
        // Do any additional setup after loading the view.
    }

    func setupRightItemButton(){
        self.navigationItem.rightBarButtonItem  = nil
        if self.createdPartyCrowdItem.isPastParty == true {
            let button1 = UIBarButtonItem(image: UIImage(named: "ico_delete"), style: .plain, target: self, action:#selector(self.navigationBarRightDeleteButtonTapped))
            self.navigationItem.rightBarButtonItem  = button1
        }
        else {
            let button1 = UIBarButtonItem(image: UIImage(named: "ico_edit"), style: .plain, target: self, action:#selector(self.navigationBarRightEditButtonTapped))
            
            self.navigationItem.rightBarButtonItem  = button1
        }
        
    }
    func navigationBarRightDeleteButtonTapped(){
        let alertController = UIAlertController(title: "Partymode", message: NSLocalizedString("del_partycrowd_alert",comment:""), preferredStyle: .alert)
        let OKAction = UIAlertAction(title: NSLocalizedString("alert_yes",comment:""), style: .destructive) {
            (action:UIAlertAction!) in
            let isDeleted = DBManager.getInstance().deleteCrowdData(self.createdPartyCrowdItem)
            if isDeleted == true {
                self.back(sender:self.backButton)
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("alert_No",comment:""), style: .cancel)
        { (action:UIAlertAction!) in }
        
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion:nil)
        
        
        
    }
    func navigationBarRightEditButtonTapped(){
        //if self.sender == "crowdeditView" {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_sendDataToMemberSelectAndEditScreen"), object: self.createdPartyCrowdItem)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_sendgotochatFlagValueToEditScreen"), object: nil)
        
            _ = self.navigationController?.popViewController(animated: false)
//        }
//        else {
//            let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "PartyCrowdEditViewController") as! PartyCrowdEditViewController
//            viewController.createdPartyCrowdItem = self.createdPartyCrowdItem
//            viewController.sender = "chatEdit"
//            self.navigationController?.pushViewController(viewController, animated: true)
//        }
    }

    @IBAction func segmentItemTapped(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_reloadChatData"), object: nil)
        if (sender as AnyObject).selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.container_chatView.alpha = 1
                self.container_friendsView.alpha = 0
                self.container_picView.alpha = 0
                UserDefaults.standard.set(self.createdPartyCrowdItem.id, forKey: "currentChatScreen_CrowdId")
            })
        }
        else if (sender as AnyObject).selectedSegmentIndex == 1 {
            UIView.animate(withDuration: 0.5, animations: {
                self.container_chatView.alpha = 0
                self.container_friendsView.alpha = 1
                self.container_picView.alpha = 0
                UserDefaults.standard.set("", forKey: "currentChatScreen_CrowdId")
            })
        }
        else {
            UIView.animate(withDuration: 0.5, animations: {
                self.container_chatView.alpha = 0
                self.container_friendsView.alpha = 0
                self.container_picView.alpha = 1
                UserDefaults.standard.set("", forKey: "currentChatScreen_CrowdId")
            })
        }
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        print(segmentcontrol.selectedSegmentIndex)
        if segmentcontrol.selectedSegmentIndex != 2 {
            segmentcontrol.selectedSegmentIndex = (segmentcontrol.selectedSegmentIndex + 1) % segmentcontrol.numberOfSegments
            segmentItemTapped(segmentcontrol)
        }
        
    }
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
        print(segmentcontrol.selectedSegmentIndex)
        if segmentcontrol.selectedSegmentIndex != 0 {
            segmentcontrol.selectedSegmentIndex = (segmentcontrol.selectedSegmentIndex - 1) % segmentcontrol.numberOfSegments
            if(segmentcontrol.selectedSegmentIndex == -1){
                segmentcontrol.selectedSegmentIndex = segmentcontrol.numberOfSegments-1
            }
            
            segmentItemTapped(segmentcontrol)
        }
        
    }
    
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            print("pressed back button")
            UserDefaults.standard.set("", forKey: "currentChatScreen_CrowdId")
            
        }
    }

}
