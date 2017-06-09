//
//  Tab2PartypeopleViewController.swift
//  partymode
//
//  Created by Nikita on 1/12/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit
import MessageUI
import CRToast
class Tab2PartypeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate{
    
    @IBOutlet weak var tbl_partypeople: UITableView!
    @IBOutlet weak var addButtonView: UIView!
    @IBOutlet weak var partyEmptyImage: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    var sectionsArray = [Sections]()
    var partypeopleArray = [PartyPeopleCellData]()
    var contactsArray = [PartyPeopleCellData]()
    
    var searchresult_partypeopleArray = [PartyPeopleCellData]()
    var searchresult_contactsArray = [PartyPeopleCellData]()
    
    var timer = Timer()
    
    var searchController: UISearchController!
    var pmodeMembersCountOfDB = 0
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
   // var receivedSetPmode = false
    
    let loader = HUDLoader()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tbl_partypeople.dataSource = self
        self.tbl_partypeople.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotificationOfArrayUpdate(_:)), name:NSNotification.Name(rawValue: "notificationId_updatePartyPeopleOriginalArray"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfRefreshContacts(_:)), name:NSNotification.Name(rawValue: "notificationId_refreshContacts"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfSearchKeyUpdated(_:)), name:NSNotification.Name(rawValue: "notificationId_updateSearchKey"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfRefreshNow(_:)), name:NSNotification.Name(rawValue: "notificationId_refreshNow"), object: nil)
        
        
    }
    
    func methodOfRefreshNow(_ notification: Notification){
        //Take Action on Notification
        
        checkPmodeStatusIfPastValidTime()
        
    }
    func methodOfSearchKeyUpdated(_ notification: Notification){
        //Take Action on Notification
        
        let typedSearchKey =  notification.object as! String
        if typedSearchKey != ""{
            self.refreshWithSearchKey(key: typedSearchKey)
        }
        else {
            self.loadInitialData()
        }
    }
    func refreshWithSearchKey(key:String) {
        self.sectionsArray.removeAll()
        self.searchresult_partypeopleArray.removeAll()
        self.searchresult_contactsArray.removeAll()
        for each in self.partypeopleArray {
            if (each.name.lowercased().range(of: key) != nil) || (each.phonenumber.range(of: key) != nil) {
                self.searchresult_partypeopleArray.append(each)
            }
        }
        if self.searchresult_partypeopleArray.count > 0 {
            let partypeoples = Sections(title: NSLocalizedString("partypeople", comment: ""), objects: self.searchresult_partypeopleArray)
            self.sectionsArray.append(partypeoples)
            editButton.isHidden = false
        }
        else {
            editButton.isHidden = true
        }
        
        
        for each in self.contactsArray {
            if (each.name.lowercased().range(of: key) != nil) || (each.phonenumber.range(of: key) != nil) {
                self.searchresult_contactsArray.append(each)
            }
        }
        if self.searchresult_contactsArray.count > 0 {
            let contacts = Sections(title: NSLocalizedString("contacts_title", comment: ""), objects: self.searchresult_contactsArray)
            self.sectionsArray.append(contacts)
        }
        self.tbl_partypeople.reloadData()
    }

    func methodOfReceivedNotificationOfArrayUpdate(_ notification: Notification){
        //Take Action on Notification
        let arrayItemToUpdate =  notification.object as! PartyPeopleCellData
        var index = 0
        for each in self.sectionsArray[0].partypeoples {
            if arrayItemToUpdate.phonenumber == each.phonenumber {
                sectionsArray[0].partypeoples[index] = arrayItemToUpdate
            }
            index = index + 1
        }
        GlobalData.sharedInstance.setPartyPeopleArray(newArray: sectionsArray[0].partypeoples)
        
    }
    func methodOfRefreshContacts(_ notification: Notification){
        hideActivityIndicator()
        if GlobalData.sharedInstance.getContactsArray().count > 0 {
            self.sectionsArray.removeAll()
            //self.receivedSetPmode = false
            
            self.partypeopleArray = GlobalData.sharedInstance.getPartyPeopleArray()
            if self.partypeopleArray.count > 0 {
                let partypeoples = Sections(title: NSLocalizedString("partypeople", comment: ""), objects: self.partypeopleArray)
                self.sectionsArray.append(partypeoples)
            }
            
            self.contactsArray = GlobalData.sharedInstance.getUnduplicatedContactsArray()
            let contacts = Sections(title: NSLocalizedString("contacts_title", comment: ""), objects: self.contactsArray)
            self.sectionsArray.append(contacts)
            
            if pmodeMembersCountOfDB > 0 {//update dat if data is exist.
                for each in self.partypeopleArray {
                    _ = DBManager.getInstance().updatePmodeMemberData(each)
                }
            }
            else {//add data if data is not exist
                pmodeMembersCountOfDB = self.partypeopleArray.count
                for each in self.partypeopleArray {
                    _ = DBManager.getInstance().addPmodeMemberData(each)
                    _ = DBManager.getInstance().addPmodeCacheData(each.phonenumber, pmode_time: each.pmode_time!, pmode: each.pmode)
                }
            }
            
            self.tbl_partypeople.reloadData()
            
            var pmodeON_count = 0
            for each in self.partypeopleArray {
                
                if each.pmode == Constants.PARTYMODE_ON {
                    pmodeON_count = pmodeON_count + 1
                }
            }
            let partypOnPeopleCount_string = String(describing: pmodeON_count)
            UserDefaults.standard.set(partypOnPeopleCount_string, forKey: "partypeople_count")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_updatePartyPeopleCount"), object: nil)
            
            //loader.showSuccess()
            let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                // Your code with delay
                self.scheduledTimerWithTimeInterval()
            }
        }
        else {
            self.tbl_partypeople.isHidden = true
            partyEmptyImage.isHidden = false
        }
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //timer.invalidate()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tbl_partypeople.delegate = self;
        self.loadingIndicator.isHidden = true
        self.loadInitialContactsAndPmodeUsersOfDB()
        
        
        //self.loadInitialData()//
        
        makeAddCrowdButtonCircleShadow()
        
        partyEmptyImage.image = UIImage(named: NSLocalizedString("imagename_empty_partypeople", comment: ""))
        
        editButton.setTitle(NSLocalizedString("edit", comment: ""), for: UIControlState())
        //addEditButton()
        
//        let when = DispatchTime.now() + 10 // change 2 to desired number of seconds
//        DispatchQueue.main.asyncAfter(deadline: when) {
//            // Your code with delay
//            self.scheduledTimerWithTimeInterval()
//        }
        
    }
    func loadInitialContactsAndPmodeUsersOfDB(){
        
        DispatchQueue.main.async(execute: {
            if self.partypeopleArray.count == 0 {
                self.showAcitivityIndicator()
            }
        })
        
        self.sectionsArray.removeAll()
        self.contactsArray = GlobalData.sharedInstance.getContactsArray()
        self.partypeopleArray = GlobalData.sharedInstance.getCachedPmodeDataOfDB()//DBManager.getInstance().getAllPmodeMembersData()
        self.sortPartyPeopleArray()
        pmodeMembersCountOfDB = self.partypeopleArray.count
        if self.partypeopleArray.count > 0 {
            
            let partypeoples = Sections(title: NSLocalizedString("partypeople", comment: ""), objects: self.partypeopleArray)
            self.sectionsArray.append(partypeoples)
            editButton.isHidden = false
        }
        else {
            editButton.isHidden = true
            //DispatchQueue.main.async(execute: {
                GlobalData.sharedInstance.startLoadingData(sender:self)
            //})
        }
        
        let contacts = Sections(title: NSLocalizedString("contacts_title", comment: ""), objects: self.contactsArray)
        self.sectionsArray.append(contacts)
        
        self.tbl_partypeople.reloadData()
        
    }
    func sortPartyPeopleArray(){
        var sortedPartypeopleArray = [PartyPeopleCellData]()
        sortedPartypeopleArray.removeAll()
        for each in self.partypeopleArray {
            if each.pmode == Constants.PARTYMODE_NA {
                sortedPartypeopleArray.append(each)
            }
            else if each.pmode == Constants.PARTYMODE_OFF {
                sortedPartypeopleArray.insert(each, at: 0)
            }
            
        }
        for each in self.partypeopleArray {
            if each.pmode == Constants.PARTYMODE_ON {
                sortedPartypeopleArray.insert(each, at: 0)
            }
        }
        self.partypeopleArray.removeAll()
        self.partypeopleArray = sortedPartypeopleArray
    }
    func loadInitialData(){
        self.sectionsArray.removeAll()
        self.partypeopleArray = GlobalData.sharedInstance.getPartyPeopleArray()
        if self.partypeopleArray.count > 0 {
            let partypeoples = Sections(title: NSLocalizedString("partypeople", comment: ""), objects: self.partypeopleArray)
            self.sectionsArray.append(partypeoples)
            editButton.isHidden = false
        }
        else {
            editButton.isHidden = true
        }
        
        
        self.contactsArray = GlobalData.sharedInstance.getUnduplicatedContactsArray()
        let contacts = Sections(title: NSLocalizedString("contacts_title", comment: ""), objects: self.contactsArray)
        self.sectionsArray.append(contacts)
        
        self.tbl_partypeople.reloadData()
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
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsArray[section].headings
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        partyEmptyImage.isHidden = true
        return sectionsArray[section].partypeoples.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eachData: PartyPeopleCellData = sectionsArray[indexPath.section].partypeoples[indexPath.row]
        
        switch self.tableView(tableView, titleForHeaderInSection: indexPath.section)! {

        case NSLocalizedString("contacts_title", comment: ""):
            let cell = tbl_partypeople.dequeueReusableCell(withIdentifier: Constants.cellId_contactTableView, for: indexPath as IndexPath) as! ContactTableViewCell
            
            cell.avatarImage.image = eachData.face_image
            cell.personName?.text = eachData.name
            cell.phonenumberLabel.text = eachData.phonenumber
            cell.inviteButton.tag = indexPath.row
            cell.inviteButton.addTarget(self, action:  #selector(self.inviteClicked(_:)),for: .touchUpInside)
            makeAvatarBoderBlack(avatarImageView: (cell.avatarImage))
            
            
            return cell
        case NSLocalizedString("partypeople", comment: ""):
            let cell = tbl_partypeople.dequeueReusableCell(withIdentifier: Constants.cellId_partypeopleTableView, for: indexPath as IndexPath) as! PartyPeopleTableViewCell
            cell.phonenumberLabel.text = eachData.phonenumber
//            DispatchQueue.main.async(execute: {
//                
//            })
            cell.avatarImage.image = eachData.face_image
            cell.personName?.text = eachData.name
            
            hideActivityIndicator()
            
            if eachData.pmode == Constants.PARTYMODE_NA {//pending
                makeAvatarBoderBlack(avatarImageView: (cell.avatarImage))
                cell.partyfyButton.isHidden = false
                cell.partyfyIcon.isHidden = false
                //cell.disablePartify()
            }
            if eachData.pmode == Constants.PARTYMODE_OFF {//off
                makeAvatarBoderRed(avatarImageView: (cell.avatarImage))
                cell.partyfyButton.isHidden = true
                cell.partyfyIcon.isHidden = true
                //cell.disablePartify()
            }
            if eachData.pmode == Constants.PARTYMODE_ON {//on
                makeAvatarBoderGreen(avatarImageView: (cell.avatarImage))
                cell.partyfyButton.isHidden = true
                cell.partyfyIcon.isHidden = true
                //cell.enblePartify()
            }
            
            
            
//            let dbData : PmodeMemberCellData = DBManager.getInstance().getPmodeMemberData(eachData.phonenumber)
//            if receivedSetPmode == false {
//                if dbData.last_modified_pmode == dbData.pmode {
//                    let pmode_time = dbData.pmode_time
//                    let current_time = Int(NSDate().timeIntervalSince1970)
//                    
//                    if dbData.last_modified_pmode == Constants.PARTYMODE_ON {
//                        if current_time - pmode_time >= Constants.PARTYMODEON_DURATION{
//                            makeAvatarBoderBlack(avatarImageView: (cell.avatarImage))
//                            cell.partyfyButton.isHidden = false
//                            cell.partyfyIcon.isHidden = false
//                        }
//                    }
//                    if dbData.last_modified_pmode == Constants.PARTYMODE_OFF {
//                        if current_time - pmode_time >= Constants.PARTYMODEOFF_DURATION{
//                            makeAvatarBoderBlack(avatarImageView: (cell.avatarImage))
//                            cell.partyfyButton.isHidden = false
//                            cell.partyfyIcon.isHidden = false
//                        }
//                    }
//                    
//                    
//                }
//            }
            
            
            let partified_time = DBManager.getInstance().getPartifyInfo(eachData.phonenumber)
            
            let current_time = Int(NSDate().timeIntervalSince1970)
            if partified_time == 0 || (current_time - partified_time) > Constants.FREQUENCY_PARTIFY {
                cell.disablePartify()
            }
            else {
                cell.enblePartify()
            }
            
//            if partified_time == 0 {
//                cell.disablePartify()
//            }
//            else {
//                cell.enblePartify()
//            }
            
            cell.partyfyButton.tag = indexPath.row
            cell.partyfyButton.addTarget(self, action:  #selector(self.partifyClicked(_:)),for: .touchUpInside)
            
            return cell
            
        default:
            break
        }
        
        let cell = tbl_partypeople.dequeueReusableCell(withIdentifier: Constants.cellId_partypeopleTableView, for: indexPath as IndexPath) as! PartyPeopleTableViewCell
        return cell
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeAddCrowdButtonCircleShadow(){
        addButtonView.layer.cornerRadius = addButtonView.bounds.width / 2
        addButtonView.layer.shadowColor = UIColor.gray.cgColor
        addButtonView.layer.shadowOpacity = 1
        addButtonView.layer.shadowOffset = CGSize(width: 2, height: 2)
        addButtonView.layer.borderWidth = 0
    }
    
    @IBAction func addPartyCrowdCircleButtonPressed(_ sender: Any) {
        print("addPartyCrowdCircleButtonPressed in Tab2")
        let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "CreatePartyCrowdViewController") as! CreatePartyCrowdViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func transparentAddPartyCrowdButtonPressed(_ sender: Any) {
        print("addPartyCrowdCircleButtonPressed in Tab2")
        let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "CreatePartyCrowdViewController") as! CreatePartyCrowdViewController
        self.navigationController?.pushViewController(viewController, animated: true)
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
    
    
    @objc func inviteClicked(_ sender:UIButton) {
        print(sender.tag)
        let selectedContact: PartyPeopleCellData = sectionsArray[1].partypeoples[sender.tag]
        let phonenumber = selectedContact.phonenumber.replacingOccurrences(of: GlobalData.sharedInstance.getCountryCode(), with: "")
        sendSMSText(phoneNumber: phonenumber)
    }
    @objc func partifyClicked(_ sender:UIButton) {
        print(sender.tag)
        let selectedItem: PartyPeopleCellData = sectionsArray[0].partypeoples[sender.tag]
        PartifyContactAPICall().request(self, phone_nrToPartify: selectedItem.phonenumber, completionHandler: {(post) -> Void in
            if post == "failed" {
                
            }
            else {
                self.showToast(selectedItem.name + " " + NSLocalizedString("partify_success", comment: ""))
            }
        })
    }
    
    func sendSMSText(phoneNumber: String) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = NSLocalizedString("sms_invitation", comment: "")
            controller.recipients = [phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    func getCountryCode() -> String{
        let contact_countrycode = "+" + CountryCodeHelperCalss().getCountryPhonceCode(Locale.current.regionCode!)
        print(Locale.current.regionCode!)
        return contact_countrycode
        
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        //timer = Timer.scheduledTimer(timeInterval: TimeInterval(Constants.FREQUENCY_SEND_CONTACTS), target: self, selector: #selector(self.updateContacts), userInfo: nil, repeats: true)
        checkPmodeStatusIfPastValidTime()
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(Constants.FREQUENCY_REFRESH_PMODE), target: self, selector: #selector(self.checkPmodeStatusIfPastValidTime), userInfo: nil, repeats: true)
    }
    func checkPmodeStatusIfPastValidTime(){
        NSLog("checking and refreshing pmodes now..")
        var temp_partypeopleArray = GlobalData.sharedInstance.getPartyPeopleArray()
        var index = 0
        for eachData in temp_partypeopleArray {
            if let pmodeCacheData = DBManager.getInstance().getPmodeCacheData(eachData.phonenumber) {
            
                let current_time = Int(NSDate().timeIntervalSince1970)
                if pmodeCacheData.last_pmode == Constants.PARTYMODE_ON {
                    if current_time - (pmodeCacheData.last_pmode_time) >= Constants.PARTYMODEON_DURATION{
                        
                        var itemToModify = eachData
                        itemToModify.pmode = Constants.PARTYMODE_NA
                        GlobalData.sharedInstance.updatePartyPeopleArray(index: index, newArray: itemToModify)
                        _ = DBManager.getInstance().updatePmodeMemberData(itemToModify)
                        
                    }
                }
                if pmodeCacheData.last_pmode == Constants.PARTYMODE_OFF {
                    if current_time - (pmodeCacheData.last_pmode_time) >= Constants.PARTYMODEOFF_DURATION{
                        var itemToModify = eachData
                        itemToModify.pmode = Constants.PARTYMODE_NA
                        GlobalData.sharedInstance.updatePartyPeopleArray(index: index, newArray: itemToModify)
                        _ = DBManager.getInstance().updatePmodeMemberData(itemToModify)
                    }
                }
            }
            
            index = index + 1
        }
         GlobalData.sharedInstance.sortPartyPeopleArray()
        loadInitialData()
    }
    func updateContacts(){
        NSLog("refreshing and uploading contacts now..")
        GlobalData.sharedInstance.startLoadingData(sender:self)
    }
    func addEditButton(){
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let button = UIButton(frame: CGRect(x: screenWidth - 52, y: 33, width: 50, height: 15))
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitle("EDIT", for: .normal)
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        tbl_partypeople.addSubview(button)
    }
    func editButtonTapped(){
        print("Edit Button pressed")
        UserDefaults.standard.set("false", forKey: "shouldgotoPartypeopleTab")
        let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "PartyPeopleEditViewController") as! PartyPeopleEditViewController
        viewController.totalArray = sectionsArray[0].partypeoples
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        editButtonTapped()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tbl_partypeople {
            let contentOffset = scrollView.contentOffset.y
            //print("contentOffset: ", contentOffset)
            if (contentOffset > 38) {
//                print("scrolling Down")
//                print("dragging Up")
                editButton.isHidden = true
            } else {
//                print("scrolling Up")
//                print("dragging Down")
                editButton.isHidden = false
            }
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
            kCRToastTimeIntervalKey as NSObject: NSNumber(value: 2.5) as AnyObject,
            kCRToastUnderStatusBarKey as NSObject : NSNumber(value: true),
            kCRToastImageAlignmentKey as NSObject : NSNumber(value: NSTextAlignment.left.rawValue) as AnyObject,
            kCRToastTextAlignmentKey as NSObject : NSNumber(value: NSTextAlignment.left.rawValue) as AnyObject,
            kCRToastImageKey as NSObject : UIImage(named: "ico_partyfy05")!,
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
    
    func showAcitivityIndicator(){
        
        self.loadingIndicator.isHidden = false
        self.loadingIndicator.hidesWhenStopped = true
        self.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.loadingIndicator.startAnimating()
    }
    
    func hideActivityIndicator(){
        
        self.loadingIndicator.stopAnimating()
        
    }
}

