//
//  PartyHistoryViewController.swift
//  partymode
//
//  Created by Nikita on 3/9/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class PartyHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tbl_partycrowd: UITableView!
    
    @IBOutlet weak var crowdEmptyImage: UIImageView!
    
    var sectionsArray = [Sections]()
    var partycrowdArray = [PartyCrowdCellData]()
    
    
    var pastCrowdArray = [PartyCrowdCellData]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(PartyHistoryViewController.methodOfReloadTab3Screen(_:)), name:NSNotification.Name(rawValue: "notificationId_reloadTab3Screen"), object: nil)
    }
    func methodOfReloadTab3Screen(_ notification: Notification){
        //Take Action on Notification
        
        self.loadCrowsDataFromDB()
        
        
    }
    
    func loadCrowsDataFromDB(){
        
        // Thread.sleep(forTimeInterval:1)
        self.sectionsArray.removeAll()
        self.partycrowdArray.removeAll()
        self.pastCrowdArray.removeAll()
        
        self.partycrowdArray = DBManager.getInstance().getAllCrowdsData()
        let current_time_stamp = Int(NSDate().timeIntervalSince1970)
        for each in self.partycrowdArray {
            if (each.partyTimeStamp <  current_time_stamp - Constants.PASTCROWD_OFFSET_DURATION) {
                
                if var castedEach = each as? PartyCrowdCellData {
                    castedEach.setPastPartyValue(true)
                    self.pastCrowdArray.append(castedEach)
                }
                
            }
            
        }
        
        if self.pastCrowdArray.count > 0 {
            let pastcrowds = Sections(title: NSLocalizedString("pastcrowds", comment: ""), objects: self.pastCrowdArray)
            self.sectionsArray.append(pastcrowds)
        }
        
        self.tbl_partycrowd.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        crowdEmptyImage.image = UIImage(named: NSLocalizedString("imagename_empty_partymode", comment: ""))
        crowdEmptyImage.isHidden = true
        self.title = NSLocalizedString("partyhistory", comment: "")
        
        self.loadCrowsDataFromDB()
        if self.pastCrowdArray.count > 0 {
            setupRightItemButton()
        }
        
    }
    func setupRightItemButton(){
        self.navigationItem.rightBarButtonItem  = nil
        
        let button1 = UIBarButtonItem(image: UIImage(named: "ico_delete"), style: .plain, target: self, action:#selector(self.navigationBarRightEditButtonTapped))
        self.navigationItem.rightBarButtonItem  = button1
    }
    func navigationBarRightEditButtonTapped(){
        let alertController = UIAlertController(title: NSLocalizedString("del_partycrowd_title",comment:""), message: NSLocalizedString("del_partycrowd_text",comment:""), preferredStyle: .alert)
        let OKAction = UIAlertAction(title: NSLocalizedString("delete",comment:""), style: .destructive) {
            (action:UIAlertAction!) in
            for eachItem in self.pastCrowdArray {
                let isDeleted = DBManager.getInstance().deleteCrowdData(eachItem)
                if isDeleted == true {
                    
                    self.sectionsArray[0].partycrowds.removeFirst()
                    self.tbl_partycrowd.reloadData()
                }
            }
            
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel",comment:"").uppercased(), style: .cancel)
        { (action:UIAlertAction!) in }
        
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion:nil)
        
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsArray[section].headings
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sectionsArray[section].partycrowds.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eachData: PartyCrowdCellData = sectionsArray[indexPath.section].partycrowds[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId_partycrowdTableView, for: indexPath as IndexPath) as! PartyCrowdTableViewCell
        cell.parentView = self
        cell.eachData = eachData
        cell.showReactivateButton()
        //cell.hideReactivateButton()
        cell.partyname.text = eachData.title
        cell.partyCreatorName.text = ""
        cell.partyTime.text = TimeStampClass().checkTimeStamp(stamp: eachData.partyTimeStamp, time: eachData.partyTime) //eachData.partyTime
        cell.partyLocation.text = eachData.location
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let eachData: PartyCrowdCellData = sectionsArray[indexPath.section].partycrowds[indexPath.row]
        UserDefaults.standard.set("YES", forKey: "isFromPartyHistory")
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
        //viewController.shouldBeReactivate = true
        
        GlobalData.sharedInstance.setSelectedPartyCrowdItem(eachData)
        self.navigationController?.pushViewController(viewController, animated: false)
        
    }
    
}
