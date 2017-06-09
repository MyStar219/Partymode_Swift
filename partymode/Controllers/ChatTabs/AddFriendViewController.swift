//
//  AddFriendViewController.swift
//  partymode
//
//  Created by Nikita on 3/25/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class AddFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var tbl_CreatePartyCrowd: UITableView!
    @IBOutlet weak var emptyImage: UIImageView!
    
    var sectionsArray = [Sections]()
    var partypeopleArray = [PartyPeopleCellData]()
    var searchresult_partypeopleArray = [PartyPeopleCellData]()
    var temp_createdPartyCrowdItem: PartyCrowdCellData! = nil
    var shouldGoForward = false
    var shouldGoToEdit = false
    var sender = ""
    
    var searchButton : UIBarButtonItem!
    var searchBar:UISearchBar!
    
    var addedNewFriendsArray = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(CreatePartyCrowdViewController.methodOfSendDataToEditScreen(_:)), name:NSNotification.Name(rawValue: "notificationId_sendDataToMemberSelectAndEditScreen"), object: nil)
        self.title = NSLocalizedString("editpartycrowd", comment: "")
        
    }
    func methodOfSendDataToEditScreen(_ notification: Notification){
        //Take Action on Notification
        GlobalData.sharedInstance.removeAllSelectedPartyCrowdMemberFromArray()
        self.temp_createdPartyCrowdItem = notification.object as! PartyCrowdCellData
        
        self.tbl_CreatePartyCrowd.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyImage.image = UIImage(named: NSLocalizedString("imagename_empty_partypeople", comment: ""))
        
        searchBar = UISearchBar(frame: CGRect(x:0, y:0, width:self.view.frame.width - 60, height:20))
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        
        self.title = NSLocalizedString("title_activity_create_crowd", comment: "")
        self.automaticallyAdjustsScrollViewInsets = false
        //navigationController?.navigationBar.barTintColor = Constants.tab_color_partycrowds
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
        var phonenumberArray = [String]()
        for each in selectedPartyPeopleArray {
            phonenumberArray.append(each.phonenumber)
        }
        for new_each_member in phonenumberArray {//from new array
            var isExist = false
            for original_each_member in self.temp_createdPartyCrowdItem.members {//from original array
                if original_each_member == new_each_member {
                    isExist = true
                    break
                }
            }
            if isExist == false {
                
                print("\(new_each_member) is new added contact, so inserting to DB now...")
                self.addedNewFriendsArray.append(new_each_member)
                //let isInserted = DBManager.getInstance().addContactData(original_each_member)
            }
        }
        
            AddFriendsToCrowdAPICall().request(id: self.temp_createdPartyCrowdItem.id, title: self.temp_createdPartyCrowdItem.title, location: self.temp_createdPartyCrowdItem.location, partyTimeStamp: self.temp_createdPartyCrowdItem.partyTimeStamp, partyTime:self.temp_createdPartyCrowdItem.partyTime, invite_friends: self.temp_createdPartyCrowdItem.invite_friends, color: self.temp_createdPartyCrowdItem.color, members: self.addedNewFriendsArray, completionHandler: {(post) -> Void in
                let state = post.object(forKey: "state") as! String
                if state == "success" {
                    
                    print("Original party updated successfully")
                    _ = DBManager.getInstance().addCrowdMembers(self.addedNewFriendsArray, crowdId: self.temp_createdPartyCrowdItem.id, status:Constants.CROWD_STATUS_PENDING)
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_reloadMembersData"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_sendMembersArrayToEditScreen"), object: phonenumberArray)
                    _ = self.navigationController?.popViewController(animated: true)
                    
                }
                
            })
       
        
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
                        cell.setSwitchOn()
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
