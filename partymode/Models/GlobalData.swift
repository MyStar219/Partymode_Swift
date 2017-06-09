//
//  GlobalData.swift
//  partymode
//
//  Created by Nikita on 2/9/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import APAddressBook
import AlamofireImage
import Alamofire
class GlobalData {
    
    static let sharedInstance = GlobalData()
    private init() {
        print("MyClass Initialized")
    }
    static var cached_partypeopleArray = [PartyPeopleCellData]()
    static var partypeopleArray = [PartyPeopleCellData]()
    static var contactsArray = [PartyPeopleCellData]()
    static var unduplicatedContactsArray = [PartyPeopleCellData]()//removed duplicates item of Partypeople from Constacts Array.
    static var sortedPartypeopleArray = [PartyPeopleCellData]()
    
    static var selectedPartyCrowdMembersArray = [PartyPeopleCellData]()
    static var createdPartyCrowdsArray = [PartyCrowdCellData]()
    static var selectedPartyCrowdItem: PartyCrowdCellData! = nil
    static var partytitlesArray = [
        NSLocalizedString("def_title1", comment: ""),
        NSLocalizedString("def_title2", comment: ""),
        NSLocalizedString("def_title3", comment: ""),
        NSLocalizedString("def_title4", comment: ""),
        NSLocalizedString("def_title5", comment: "")
    ]
    static var partylocationsArray = [
        NSLocalizedString("def_location1", comment: ""),
        NSLocalizedString("def_location2", comment: ""),
        NSLocalizedString("def_location3", comment: ""),
        NSLocalizedString("def_location4", comment: ""),
        NSLocalizedString("def_location5", comment: "")
    ]
    
    static let addressBook = APAddressBook()
    static var contacts = [APContact]()
    
    static var phoneNumbersArrayOfDB = [String]()
    static var phoneNumbersArrayToSend = [String]()
    static var temp_phoneNumbersArrayToSend = [String]()
    static var currentCountryCodeNum:String!
    
    static var newAddedPhoneNumbersArray = [String]()
    static var deletedPhoneNumbersArray = [String]()
    
    func loadPmodeUsersDataFromDB(){
        GlobalData.cached_partypeopleArray.removeAll()
        GlobalData.cached_partypeopleArray = DBManager.getInstance().getAllPmodeMembersData()
    }
    func getCachedPmodeDataOfDB() -> [PartyPeopleCellData] {
        return GlobalData.cached_partypeopleArray
    }
    func startLoadingData(sender:UIViewController){
        GlobalData.partypeopleArray.removeAll()
        GlobalData.contactsArray.removeAll()
        GlobalData.unduplicatedContactsArray.removeAll()
        GlobalData.phoneNumbersArrayToSend.removeAll()
        
        
        GlobalData.currentCountryCodeNum = getCountryCode()
        GlobalData.addressBook.fieldsMask = [APContactField.default, APContactField.thumbnail]
        GlobalData.addressBook.sortDescriptors = [NSSortDescriptor(key: "name.firstName", ascending: true),
                                       NSSortDescriptor(key: "name.lastName", ascending: true)]
        GlobalData.addressBook.filterBlock =
            {
                (contact: APContact) -> Bool in
                if let phones = contact.phones
                {
                    return phones.count > 0
                }
                return false
        }
        
        self.loadContacts(sender: sender)
    }

    func loadContacts(sender:UIViewController)
    {
        GlobalData.addressBook.loadContacts
            {
                [unowned self] (contacts: [APContact]?, error: Error?) in
                
                if let contacts = contacts
                {
                    GlobalData.contacts = contacts
                    var eachItem: PartyPeopleCellData!
                    for eachContact in GlobalData.contacts {
                        let faceImage:UIImage!
                        if eachContact.thumbnail != nil {
                            faceImage = eachContact.thumbnail
                        }
                        else {
                            faceImage = UIImage(named: "nav_profile_inactive")
                        }
                        
                        for phone in eachContact.phones! {
                            if let number = phone.number {
                                let number = self.filterPhonenumberString(number: number)
                                
                                GlobalData.phoneNumbersArrayToSend.append(number)
                                eachItem = PartyPeopleCellData(image: faceImage, name_string: self.contactName(eachContact), phonenumber: number, pmode: Constants.PARTYMODE_NA, img_off_lc: 0, img_on_lc: 0, img_pending_lc: 0, user_state: Constants.STATE_CONTACT)
                                GlobalData.contactsArray.append(eachItem)
                            }
                        }
                        
                    }
                    
                    GlobalData.phoneNumbersArrayOfDB = DBManager.getInstance().getAllContactNumbersData()
                    
                    for phone_each_contact in GlobalData.contactsArray {//from DB's contacts
                        var isExist = false
                        for db_each_number in GlobalData.phoneNumbersArrayOfDB {//from iPhone's Contacts
                            if phone_each_contact.phonenumber == db_each_number {
                                isExist = true
                                break
                            }
                        }
                        if isExist == false {
                            //this phone_each_number is new contact
                            //GlobalData.newAddedPhoneNumbersArray.append(phone_each_contact.phonenumber)
                            print("\(phone_each_contact.phonenumber) is new added friend")
                            let isInserted = DBManager.getInstance().addContactData(phone_each_contact)
                        }
                    }
                
                    for db_each_number in GlobalData.phoneNumbersArrayOfDB {
                        var isExist = false
                        for phone_each_contact in GlobalData.contactsArray {
                            if db_each_number == phone_each_contact.phonenumber {
                                isExist = true
                                break
                            }
                        }
                        if isExist == false {
                            //this db_each_number is removed contact
                            //GlobalData.deletedPhoneNumbersArray.append(db_each_number)
                            print("\(db_each_number) is not in contacts now, so removing from DB now...")
                            let isRemoved = DBManager.getInstance().deleteContactFromDB(db_each_number)
                        }
                        
                    }
                    
                    if GlobalData.phoneNumbersArrayToSend.count > 0 {
                        SendContactsAPICallForPreLoading().request(sender: sender, contactNumbers: GlobalData.phoneNumbersArrayToSend, completionHandler: {(partypeopleArray) -> Void in
                            
                            let temp_partypeopleArray = partypeopleArray
                            self.removeDuplicatsFromContacts(partypeopleArray: temp_partypeopleArray)
                            //NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_refreshContacts"), object: nil)
                            
                            if GlobalData.sharedInstance.getPartyPeopleArray().count > 0{
                                self.loadImageOfPartypeople()
                            }
                            else {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_refreshContacts"), object: nil)
                            }
                            
                        })
                    }
                    else {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_refreshContacts"), object: nil)
                    }
                    
                }
        }
    }
    func startLoadingIfNewContactAddedOrDeleted(_ sender:UIViewController){
        GlobalData.temp_phoneNumbersArrayToSend.removeAll()
        
        GlobalData.currentCountryCodeNum = getCountryCode()
        GlobalData.addressBook.fieldsMask = [APContactField.default, APContactField.thumbnail]
        GlobalData.addressBook.sortDescriptors = [NSSortDescriptor(key: "name.firstName", ascending: true),
                                                  NSSortDescriptor(key: "name.lastName", ascending: true)]
        GlobalData.addressBook.filterBlock =
            {
                (contact: APContact) -> Bool in
                if let phones = contact.phones
                {
                    return phones.count > 0
                }
                return false
        }
        GlobalData.addressBook.loadContacts
            {
                [unowned self] (contacts: [APContact]?, error: Error?) in
                
                if let contacts = contacts
                {
                    GlobalData.contacts = contacts
                    for eachContact in GlobalData.contacts {
                        for phone in eachContact.phones! {
                            if let number = phone.number {
                                
                                GlobalData.temp_phoneNumbersArrayToSend.append(number)
                                
                            }
                        }
                        
                    }
                    let oldContactsCount = GlobalData.phoneNumbersArrayToSend.count
                    let currentContactsCount = GlobalData.temp_phoneNumbersArrayToSend.count
                    print("oldContactsCount: \(oldContactsCount) currentContactsCount: \(currentContactsCount)")
                    if oldContactsCount != currentContactsCount {
                        GlobalData.sharedInstance.startLoadingData(sender:sender)
                    }
                   
                }
            }
        
    }
    
    func contactName(_ contact :APContact) -> String {
        if let firstName = contact.name?.firstName, let lastName = contact.name?.lastName {
            return "\(firstName) \(lastName)"
        }
        else if let firstName = contact.name?.firstName {
            return "\(firstName)"
        }
        else if let lastName = contact.name?.lastName {
            return "\(lastName)"
        }
        else {
            return "Unnamed contact"
        }
    }
    
//    func contactPhones(_ contact :APContact) -> String {
//        if let phones = contact.phones {
//            var phonesString = ""
//            //            var contact_countrycode = ""
//            for phone in phones {
//                if let number = phone.number {
//                    let number = self.filterPhonenumberString(number: number)
//                    GlobalData.phoneNumbersArrayToSend.append(number)
//                    phonesString = phonesString + " " + number
//                }
//            }
//            
//            return phonesString
//        }
//        return "No phone"
//    }
    func filterPhonenumberString(number:String) -> String {
        let number = number.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        var trimmedString = number.removingWhitespaces()
        
        if trimmedString.characters.first != "+" {
            let index:String.Index = trimmedString.index(trimmedString.startIndex, offsetBy: 0)
            if trimmedString[index] == "0" {
                let choppedChar:Character = trimmedString.remove(at: index)
                //print(trimmedString)
                
                if trimmedString[index] == "0" {
                    let choppedChar:Character = trimmedString.remove(at: index)
                    //print(trimmedString)
                }
            }
            trimmedString = GlobalData.currentCountryCodeNum + trimmedString
        }
        
        
        
        return trimmedString
    }
    func removeItemFromUnduplicatedArray(_ item:PartyPeopleCellData){
        var index = 0
        for eachContact in GlobalData.unduplicatedContactsArray{
            if item.phonenumber == eachContact.phonenumber {
                
                GlobalData.unduplicatedContactsArray.remove(at: index)
                index = index + 1
            }
        }
    }
    func removeDuplicatsFromContacts(partypeopleArray: [PartyPeopleCellData]){
        GlobalData.partypeopleArray.removeAll()
        GlobalData.unduplicatedContactsArray.removeAll()
        //GlobalData.unduplicatedContactsArray = GlobalData.contactsArray
        var faceImage:UIImage = UIImage(named: "nav_profile_inactive")!
        for eachPartyPeople in partypeopleArray {
            //var repeatIndex = -1
            for eachContact in GlobalData.contacts {
                if let phones = eachContact.phones {
                    for phone in phones {
                        //repeatIndex = repeatIndex + 1
                        if eachPartyPeople.phonenumber == self.filterPhonenumberString(number: phone.number!) {//found duplicated item
                            //displaying for only partypeople contacs avartar from contact images.
//                            if eachContact.thumbnail != nil {
//                                faceImage = eachContact.thumbnail!
//                            }
                            GlobalData.partypeopleArray.append(PartyPeopleCellData(image: faceImage, name_string: self.contactName(eachContact), phonenumber: eachPartyPeople.phonenumber, pmode: eachPartyPeople.pmode, img_off_lc: eachPartyPeople.img_off_lc, img_on_lc: eachPartyPeople.img_on_lc, img_pending_lc: eachPartyPeople.img_pending_lc, user_state: eachPartyPeople.user_state, pmode_time: eachPartyPeople.pmode_time!))
                            
                            //GlobalData.unduplicatedContactsArray.remove(at: repeatIndex)
                            //repeatIndex = repeatIndex - 1
                            //break
                        }
//                        else {
//                            GlobalData.unduplicatedContactsArray.append(PartyPeopleCellData(image: faceImage, name_string: self.contactName(eachContact), phonenumber: eachPartyPeople.phonenumber, pmode: eachPartyPeople.pmode, img_off_lc: eachPartyPeople.img_off_lc, img_on_lc: eachPartyPeople.img_on_lc, img_pending_lc: eachPartyPeople.img_pending_lc, user_state: eachPartyPeople.user_state))
//                        }
                        
                    }
                }
                
            }
        }
        
        for eachContact in GlobalData.contactsArray  {
            var exist = false
            for eachPartyPeople in partypeopleArray{
                if eachPartyPeople.phonenumber == eachContact.phonenumber {
                    exist = true
                }
            }
            if exist == false {
                GlobalData.unduplicatedContactsArray.append(eachContact)
            }
        }
        
        print("partypeopleArray: \(GlobalData.partypeopleArray)")
        
        self.sortPartyPeopleArray()
        print("sorted partypeopleArray: \(GlobalData.partypeopleArray)")
        self.checkPmodeStatusIfPastValidTime()
//        print("partypeopleArray: \(GlobalData.partypeopleArray)")
//        print("contactsArray: \(GlobalData.contactsArray)")
//        print("unduplicatedContactsArray: \(GlobalData.unduplicatedContactsArray)")
    }
    func loadImageOfPartypeople(){
        
        for each in GlobalData.partypeopleArray {
            DownloadPictureOfContactAPICall().request(phone_nr: each.phonenumber, imagemode: each.pmode, completionHandler: {(fetchedImage) -> Void in
                let index = self.getIndexByPhoneNumberFromPartypeopArray(each.phonenumber)
                print("index\(index)")
                print(GlobalData.partypeopleArray)
                if GlobalData.partypeopleArray.count > 0 {
                    GlobalData.partypeopleArray[index].face_image = fetchedImage
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_refreshContacts"), object: nil)

                }
                
            })
        }
        
    }
    func loadImageOfPartyperson(_ phoneNr:String, pmode:Int){
        DownloadPictureOfContactAPICall().request(phone_nr: phoneNr, imagemode: pmode, completionHandler: {(fetchedImage) -> Void in
            let index = self.getIndexByPhoneNumberFromPartypeopArray(phoneNr)
            GlobalData.partypeopleArray[index].face_image = fetchedImage
            NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_refreshContacts"), object: nil)
        })
    }
    func getIndexByPhoneNumberFromPartypeopArray(_ phoneNr:String) -> Int{
        var index = 0
        for each in GlobalData.partypeopleArray {
            if each.phonenumber == phoneNr {
                break
            }
            index = index + 1
        }
        return index
    }
    func getCountryCode() -> String{
        let contact_countrycode = "+" + CountryCodeHelperCalss().getCountryPhonceCode(Locale.current.regionCode!)
        //print(Locale.current.regionCode!)
        return contact_countrycode
        
    }
    func getPartyPeopleArray() -> [PartyPeopleCellData] {
        return GlobalData.partypeopleArray
    }
    func updatePartyPeopleArray(index:Int, newArray:PartyPeopleCellData){
        GlobalData.partypeopleArray[index] = newArray
    }
    func setPartyPeopleArray(newArray:[PartyPeopleCellData]){
        GlobalData.partypeopleArray.removeAll()
        GlobalData.partypeopleArray = newArray
//        print("partypeopleArray: \(GlobalData.partypeopleArray)")
        
        self.sortPartyPeopleArray()
//        print("sorted partypeopleArray: \(GlobalData.partypeopleArray)")
    }
    func sortPartyPeopleArray(){
//        var i = 0
        GlobalData.sortedPartypeopleArray.removeAll()
        for each in GlobalData.partypeopleArray {
            if each.pmode == Constants.PARTYMODE_NA {
                GlobalData.sortedPartypeopleArray.append(each)
            }
            else if each.pmode == Constants.PARTYMODE_OFF {
                GlobalData.sortedPartypeopleArray.insert(each, at: 0)
            }
            
        }
        for each in GlobalData.partypeopleArray {
            if each.pmode == Constants.PARTYMODE_ON {
                GlobalData.sortedPartypeopleArray.insert(each, at: 0)
            }
        }
        GlobalData.partypeopleArray.removeAll()
        GlobalData.partypeopleArray = GlobalData.sortedPartypeopleArray
    }
    func getFaceImageFromContactsArray(_ phone_nr:String) -> UIImage {
        let partypeopleArray = GlobalData.sharedInstance.getPartyPeopleArray()
        for eachPartyPeople in partypeopleArray {
            if phone_nr == eachPartyPeople.phonenumber {
                return eachPartyPeople.face_image
            }
        }
        for each in GlobalData.contactsArray {
            if each.phonenumber == phone_nr {
                return each.face_image
            }
        }
        return UIImage(named: "nav_profile_inactive")!
    }
    func getContactsArray() -> [PartyPeopleCellData] {
        return GlobalData.contactsArray
    }
    func setContactsArray(newArray:[PartyPeopleCellData]){
        GlobalData.contactsArray.removeAll()
        GlobalData.contactsArray = newArray
    }
    func getUnduplicatedContactsArray() -> [PartyPeopleCellData] {
        return GlobalData.unduplicatedContactsArray
    }
    func setUnduplicatedContactsArray(newArray:[PartyPeopleCellData]){
        GlobalData.unduplicatedContactsArray.removeAll()
        GlobalData.unduplicatedContactsArray = newArray
    }
    func getSelectedPartyCrowdMembersArray() -> [PartyPeopleCellData] {
        return GlobalData.selectedPartyCrowdMembersArray
    }
    func addSelectedPartyCrowdMemberToArray(_ item:PartyPeopleCellData){
        GlobalData.selectedPartyCrowdMembersArray.append(item)
    }
    func removeSelectedPartyCrowdMemberFromArray(_ item: PartyPeopleCellData){
        var index = 0
        for each in GlobalData.selectedPartyCrowdMembersArray {
            if item.phonenumber ==  each.phonenumber {
                GlobalData.selectedPartyCrowdMembersArray.remove(at: index)
            }
            index = index + 1
        }
    }
    func removeAllSelectedPartyCrowdMemberFromArray(){
        GlobalData.selectedPartyCrowdMembersArray.removeAll()
    }
    func getRandomPartyTitle() -> String {
        let randomIndex = Int(arc4random_uniform(UInt32(GlobalData.partytitlesArray.count)))
        // Get a random item
        return GlobalData.partytitlesArray[randomIndex]
    }
    func getRandomLocationTitle() -> String {
        let randomIndex = Int(arc4random_uniform(UInt32(GlobalData.partylocationsArray.count)))
        // Get a random item
        return GlobalData.partylocationsArray[randomIndex]
    }
    func addToCreatedPartyCrowdsArray(_ item: PartyCrowdCellData){
        GlobalData.createdPartyCrowdsArray.append(item)
        
    }
    func getCreatedPartyCrowdsArray() -> [PartyCrowdCellData]{
        return GlobalData.createdPartyCrowdsArray
    }
    
    func setSelectedPartyCrowdItem(_ item: PartyCrowdCellData) {
        GlobalData.selectedPartyCrowdItem = item
    }
    func getSelectedPartyCrowdItem() ->  PartyCrowdCellData{
        return GlobalData.selectedPartyCrowdItem
    }
    
    func getPartyPeopleArrayWith(crowdMembersPhoneArray: [String]) -> [PartyPeopleCellData] {
        var partypeopleArray = [PartyPeopleCellData]()
        for each_crowdmember_phone in crowdMembersPhoneArray {
            for eachContact in GlobalData.sharedInstance.getPartyPeopleArray(){//GlobalData.contactsArray {
                if each_crowdmember_phone == eachContact.phonenumber {
                    partypeopleArray.append(eachContact)
                    
                }
            }
        }
        
        return partypeopleArray
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
        
        let partypeopleArray = GlobalData.sharedInstance.getPartyPeopleArray()
        var pmodeON_count = 0
        for each in partypeopleArray {
            
            if each.pmode == Constants.PARTYMODE_ON {
                pmodeON_count = pmodeON_count + 1
            }
        }
        let partypOnPeopleCount_string = String(describing: pmodeON_count)
        UserDefaults.standard.set(partypOnPeopleCount_string, forKey: "partypeople_count")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_updatePartyPeopleCount"), object: nil)
    }
}
extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
