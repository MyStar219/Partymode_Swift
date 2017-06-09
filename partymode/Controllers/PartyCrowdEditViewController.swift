//
//  PartyCrowdEditViewController.swift
//  partymode
//
//  Created by Nikita on 1/15/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit
import CRToast

class PartyCrowdEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tbl_invitedPartypeoples: UITableView!
    @IBOutlet weak var addPeopleButtonView: UIView!
    
    @IBOutlet weak var partytitleTextField: UITextField!
    @IBOutlet weak var partytimeTextfield: UITextField!
    @IBOutlet weak var partyLocationTextField: UITextField!
    
    @IBOutlet weak var friendCanaAddfriendsLabel: UILabel!
    @IBOutlet weak var canAddFriendSwitch: UISwitch!
    
    var sectionsArray = [Sections]()
    var partypeopleArray = [PartyPeopleCellData]()
    var datetimePicker : UIDatePicker!
    var party_timestamp: Int!
    
    let color = 0
    var phonenumberArray = [String]()
    var inviteFriend = false
    var createdPartyCrowdItem: PartyCrowdCellData! = nil
    var sender = ""
    var shouldGoForward = false
    var shouldGoToEdit = false
    var shouldGoToChat = false
    var shouldBeReactivate = false
    
    @IBOutlet weak var addButtonView: UIView!
    @IBOutlet weak var addTransparentButton: MKButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "ico_back"), style: .plain, target: self, action: #selector(PartyCrowdEditViewController.back(sender:)))
        
        self.navigationItem.leftBarButtonItem = backButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(PartyCrowdEditViewController.methodOfSendDataToEditScreen(_:)), name:NSNotification.Name(rawValue: "notificationId_sendDataToMemberSelectAndEditScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PartyCrowdEditViewController.methodOfSendChatFlagValueToEditScreen(_:)), name:NSNotification.Name(rawValue: "notificationId_sendgotochatFlagValueToEditScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PartyCrowdEditViewController.methodOfUpdateMembersArray(_:)), name:NSNotification.Name(rawValue: "notificationId_sendMembersArrayToEditScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfRefreshContacts(_:)), name:NSNotification.Name(rawValue: "notificationId_refreshContacts"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfGotoHomeView(_:)), name:NSNotification.Name(rawValue: "notificationId_gotoPartyPeopleTab"), object: nil)
        
        if shouldBeReactivate == true {
            
        }
        if shouldGoToEdit == true {
            
        }
        else if shouldGoForward == true {
                print("going to Go Forward")
                let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "PartyCrowdChatViewController") as! PartyCrowdChatViewController
                viewController.createdPartyCrowdItem = self.createdPartyCrowdItem
                GlobalData.sharedInstance.setSelectedPartyCrowdItem(self.createdPartyCrowdItem)
                //viewController.sender = "crowdeditView"
                self.navigationController?.pushViewController(viewController, animated: false)
                shouldGoForward = false
        }
    }
    func methodOfGotoHomeView(_ notification: Notification){
        //Take Action on Notification
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true);
    }
    
    func back(sender: UIBarButtonItem) {
        if shouldGoToEdit == true {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true);
            
            
        }
        else if shouldGoToChat == true {
            let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "PartyCrowdChatViewController") as! PartyCrowdChatViewController
            viewController.createdPartyCrowdItem = self.createdPartyCrowdItem
            GlobalData.sharedInstance.setSelectedPartyCrowdItem(self.createdPartyCrowdItem)
            self.navigationController?.pushViewController(viewController, animated: false)
        }
        else {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    func methodOfSendChatFlagValueToEditScreen(_ notification: Notification){
        //Take Action on Notification
        self.shouldGoToChat = true
        hiddenAddButton()
    }
    func methodOfSendDataToEditScreen(_ notification: Notification){
        //Take Action on Notification
        self.title = NSLocalizedString("editpartycrowd", comment: "")
        self.createdPartyCrowdItem = notification.object as! PartyCrowdCellData
    }
    func methodOfRefreshContacts(_ notification: Notification){
        
        updateProfileImages()
    }
    func updateProfileImages(){
        let partypeopleArray = GlobalData.sharedInstance.getPartyPeopleArray()
        
        for eachPartyPeople in partypeopleArray {
            var i = 0
            for eachCrowdMembers in self.partypeopleArray {
                if eachPartyPeople.phonenumber == eachCrowdMembers.phonenumber {
                    self.partypeopleArray[0].face_image = eachPartyPeople.face_image
                    self.partypeopleArray[0].pmode = eachPartyPeople.pmode
                    sectionsArray[0].partypeoples[i].face_image = eachPartyPeople.face_image
                    sectionsArray[0].partypeoples[i].pmode = eachPartyPeople.pmode
                    
                    break
                }
                i = i + 1
            }
            
        }
        self.tbl_invitedPartypeoples.reloadData()
    }
    func methodOfUpdateMembersArray(_ notification: Notification){
        //Take Action on Notification
        self.sectionsArray.removeAll()
        self.partypeopleArray.removeAll()
        //self.partypeopleArray = GlobalData.sharedInstance.getPartyPeopleArrayWith(crowdMembersPhoneArray: self.createdPartyCrowdItem.members)
        
        let newMembersArray = notification.object as! [String]
        
        let newPartypeopleArray = GlobalData.sharedInstance.getPartyPeopleArrayWith(crowdMembersPhoneArray: newMembersArray)
        
        for each in newPartypeopleArray {
            self.partypeopleArray.append(each)
        }
        
        
        let partypeoples = Sections(title: NSLocalizedString("invitedpartypeople", comment: ""), objects: self.partypeopleArray)
        self.sectionsArray.append(partypeoples)
        tbl_invitedPartypeoples.reloadData()
        updateProfileImages()
        
//        self.partypeopleArray = GlobalData.sharedInstance.getSelectedPartyCrowdMembersArray()
//        let partypeoples = Sections(title: NSLocalizedString("invitedpartypeople", comment: ""), objects: self.partypeopleArray)
//        self.sectionsArray.append(partypeoples)
//        tbl_invitedPartypeoples.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //partyLocationTextField.text = "test"
        setupRightItemButton()
        setSwitchStyle()
        //self.title = NSLocalizedString("editpartycrowd", comment: "")
        partytitleTextField.placeholder = NSLocalizedString("partytitle", comment: "")
        partytimeTextfield.placeholder = NSLocalizedString("selectdate", comment: "")
        partyLocationTextField.placeholder = NSLocalizedString("location", comment: "")
        friendCanaAddfriendsLabel.text = NSLocalizedString("friendsaddfriends", comment: "")
        
        
        self.automaticallyAdjustsScrollViewInsets = false
        makeAddCrowdButtonCircleShadow()
        // Do any additional setup after loading the view.
        
        if self.createdPartyCrowdItem == nil {
            self.title = NSLocalizedString("title_activity_create_crowd", comment: "")
            self.partypeopleArray = GlobalData.sharedInstance.getSelectedPartyCrowdMembersArray()
            let partypeoples = Sections(title: NSLocalizedString("invitedpartypeople", comment: ""), objects: self.partypeopleArray)
            self.sectionsArray.append(partypeoples)
            
            partytitleTextField.text = GlobalData.sharedInstance.getRandomPartyTitle()
            //partyLocationTextField.text = GlobalData.sharedInstance.getRandomLocationTitle()
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "dd.MM.yyyy 20:00"//"yyyy/MM/dd 20:00"
            partytimeTextfield.text = dateFormatter1.string(for: Date())
            
            let dateFormatterForDefaultTimeStamp = DateFormatter()
            dateFormatterForDefaultTimeStamp.dateFormat = "dd.MM.yyyy 20:00:00 Z"//"yyyy-MM-dd 20:00:00 Z"
            let strTime = dateFormatterForDefaultTimeStamp.string(for: Date())
            
            //let strTime = "2017-02-11 20:00:00 +0000"
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm:ss Z"//"yyyy-MM-dd HH:mm:ss Z"
            let date = formatter.date(from: strTime!)
            party_timestamp = Int(TimeStampClass().convertToTimestamp(date:date!))
            self.pickUpDate(self.partytimeTextfield)
            
        }
        else {
            if self.shouldBeReactivate == true {
                self.title = NSLocalizedString("title_activity_create_crowd", comment: "")
                partytitleTextField.text = self.createdPartyCrowdItem.title
                partyLocationTextField.text = self.createdPartyCrowdItem.location
                //            partytimeTextfield.text = self.createdPartyCrowdItem.partyTime
                //            party_timestamp = self.createdPartyCrowdItem.partyTimeStamp
                /************* modifying as current date *************/
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateFormat = "dd.MM.yyyy 20:00"//"yyyy/MM/dd 20:00"
                partytimeTextfield.text = dateFormatter1.string(for: Date())
                
                let dateFormatterForDefaultTimeStamp = DateFormatter()
                dateFormatterForDefaultTimeStamp.dateFormat = "dd.MM.yyyy 20:00:00 Z"//"yyyy-MM-dd 20:00:00 Z"
                let strTime = dateFormatterForDefaultTimeStamp.string(for: Date())
                
                //let strTime = "2017-02-11 20:00:00 +0000"
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy HH:mm:ss Z"//"yyyy-MM-dd HH:mm:ss Z"
                let date = formatter.date(from: strTime!)
                party_timestamp = Int(TimeStampClass().convertToTimestamp(date:date!))
                self.pickUpDate(self.partytimeTextfield)
                /*****************************************************/
                
                canAddFriendSwitch.setOn(self.createdPartyCrowdItem.invite_friends, animated: false)
                self.inviteFriend = self.createdPartyCrowdItem.invite_friends
                
                self.partypeopleArray = GlobalData.sharedInstance.getPartyPeopleArrayWith(crowdMembersPhoneArray: self.createdPartyCrowdItem.members)
                
                let myPhoneNr = UserDefaults.standard.string(forKey: "phone_nr")
                var i = 0
                for each in self.partypeopleArray {
                    if each.phonenumber == myPhoneNr {
                        self.partypeopleArray.remove(at: i)
                        break
                    }
                    i = i + 1
                }
                
                
                let partypeoples = Sections(title: NSLocalizedString("invitedpartypeople", comment: ""), objects: self.partypeopleArray)
                self.sectionsArray.append(partypeoples)
            }
            else {
                self.title = NSLocalizedString("editpartycrowd", comment: "")
                partytitleTextField.text = self.createdPartyCrowdItem.title
                partyLocationTextField.text = self.createdPartyCrowdItem.location
                partytimeTextfield.text = self.createdPartyCrowdItem.partyTime
                party_timestamp = self.createdPartyCrowdItem.partyTimeStamp
//                /************* modifying as current date *************/
//                let dateFormatter1 = DateFormatter()
//                dateFormatter1.dateFormat = "dd.MM.yyyy 20:00"//"yyyy/MM/dd 20:00"
//                partytimeTextfield.text = dateFormatter1.string(for: Date())
//                
//                let dateFormatterForDefaultTimeStamp = DateFormatter()
//                dateFormatterForDefaultTimeStamp.dateFormat = "dd.MM.yyyy 20:00:00 Z"//"yyyy-MM-dd 20:00:00 Z"
//                let strTime = dateFormatterForDefaultTimeStamp.string(for: Date())
//                
//                //let strTime = "2017-02-11 20:00:00 +0000"
//                let formatter = DateFormatter()
//                formatter.dateFormat = "dd.MM.yyyy HH:mm:ss Z"//"yyyy-MM-dd HH:mm:ss Z"
//                let date = formatter.date(from: strTime!)
//                party_timestamp = Int(TimeStampClass().convertToTimestamp(date:date!))
//                self.pickUpDate(self.partytimeTextfield)
//                /*****************************************************/
                
                canAddFriendSwitch.setOn(self.createdPartyCrowdItem.invite_friends, animated: false)
                self.inviteFriend = self.createdPartyCrowdItem.invite_friends
                
                self.partypeopleArray = GlobalData.sharedInstance.getPartyPeopleArrayWith(crowdMembersPhoneArray: self.createdPartyCrowdItem.members)
                
                let myPhoneNr = UserDefaults.standard.string(forKey: "phone_nr")
                var i = 0
                for each in self.partypeopleArray {
                    if each.phonenumber == myPhoneNr {
                        self.partypeopleArray.remove(at: i)
                        break
                    }
                    i = i + 1
                }
                
                
                let partypeoples = Sections(title: NSLocalizedString("invitedpartypeople", comment: ""), objects: self.partypeopleArray)
                self.sectionsArray.append(partypeoples)
            }
            
        }
        updateProfileImages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupRightItemButton(){
        self.navigationItem.rightBarButtonItem  = nil
        let button1 = UIBarButtonItem(image: UIImage(named: "ico-check"), style: .plain, target: self, action:#selector(self.checkButtonTapped))
        self.navigationItem.rightBarButtonItem  = button1
    }
    func navigationBarRightCheckButtonTapped(){
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func addPeopleCircleButtonPressed(_ sender: Any) {
//        if self.sender == ""{
            navigationBarRightCheckButtonTapped()
//        }
//        else {
//            let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "CreatePartyCrowdViewController") as! CreatePartyCrowdViewController
//            viewController.temp_createdPartyCrowdItem = self.createdPartyCrowdItem
//            self.navigationController?.pushViewController(viewController, animated: true)
//        }
        
    }
    @IBAction func transparentAddPeopleButton(_ sender: Any) {
        if self.shouldGoToChat == true {
//            let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "AddMembersViewController") as! AddMembersViewController
//            viewController.temp_createdPartyCrowdItem = self.createdPartyCrowdItem
//            GlobalData.sharedInstance.setSelectedPartyCrowdItem(self.createdPartyCrowdItem)
//            self.navigationController?.pushViewController(viewController, animated: true)
            let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "AddFriendViewController") as! AddFriendViewController
            viewController.temp_createdPartyCrowdItem = self.createdPartyCrowdItem
            GlobalData.sharedInstance.setSelectedPartyCrowdItem(self.createdPartyCrowdItem)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else {
            let shouldBeReactivate = UserDefaults.standard.string(forKey: "shouldBeReactivate")
            if shouldBeReactivate == "true" {
                GlobalData.sharedInstance.removeAllSelectedPartyCrowdMemberFromArray()
            }
            else {
                
            }
            
            navigationBarRightCheckButtonTapped()
        }
    }
    func checkButtonTapped(){
        let shouldBeReactivate = UserDefaults.standard.string(forKey: "shouldBeReactivate")
        
        self.phonenumberArray.removeAll()
        if checkIfNotEmprty() {
            UserDefaults.standard.set("NO", forKey: "isFromPartyHistory")
            for each in self.partypeopleArray {
                self.phonenumberArray.append(each.phonenumber)
            }
            UserDefaults.standard.set("false", forKey: "shouldBeReactivate")
            if self.createdPartyCrowdItem != nil{
                
                if shouldBeReactivate == "true" {
                    CreatEditCrowdAPICall().request(self, title: partytitleTextField.text!, location: partyLocationTextField.text!, partyTimeStamp: self.party_timestamp, partyTime:partytimeTextfield.text!, invite_friends: inviteFriend, color: color, members: phonenumberArray, completionHandler: {(post) -> Void in
                        let state = post.object(forKey: "state") as! String
                        if state == "success" {
                            let id = post.object(forKey: "id") as! String
                            print("New party created successfully")
                            let myPhoneNr = UserDefaults.standard.string(forKey: "phone_nr")
                            self.createdPartyCrowdItem = PartyCrowdCellData(id:id, title: self.partytitleTextField.text!, location: self.partyLocationTextField.text!, partyTimeStamp: self.party_timestamp, partyTime: self.partytimeTextfield.text!, invite_friends: self.inviteFriend, color: self.color, members: self.phonenumberArray, status:Constants.CROWD_STATUS_DO_NO_CHANGE_STATUS)
                            
                            let isInserted = DBManager.getInstance().addCrowdData(self.createdPartyCrowdItem)
                            
                            //let isInserted = DBManager.getInstance().addCrowdData(self.createdPartyCrowdItem, owner_phoneNr: myPhoneNr!, crowd_status: Constants.CROWD_STATUS_DO_NO_CHANGE_STATUS)
                            if isInserted {
                                let myPhoneNr = UserDefaults.standard.string(forKey: "phone_nr")
                                _ = DBManager.getInstance().addCrowdMembers([myPhoneNr!], crowdId: id, status:Constants.CROWD_STATUS_ACCEPTED)
                                
                                _ = DBManager.getInstance().addCrowdMembers(self.phonenumberArray, crowdId: id)
                                //DBUtil.invokeAlertMethod("", strBody: "Record Inserted successfully.", delegate: nil)
                                
                                
                            } else {
                                //DBUtil.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
                            }
                            //GlobalData.sharedInstance.addToCreatedPartyCrowdsArray(self.createdPartyCrowdItem)
                            
                            let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "PartyCrowdChatViewController") as! PartyCrowdChatViewController
                            viewController.createdPartyCrowdItem = self.createdPartyCrowdItem
                            GlobalData.sharedInstance.setSelectedPartyCrowdItem(self.createdPartyCrowdItem)
                            //viewController.sender = "crowdeditView"
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_reloadTab3Screen"), object: nil)
                            
                            self.navigationController?.pushViewController(viewController, animated: true)
                            
                            
                        }
                        
                    })
                }
                else {
                    CreatEditCrowdAPICall().request(id: self.createdPartyCrowdItem.id, title: partytitleTextField.text!, location: partyLocationTextField.text!, partyTimeStamp: self.party_timestamp, partyTime:partytimeTextfield.text!, invite_friends: inviteFriend, color: color, members: phonenumberArray, completionHandler: {(post) -> Void in
                        let state = post.object(forKey: "state") as! String
                        if state == "success" {
                            if post.object(forKey: "id") as? String != nil {
                                let id = post.object(forKey: "id") as! String
                                print("Original party updated successfully")
                                
                                self.createdPartyCrowdItem = PartyCrowdCellData(id:id, title: self.partytitleTextField.text!, location: self.partyLocationTextField.text!, partyTimeStamp: self.party_timestamp, partyTime: self.partytimeTextfield.text!, invite_friends: self.inviteFriend, color: self.color, members: self.phonenumberArray, status:Constants.CROWD_STATUS_DO_NO_CHANGE_STATUS)
                                let isUpdated = DBManager.getInstance().updateCrowdData(self.createdPartyCrowdItem)
                                if isUpdated {
                                    _ = DBManager.getInstance().DeleteCrowdMembers(id)
                                    let myPhoneNr = UserDefaults.standard.string(forKey: "phone_nr")
                                    _ = DBManager.getInstance().addCrowdMembers([myPhoneNr!], crowdId: id, status:Constants.CROWD_STATUS_ACCEPTED)
                                    
                                    _ = DBManager.getInstance().addCrowdMembers(self.phonenumberArray, crowdId: id)
                                    
                                    //DBUtil.invokeAlertMethod("", strBody: "Record Updated successfully.", delegate: nil)
                                    
                                    
                                } else {
                                    //DBUtil.invokeAlertMethod("", strBody: "Error in updating record.", delegate: nil)
                                }
                                //GlobalData.sharedInstance.addToCreatedPartyCrowdsArray(self.createdPartyCrowdItem)
                                
                                let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "PartyCrowdChatViewController") as! PartyCrowdChatViewController
                                viewController.createdPartyCrowdItem = self.createdPartyCrowdItem
                                
                                if var castedEach = self.createdPartyCrowdItem as? PartyCrowdCellData {
                                    castedEach.setPastPartyValue(false)
                                    GlobalData.sharedInstance.setSelectedPartyCrowdItem(self.createdPartyCrowdItem)
                                }
                                
                                
                                viewController.sender = "crowdeditView"
                                self.navigationController?.pushViewController(viewController, animated: true)
                            }
                            else {
                                self.showToast("Please update your party time.")
                            }
                        }
                        
                    })
                }
                
            }
            else {
                CreatEditCrowdAPICall().request(self, title: partytitleTextField.text!, location: partyLocationTextField.text!, partyTimeStamp: self.party_timestamp, partyTime:partytimeTextfield.text!, invite_friends: inviteFriend, color: color, members: phonenumberArray, completionHandler: {(post) -> Void in
                    let state = post.object(forKey: "state") as! String
                    if state == "success" {
                        let id = post.object(forKey: "id") as! String
                        print("New party created successfully")
                        let myPhoneNr = UserDefaults.standard.string(forKey: "phone_nr")
                        self.createdPartyCrowdItem = PartyCrowdCellData(id:id, title: self.partytitleTextField.text!, location: self.partyLocationTextField.text!, partyTimeStamp: self.party_timestamp, partyTime: self.partytimeTextfield.text!, invite_friends: self.inviteFriend, color: self.color, members: self.phonenumberArray, status:Constants.CROWD_STATUS_DO_NO_CHANGE_STATUS)
                        
                        let isInserted = DBManager.getInstance().addCrowdData(self.createdPartyCrowdItem)
                        
                        //let isInserted = DBManager.getInstance().addCrowdData(self.createdPartyCrowdItem, owner_phoneNr: myPhoneNr!, crowd_status: Constants.CROWD_STATUS_DO_NO_CHANGE_STATUS)
                        if isInserted {
                            let myPhoneNr = UserDefaults.standard.string(forKey: "phone_nr")
                            _ = DBManager.getInstance().addCrowdMembers([myPhoneNr!], crowdId: id, status:Constants.CROWD_STATUS_ACCEPTED)
                            
                            _ = DBManager.getInstance().addCrowdMembers(self.phonenumberArray, crowdId: id)
                            //DBUtil.invokeAlertMethod("", strBody: "Record Inserted successfully.", delegate: nil)
                            
                            
                        } else {
                            //DBUtil.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
                        }
                        //GlobalData.sharedInstance.addToCreatedPartyCrowdsArray(self.createdPartyCrowdItem)
                        
                        let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "PartyCrowdChatViewController") as! PartyCrowdChatViewController
                        viewController.createdPartyCrowdItem = self.createdPartyCrowdItem
                        GlobalData.sharedInstance.setSelectedPartyCrowdItem(self.createdPartyCrowdItem)
                        //viewController.sender = "crowdeditView"
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_reloadTab3Screen"), object: nil)
                        
                        self.navigationController?.pushViewController(viewController, animated: true)
                        
                        
                    }
                    
                })
            }
            
            
            
        }
        else {
            
        }
        
    }
    
    func makeAddCrowdButtonCircleShadow(){
        addPeopleButtonView.layer.cornerRadius = addPeopleButtonView.bounds.width / 2
        addPeopleButtonView.layer.shadowColor = UIColor.gray.cgColor
        addPeopleButtonView.layer.shadowOpacity = 1
        addPeopleButtonView.layer.shadowOffset = CGSize(width: 2, height: 2)
        addPeopleButtonView.layer.borderWidth = 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsArray[section].headings
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsArray[section].partypeoples.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eachData: PartyPeopleCellData = sectionsArray[indexPath.section].partypeoples[indexPath.row]
        
        switch self.tableView(tableView, titleForHeaderInSection: indexPath.section)! {
            
        case NSLocalizedString("invitedpartypeople", comment: ""):
            let cell = tbl_invitedPartypeoples.dequeueReusableCell(withIdentifier: Constants.cellId_creatPartyCrowTableView, for: indexPath as IndexPath) as! CreatePartyCrowdTableViewCell
            cell.eachData = eachData
            cell.selfIndex = indexPath.row
            
            cell.phonenumberLabel.text = eachData.phonenumber
            cell.avatarImage.image = eachData.face_image
            cell.personName?.text = eachData.name
            
            cell.crowdswitch.setOn(true, animated: false)
            cell.crowdswitch.isUserInteractionEnabled = false
            
            if eachData.pmode == Constants.PARTYMODE_NA {//pending
                makeAvatarBoderBlack(avatarImageView: (cell.avatarImage))
            }
            if eachData.pmode == Constants.PARTYMODE_OFF {//off
                makeAvatarBoderRed(avatarImageView: (cell.avatarImage))
            }
            if eachData.pmode == Constants.PARTYMODE_ON {//on
                makeAvatarBoderGreen(avatarImageView: (cell.avatarImage))
            }
            return cell
            
        default:
            break
        }
        
        let cell = tbl_invitedPartypeoples.dequeueReusableCell(withIdentifier: Constants.cellId_creatPartyCrowTableView, for: indexPath as IndexPath) as! CreatePartyCrowdTableViewCell
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
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
    func setSwitchStyle(){
        canAddFriendSwitch.layer.cornerRadius = 17
        canAddFriendSwitch.tintColor = UIColor.clear
        canAddFriendSwitch.backgroundColor = Constants.color_switch_off
        canAddFriendSwitch.transform = CGAffineTransform(scaleX: 0.9, y: 0.9);//CGAffineTransform(scaleX: 0.7, y: 0.7);
        canAddFriendSwitch.setOn(false, animated: false)
    }
    
    func pickUpDate(_ textField : UITextField){
        
        // DatePicker
        self.datetimePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datetimePicker.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        self.datetimePicker.datePickerMode = UIDatePickerMode.dateAndTime
        textField.inputView = self.datetimePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = Constants.tab_color_partyprofile
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: NSLocalizedString("done", comment: ""), style: .plain, target: self, action: #selector(self.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("cancel", comment: ""), style: .plain, target: self, action: #selector(self.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
        let dateString = textField.text//"2017/2/11 20:00"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"//"yyyy/MM/dd HH:mm"
        let date = dateFormatter.date(from: dateString!)
        
        self.datetimePicker.minimumDate = Date()
        if date != nil {
            datetimePicker.setDate(date!, animated: true)
        }
        
        
    }
    // MARK:- Button Done and Cancel
    func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "dd.MM.yyyy HH:mm"//"yyyy/MM/dd HH:mm"
        partytimeTextfield.text = dateFormatter1.string(from: datetimePicker.date)
        partytimeTextfield.resignFirstResponder()
        
        party_timestamp = Int(TimeStampClass().convertToTimestamp(date: datetimePicker.date))!
    }
    func cancelClick() {
        partytimeTextfield.resignFirstResponder()
    }
    func checkIfNotEmprty() -> Bool{
        if partyLocationTextField.text == "" {
            partyLocationTextField.text = NSLocalizedString("emptylocation", comment: "")
        }
        if partytitleTextField.text == ""{
            showToast(NSLocalizedString("emptytitle", comment: ""))
            return false
        }
        else if self.party_timestamp <  Int(NSDate().timeIntervalSince1970) {
            showToast(NSLocalizedString("timeinpast", comment: ""))
            return false
        }
        else {
            return true
        }
        
    }
    
    func showToast(_ string:String){
        let options:[NSObject:AnyObject]  = [
            kCRToastNotificationPresentationTypeKey as NSObject : 1 as AnyObject,
            kCRToastTextKey as NSObject : string as AnyObject,
            kCRToastBackgroundColorKey as NSObject : UIColor.orange,
            kCRToastTextColorKey as NSObject: UIColor.white,
            kCRToastFontKey as NSObject: UIFont(name:"HelveticaNeue-Bold", size: 15)!,
            kCRToastTextMaxNumberOfLinesKey as NSObject: 2 as AnyObject,
            kCRToastTimeIntervalKey as NSObject: 3 as AnyObject,
            kCRToastUnderStatusBarKey as NSObject : NSNumber(value: true),
            kCRToastImageAlignmentKey as NSObject : NSNumber(value: NSTextAlignment.left.rawValue) as AnyObject,
            kCRToastTextAlignmentKey as NSObject : NSNumber(value: NSTextAlignment.left.rawValue) as AnyObject,
            kCRToastImageKey as NSObject : UIImage(named: "alert_icon")!,
            kCRToastNotificationTypeKey as NSObject : NSNumber(value: CRToastType.navigationBar.rawValue) as AnyObject,
            kCRToastAnimationInTypeKey as NSObject : NSNumber(value: CRToastAnimationType.spring.rawValue) as AnyObject,
            kCRToastAnimationOutTypeKey as NSObject : NSNumber(value: CRToastAnimationType.spring.rawValue) as AnyObject,
            kCRToastAnimationInDirectionKey as NSObject : NSNumber(value:CRToastAnimationDirection.top.rawValue) as AnyObject,
            kCRToastAnimationOutDirectionKey as NSObject : CRToastAnimationDirection.top.rawValue as AnyObject,
            //kCRToastNotificationPreferredPaddingKey as NSObject : NSNumber(value: Int(self.view.bounds.width/12)) as AnyObject
        ]
        
        CRToastManager.showNotification(options: options, completionBlock: { () -> Void in
            print("done!")
        })
    }
    @IBAction func addFriendSwitchEvent(_ sender: UISwitch) {
        if sender.isOn {
            self.inviteFriend = true
            
        }
        else {
            self.inviteFriend = false
        }
    }
    
    func hiddenAddButton(){
        self.addButtonView.isHidden = true
        self.addTransparentButton.isHidden = true
    }
//    override func willMove(toParentViewController parent: UIViewController?) {
//        super.willMove(toParentViewController: parent)
//        if parent == nil {
//            print("pressed back button")
//            if shouldGoToEdit == true {
//                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
//                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true);
//            
//            
//            }
//            
//        }
//    }
}
