//
//  PartyPeopleEditViewController.swift
//  partymode
//
//  Created by Nikita on 1/18/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit
import APAddressBook
class PartyPeopleEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource ,PartypeopleEditCellDelegate{
    
    @IBOutlet weak var tbl_partypeople: UITableView!
    
    @IBOutlet weak var partyEmptyImage: UIImageView!
    
    var sectionsArray = [Sections]()
    var totalArray = [PartyPeopleCellData]()
    var visibleArray = [PartyPeopleCellData]()
    var blockedArray = [PartyPeopleCellData]()
    
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
        self.title = NSLocalizedString("edit_partypeople", comment: "")//"editpartypeople"
        
        partyEmptyImage.image = UIImage(named: NSLocalizedString("imagename_empty_partypeople", comment: ""))
        
        setupRightItemButton()
        
        self.sectionsArray.removeAll()
        for each in self.totalArray {
            if each.user_state == 2 {
                self.blockedArray.append(each)
            }
            else{
                self.visibleArray.append(each)
            }
        }
        let partypeoples = Sections(title: NSLocalizedString("partypeople", comment: ""), objects: visibleArray)
        self.sectionsArray.append(partypeoples)
        
        //self.removeDuplicatsFromContacts(partypeopleArray: partypeopleArray)
        let blocks = Sections(title: NSLocalizedString("blocked", comment: ""), objects: self.blockedArray)
        self.sectionsArray.append(blocks)
        self.tbl_partypeople.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsArray[section].headings
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        partyEmptyImage.isHidden = true
        if section == 0 {
            return sectionsArray[section].partypeoples.count
        }
        else{
            return sectionsArray[section].partypeoples.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eachData: PartyPeopleCellData = sectionsArray[indexPath.section].partypeoples[indexPath.row]
        
        let cell = tbl_partypeople.dequeueReusableCell(withIdentifier: Constants.cellId_partypeopleeditTableView, for: indexPath as IndexPath) as! PartyPeopleEditTableViewCell
        // set the delegate
        cell.delegate = self
        cell.eachData = eachData
        cell.selfIndex = indexPath.row
        
        if cell.eachData.pmode == Constants.PARTYMODE_NA {//pending
            makeAvatarBoderBlack(avatarImageView: (cell.avatarImage))
            
        }
        if cell.eachData.pmode == Constants.PARTYMODE_OFF {//off
            makeAvatarBoderRed(avatarImageView: (cell.avatarImage))
            
        }
        if cell.eachData.pmode == Constants.PARTYMODE_ON {//on
            makeAvatarBoderGreen(avatarImageView: (cell.avatarImage))
            
        }
        cell.personName?.text = cell.eachData.name
        cell.avatarImage.image = cell.eachData.face_image
        cell.phonenumberLabel.text = cell.eachData.phonenumber
        
        switch self.tableView(tableView, titleForHeaderInSection: indexPath.section)! {
        case NSLocalizedString("partypeople", comment: ""):
            cell.changeToVisibleStatusIcon()
            
            let notification_status = DBManager.getInstance().getNotificationInfo(eachData.phonenumber)
            
            if notification_status == Constants.NOTIFICATION_FALSE{
                cell.changeTodisabledNotificationIcon()
            }
            else {
                cell.changeToEnabledNotificationIcon()
            }
            
            cell.showNotificationStatusButton()
//            cell.notificationStatusButton.tag = indexPath.row
//            cell.notificationStatusButton.addTarget(self, action:  #selector(self.notificationClicked(_:)),for: .touchUpInside)
            
        case NSLocalizedString("blocked", comment: ""):
            cell.changeToBlockStatusIcon()
            cell.hiddenNotificationStatusButton()
        
        default:
            break
        }
        
        return cell
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeAvatarBoderGreen(avatarImageView: UIImageView){
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.layer.borderColor = Constants.avartar_color_green.cgColor
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.layer.masksToBounds = true
    }
    func makeAvatarBoderBlack(avatarImageView: UIImageView){
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.layer.borderColor = Constants.avartar_color_black.cgColor
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.layer.masksToBounds = true
    }
    func makeAvatarBoderRed(avatarImageView: UIImageView){
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.layer.borderColor = Constants.avartar_color_red.cgColor
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.layer.masksToBounds = true
    }
    
//    
//    @objc func notificationClicked(_ sender:UIButton) {
//        print(sender.tag)
//        let indexPath = IndexPath(item: sender.tag, section: 0)
//        let cell = tbl_partypeople.dequeueReusableCell(withIdentifier: Constants.cellId_partypeopleeditTableView, for: indexPath as IndexPath) as! PartyPeopleEditTableViewCell
//        cell.changeTodisabledNotificationIcon()
////        let phonenumber = contactPhones(blocks[sender.tag]).replacingOccurrences(of: currentCountryCodeNum, with: "")
//    }
//    
    func setupRightItemButton(){
        self.navigationItem.rightBarButtonItem  = nil
        let button1 = UIBarButtonItem(image: UIImage(named: "ico-check"), style: .plain, target: self, action:#selector(self.navigationBarRightCheckButtonTapped))
        self.navigationItem.rightBarButtonItem  = button1
    }
    func navigationBarRightCheckButtonTapped(){
        _ = navigationController?.popViewController(animated: true)
    }
    internal func moveToBlockLists(item: PartyPeopleCellData, indexOfArray:Int) {
        self.sectionsArray[1].partypeoples.insert(item, at: 0)
        self.sectionsArray[0].partypeoples.remove(at: indexOfArray)
        self.tbl_partypeople.reloadData()

    }
    internal func moveToVisibleLists(item: PartyPeopleCellData, indexOfArray:Int) {
        self.sectionsArray[0].partypeoples.insert(item, at: 0)
        self.sectionsArray[1].partypeoples.remove(at: indexOfArray)
        self.tbl_partypeople.reloadData()
        
    }
}



