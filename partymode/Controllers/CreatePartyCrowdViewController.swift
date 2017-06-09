//
//  CreatePartyCrowdViewController.swift
//  partymode
//
//  Created by Nikita on 1/15/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class CreatePartyCrowdViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    @IBOutlet weak var tbl_CreatePartyCrowd: UITableView!
    @IBOutlet weak var emptyImage: UIImageView!
    
    var sectionsArray = [Sections]()
    var partypeopleArray = [PartyPeopleCellData]()
    var searchresult_partypeopleArray = [PartyPeopleCellData]()
    var temp_createdPartyCrowdItem: PartyCrowdCellData! = nil
    var shouldGoForward = false
    var shouldGoToEdit = false
    var shouldGoToChat = false
    var searchButton : UIBarButtonItem!
    var searchBar:UISearchBar!
    var shouldBeReactivate = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(CreatePartyCrowdViewController.methodOfSendDataToEditScreen(_:)), name:NSNotification.Name(rawValue: "notificationId_sendDataToMemberSelectAndEditScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfRefreshContacts(_:)), name:NSNotification.Name(rawValue: "notificationId_refreshContacts"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfSendChatFlagValueToEditScreen(_:)), name:NSNotification.Name(rawValue: "notificationId_sendgotochatFlagValueToEditScreen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfGotoHomeView(_:)), name:NSNotification.Name(rawValue: "notificationId_gotoPartyPeopleTab"), object: nil)
        
        let backButton = UIBarButtonItem(image: UIImage(named: "ico_back"), style: .plain, target: self, action: #selector(PartyCrowdEditViewController.back(sender:)))
        
        self.navigationItem.leftBarButtonItem = backButton
        
        if shouldGoToEdit == true {
            print("going to Go to Edit")
            let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "PartyCrowdEditViewController") as! PartyCrowdEditViewController
            viewController.createdPartyCrowdItem = self.temp_createdPartyCrowdItem
            viewController.shouldGoToEdit = true
            self.navigationController?.pushViewController(viewController, animated: false)
            shouldGoToEdit = false
        }
        if shouldGoForward == true{
            print("going to Go Forward")
            let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "PartyCrowdEditViewController") as! PartyCrowdEditViewController
            viewController.createdPartyCrowdItem = self.temp_createdPartyCrowdItem
            viewController.shouldGoForward = true
            self.navigationController?.pushViewController(viewController, animated: false)
            shouldGoForward = false
        }
        if shouldBeReactivate == true {
            print("going to Go to Edit")
            let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "PartyCrowdEditViewController") as! PartyCrowdEditViewController
            viewController.createdPartyCrowdItem = self.temp_createdPartyCrowdItem
            viewController.shouldBeReactivate = true
            self.navigationController?.pushViewController(viewController, animated: false)
            shouldBeReactivate = false
        }
        
    }
    func methodOfGotoHomeView(_ notification: Notification){
        //Take Action on Notification
        _ = navigationController?.popViewController(animated: true)
    }
    func methodOfRefreshContacts(_ notification: Notification){
        self.sectionsArray.removeAll()
        
        //GlobalData.sharedInstance.removeAllSelectedPartyCrowdMemberFromArray()
        self.partypeopleArray = GlobalData.sharedInstance.getPartyPeopleArray()
        let partypeoples = Sections(title: NSLocalizedString("partypeople", comment: ""), objects: self.partypeopleArray)
        self.sectionsArray.append(partypeoples)
        self.tbl_CreatePartyCrowd.reloadData()
        
        var pmodeON_count = 0
        for each in self.partypeopleArray {
            
            if each.pmode == Constants.PARTYMODE_ON {
                pmodeON_count = pmodeON_count + 1
            }
        }
        let partypOnPeopleCount_string = String(describing: pmodeON_count)
        UserDefaults.standard.set(partypOnPeopleCount_string, forKey: "partypeople_count")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_updatePartyPeopleCount"), object: nil)
    }
    func methodOfSendDataToEditScreen(_ notification: Notification){
        //Take Action on Notification
        GlobalData.sharedInstance.removeAllSelectedPartyCrowdMemberFromArray()
        self.temp_createdPartyCrowdItem = notification.object as! PartyCrowdCellData
        
        self.tbl_CreatePartyCrowd.reloadData()
    }
    func methodOfSendChatFlagValueToEditScreen(_ notification: Notification){
        //Take Action on Notification
        self.shouldGoToChat = true
    }
    func back(sender: UIBarButtonItem) {
        UserDefaults.standard.set("false", forKey: "shouldBeReactivate")
//        if shouldGoToChat == true {
//            checkButtonTapped()
//        }
//        else {
            _ = navigationController?.popViewController(animated: true)
//        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyImage.image = UIImage(named: NSLocalizedString("imagename_empty_partypeople", comment: ""))
        
        searchBar = UISearchBar(frame: CGRect(x:0, y:0, width:self.view.frame.width - 60, height:20))
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        
        self.title = NSLocalizedString("title_activity_create_crowd", comment: "")
        self.automaticallyAdjustsScrollViewInsets = false
        navigationController?.navigationBar.barTintColor = Constants.tab_color_partycrowds
        setupRightItemButtonWithSearch()
        // Do any additional setup after loading the view.
        GlobalData.sharedInstance.removeAllSelectedPartyCrowdMemberFromArray()
        self.partypeopleArray = GlobalData.sharedInstance.getPartyPeopleArray()
        let partypeoples = Sections(title: NSLocalizedString("partypeople", comment: ""), objects: self.partypeopleArray)
        self.sectionsArray.append(partypeoples)
    }
    
    func setupRightItemButtonWithSearch(){
        self.navigationItem.rightBarButtonItem  = nil
        let checkButton = UIBarButtonItem(image: UIImage(named: "ico-check"), style: .plain, target: self, action:#selector(self.checkButtonTapped))
        searchButton = UIBarButtonItem(image: UIImage(named: "ico-search"), style: .plain, target: self, action:#selector(self.searchButtonTapped))
        //self.navigationItem.rightBarButtonItem  = [searchButton,moreButton]
        self.navigationItem.setRightBarButtonItems([checkButton, searchButton], animated: true)
    }
    func checkButtonTapped(){
        self.cancelButtonTapped()
        let selectedPartyPeopleArray = GlobalData.sharedInstance.getSelectedPartyCrowdMembersArray()
        var newSelectedPhoneNumberArray = [String]()
        for each in selectedPartyPeopleArray {
            newSelectedPhoneNumberArray.append(each.phonenumber)
        }
        
        if self.temp_createdPartyCrowdItem != nil {
            for each in newSelectedPhoneNumberArray {
                self.temp_createdPartyCrowdItem.members.append(each)
            }
            
        }
        self.tbl_CreatePartyCrowd.reloadData()
       
        let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "PartyCrowdEditViewController") as! PartyCrowdEditViewController
        viewController.createdPartyCrowdItem = self.temp_createdPartyCrowdItem
        let shouldBeReactivate = UserDefaults.standard.string(forKey: "shouldBeReactivate")
        if shouldBeReactivate == "true" {
            viewController.shouldBeReactivate = true
             UserDefaults.standard.set("true", forKey: "shouldBeReactivate")
        }
        //viewController.sender = "selectMember"
        self.navigationController?.pushViewController(viewController, animated: true)
 
    }
    func searchButtonTapped(){
        let leftNavBarButton = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        self.title = ""
        searchBar.setShowsCancelButton(true, animated: true)
        
        self.navigationItem.rightBarButtonItem  = nil
        let checkButton = UIBarButtonItem(image: UIImage(named: "ico-check"), style: .plain, target: self, action:#selector(self.checkButtonTapped))
        
        self.navigationItem.setRightBarButtonItems([checkButton], animated: false)
        self.searchBar.becomeFirstResponder()
        
    }
    func cancelButtonTapped(){
        self.title = NSLocalizedString("title_activity_create_crowd", comment: "")
        self.navigationItem.leftBarButtonItem = nil
        self.setupRightItemButtonWithSearch()
        self.searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.reloadSearchedResult(searchText.lowercased())
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cancelButtonTapped()
    }
    func reloadSearchedResult(_ key:String){
        
        self.sectionsArray.removeAll()
        self.searchresult_partypeopleArray.removeAll()
        if key == ""{
            self.partypeopleArray = GlobalData.sharedInstance.getPartyPeopleArray()
            let partypeoples = Sections(title: NSLocalizedString("partypeople", comment: ""), objects: self.partypeopleArray)
            self.sectionsArray.append(partypeoples)
        }
        else {
            for each in self.partypeopleArray {
                if (each.name.lowercased().range(of: key) != nil) || (each.phonenumber.range(of: key) != nil) {
                    self.searchresult_partypeopleArray.append(each)
                }
            }
            let partypeoples = Sections(title: NSLocalizedString("partypeople", comment: ""), objects: self.searchresult_partypeopleArray)
            self.sectionsArray.append(partypeoples)
        }
        self.tbl_CreatePartyCrowd.reloadData()
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsArray[section].headings
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptyImage.isHidden = true
        return sectionsArray[section].partypeoples.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eachData: PartyPeopleCellData = sectionsArray[indexPath.section].partypeoples[indexPath.row]
        
        switch self.tableView(tableView, titleForHeaderInSection: indexPath.section)! {
         
        case NSLocalizedString("partypeople", comment: ""):
            let cell = tbl_CreatePartyCrowd.dequeueReusableCell(withIdentifier: Constants.cellId_creatPartyCrowTableView, for: indexPath as IndexPath) as! CreatePartyCrowdTableViewCell
            cell.eachData = eachData
            cell.selfIndex = indexPath.row
            
            cell.phonenumberLabel.text = eachData.phonenumber
            cell.avatarImage.image = eachData.face_image
            cell.personName?.text = eachData.name
            
            if eachData.pmode == Constants.PARTYMODE_NA {//pending
                makeAvatarBoderBlack(avatarImageView: (cell.avatarImage))
            }
            if eachData.pmode == Constants.PARTYMODE_OFF {//off
                makeAvatarBoderRed(avatarImageView: (cell.avatarImage))
            }
            if eachData.pmode == Constants.PARTYMODE_ON {//on
                makeAvatarBoderGreen(avatarImageView: (cell.avatarImage))
                
            }
            
            if self.temp_createdPartyCrowdItem != nil {
                for selectedMemberNr in self.temp_createdPartyCrowdItem.members {
                    if selectedMemberNr == eachData.phonenumber {
                        //cell.setSwitchOn()
                        cell.hiddenSwitch()
                    }
                }
            }
            return cell
            
        default:
            break
        }
        
        let cell = tbl_CreatePartyCrowd.dequeueReusableCell(withIdentifier: Constants.cellId_creatPartyCrowTableView, for: indexPath as IndexPath) as! CreatePartyCrowdTableViewCell
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
    
    
}
