//
//  Tab3PartycrowdsViewController.swift
//  partymode
//
//  Created by Nikita on 1/12/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit
class Tab3PartycrowdsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var addButtonView: UIView!
    @IBOutlet weak var tbl_partycrowd: UITableView!
    
    @IBOutlet weak var crowdEmptyImage: UIImageView!
    //Constants.cellId_partycrowdTableView
    @IBOutlet weak var toPartyHistoryButton: UIButton!
    
    var sectionsArray = [Sections]()
    var partycrowdArray = [PartyCrowdCellData]()
    
    var invitationsCrowdArray = [PartyCrowdCellData]()
    var pastCrowdArray = [PartyCrowdCellData]()
    var activeCrowdArray = [PartyCrowdCellData]()
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(Tab3PartycrowdsViewController.methodOfReloadTab3Screen(_:)), name:NSNotification.Name(rawValue: "notificationId_reloadTab3Screen"), object: nil)
    }
    func methodOfReloadTab3Screen(_ notification: Notification){
        //Take Action on Notification
        
        self.loadCrowsDataFromDB()
        
        
    }
    func loadCrowsDataFromDB(){
        
       // Thread.sleep(forTimeInterval:1)
        self.sectionsArray.removeAll()
        self.partycrowdArray.removeAll()
        self.invitationsCrowdArray.removeAll()
        self.pastCrowdArray.removeAll()
        self.activeCrowdArray.removeAll()
        
        
        self.partycrowdArray = DBManager.getInstance().getAllCrowdsData()
        let current_time_stamp = Int(NSDate().timeIntervalSince1970)
        
        for each in self.partycrowdArray {
            if (each.partyTimeStamp >= current_time_stamp) {
                if each.status == Constants.CROWD_STATUS_PENDING {
                    self.invitationsCrowdArray.append(each)
                }
                else if each.status == Constants.CROWD_STATUS_ACCEPTED {
                     self.activeCrowdArray.append(each)
                }
                else if each.status == Constants.CROWD_STATUS_DECLINED {
                    print("declined partycrowd:\(each)")
                    self.invitationsCrowdArray.append(each)
                }
                else {
                     self.activeCrowdArray.append(each)
                }
            }
            else {
                if (each.partyTimeStamp >= current_time_stamp - Constants.PASTCROWD_OFFSET_DURATION) {
                    self.pastCrowdArray.append(each)
                }
            }
        }

        if self.invitationsCrowdArray.count > 0 {
            let invitations = Sections(title: NSLocalizedString("crowds_category_invited", comment: ""), objects: self.invitationsCrowdArray)
            self.sectionsArray.append(invitations)
        }
        
        if self.activeCrowdArray.count > 0 {
            let activecrowds = Sections(title: NSLocalizedString("crowds_category_active", comment: ""), objects: self.activeCrowdArray)
            self.sectionsArray.append(activecrowds)
        }
        
        if self.pastCrowdArray.count > 0 {
            let pastcrowds = Sections(title: NSLocalizedString("crowds_category_past", comment: ""), objects: self.pastCrowdArray)
            self.sectionsArray.append(pastcrowds)
        }
        
        self.tbl_partycrowd.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        crowdEmptyImage.image = UIImage(named: NSLocalizedString("imagename_empty_partymode", comment: ""))
        toPartyHistoryButton.setTitle(NSLocalizedString("to_partyhistory", comment: "").uppercased(), for: UIControlState())
        self.loadCrowsDataFromDB()
        makeAddCrowdButtonCircleShadow()
        makeHistoryButtonShadow()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeAddCrowdButtonCircleShadow(){
        addButtonView.layer.cornerRadius = addButtonView.bounds.width / 2
        addButtonView.layer.shadowColor = UIColor.darkGray.cgColor
        addButtonView.layer.shadowOpacity = 1
        addButtonView.layer.shadowOffset = CGSize(width: 2, height: 2)
        addButtonView.layer.borderWidth = 0
    }
    
    @IBAction func addPartyCrowdCircleButtonPressed(_ sender: Any) {
        print("addPartyCrowdCircleButtonPressed in Tab3")
        UserDefaults.standard.set("false", forKey: "shouldgotoPartypeopleTab")
        let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "CreatePartyCrowdViewController") as! CreatePartyCrowdViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func transparentAddPartyCrowdButtonPressed(_ sender: Any) {
        print("addPartyCrowdCircleButtonPressed in Tab3")
        UserDefaults.standard.set("false", forKey: "shouldgotoPartypeopleTab")
        let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "CreatePartyCrowdViewController") as! CreatePartyCrowdViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsArray[section].headings
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        crowdEmptyImage.isHidden = true
        return sectionsArray[section].partycrowds.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var eachData: PartyCrowdCellData = sectionsArray[indexPath.section].partycrowds[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId_partycrowdTableView, for: indexPath as IndexPath) as! PartyCrowdTableViewCell
        cell.parentView = self
        cell.eachData = eachData
        
        if eachData.status == Constants.CROWD_STATUS_ACCEPTED {
            cell.showSwitch_On()
        }
        else if eachData.status == Constants.CROWD_STATUS_DECLINED {
            cell.showSwitch_Off()
        }
        else if eachData.status == Constants.CROWD_STATUS_PENDING {
            cell.showSwitch_Pending()
        }
        else {
            cell.showEditButton()
        }
        
        cell.partyname.text = eachData.title
        cell.partyCreatorName.text = ""
        cell.partyTime.text = TimeStampClass().checkTimeStamp(stamp: eachData.partyTimeStamp, time: eachData.partyTime) //eachData.partyTime
        cell.partyLocation.text = eachData.location
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let eachData: PartyCrowdCellData = sectionsArray[indexPath.section].partycrowds[indexPath.row]
        UserDefaults.standard.set("false", forKey: "shouldgotoPartypeopleTab")
        UserDefaults.standard.set("NO", forKey: "isFromPartyHistory")
//        let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "PartyCrowdChatViewController") as! PartyCrowdChatViewController
//        viewController.createdPartyCrowdItem = eachData
//         GlobalData.sharedInstance.setSelectedPartyCrowdItem(eachData)
//        if self.tableView(tableView, titleForHeaderInSection: indexPath.section)! == NSLocalizedString("pastcrowds", comment: "") {
//            viewController.sender = "partyhistory"
//        }
//        self.navigationController?.pushViewController(viewController, animated: true)
        
        let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "CreatePartyCrowdViewController") as! CreatePartyCrowdViewController
        viewController.temp_createdPartyCrowdItem = eachData
        viewController.shouldGoForward = true
        //viewController.shouldGoToEdit = true
        GlobalData.sharedInstance.setSelectedPartyCrowdItem(eachData)
        self.navigationController?.pushViewController(viewController, animated: false)
        
    }
    func makeHistoryButtonShadow(){
        toPartyHistoryButton.layer.cornerRadius = 3
        toPartyHistoryButton.layer.shadowColor = UIColor.darkGray.cgColor
        toPartyHistoryButton.layer.shadowOpacity = 1
        toPartyHistoryButton.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        toPartyHistoryButton.layer.borderWidth = 0
        toPartyHistoryButton.layer.shadowRadius = 2.0
        toPartyHistoryButton.layer.masksToBounds = false
    }
    @IBAction func toPartyHistoryButtonPressed(_ sender: Any) {
        UserDefaults.standard.set("false", forKey: "shouldgotoPartypeopleTab")
        let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "PartyHistoryViewController") as! PartyHistoryViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
