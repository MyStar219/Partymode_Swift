//
//  DBManager.swift
//  partymode
//
//  Created by Nikita on 2/13/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import UIKit

let sharedInstance = DBManager()

class DBManager: NSObject {
    
    var database: FMDatabase? = nil
    
    class func getInstance() -> DBManager
    {
        if(sharedInstance.database == nil)
        {
            sharedInstance.database = FMDatabase(path: DBUtil.getPath("partymode.sqlite"))
        }
        return sharedInstance
    }
    /****** ImageChatCacheData  ******/
    func addImageCacheData(_ imageUrl: String, imageData:String) -> Bool {
        
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO chatImagesCache (imageUrl, imageData) VALUES (?, ?)", withArgumentsIn: [imageUrl, imageData])
        
        sharedInstance.database!.close()
        return isInserted
    }
    func updateImageCacheData(_ imageUrl: String, imageData:String) -> Bool {
        
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE chatImagesCache SET imageData=? WHERE imageUrl=?", withArgumentsIn: [imageData, imageUrl])
        sharedInstance.database!.close()
        return isUpdated
    }
    func getImageCacheData(_ imageUrl:String) -> String? {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM chatImagesCache WHERE imageUrl=?", withArgumentsIn: [imageUrl])
        var imageCacheData : String?
        if (resultSet != nil) {
            while resultSet.next() {
                imageCacheData = resultSet.string(forColumn: "imageData")!
                
            }
        }
        sharedInstance.database!.close()
        return imageCacheData
    }
    func deleteAllImageCacheData() -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM chatImagesCache", withArgumentsIn: nil)
        sharedInstance.database!.close()
        return isDeleted
    }
    
    /****** PmodeCacheData  ******/
    func addPmodeCacheData(_ phonenumber: String, pmode_time:Int, pmode:Int) -> Bool {
        
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO pmode_modified_cache (phonenumber, last_pmode_time, last_pmode) VALUES (?, ?, ?)", withArgumentsIn: [phonenumber, pmode_time, pmode])
        
        sharedInstance.database!.close()
        return isInserted
    }
    func updatePmodeCacheData(_ phonenumber: String, pmode_time:Int, pmode:Int) -> Bool {
        
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE pmode_modified_cache SET  last_pmode_time=?, last_pmode=? WHERE phonenumber=?", withArgumentsIn: [pmode_time, pmode,phonenumber])
        sharedInstance.database!.close()
        return isUpdated
    }
    func getPmodeCacheData(_ phonenumber:String) -> PmodeCacheData? {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM pmode_modified_cache WHERE phonenumber=?", withArgumentsIn: [phonenumber])
        var pmodeCacheData : PmodeCacheData?
        if (resultSet != nil) {
            while resultSet.next() {
                let phoneNumber = resultSet.string(forColumn: "phonenumber")!
                
                let last_pmode_time = Int(resultSet.int(forColumn: "last_pmode_time"))
                let last_pmode = Int(resultSet.int(forColumn: "last_pmode"))
                
                
                pmodeCacheData = PmodeCacheData(phonenumber: phonenumber, last_pmode_time: last_pmode_time, last_pmode: last_pmode)
                
            }
        }
        sharedInstance.database!.close()
        return pmodeCacheData
    }
    /****** PmodeMembersData  ******/
    func deleteAllPmodeMembersData() -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM pmode_members", withArgumentsIn: nil)
        sharedInstance.database!.close()
        return isDeleted
    }
    func getAllPmodeMembersData() -> [PartyPeopleCellData] {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM pmode_members", withArgumentsIn: nil)
        var pmodeMembersArrayOfDB = [PartyPeopleCellData]()
        if (resultSet != nil) {
            while resultSet.next() {
                let phoneNumber = resultSet.string(forColumn: "phonenumber")!
                let name = resultSet.string(forColumn: "name")!
                let pmode = Int(resultSet.int(forColumn: "pmode"))
                //let pmode_time = Int(resultSet.int(forColumn: "pmode_time"))
                let user_state = Int(resultSet.int(forColumn: "user_state"))
                //let partified_time = Int(resultSet.int(forColumn: "partified_time"))
                let profile_image = resultSet.string(forColumn: "profile_image")!
                let img_off_lc = Int(resultSet.int(forColumn: "img_off_lc"))
                let img_on_lc = Int(resultSet.int(forColumn: "img_on_lc"))
                let img_pending_lc = Int(resultSet.int(forColumn: "img_pending_lc"))
                
                var image = UIImage(named: "nav_profile_inactive")!
                if profile_image != "" {
                    image = Base64Util().decodedFromBase64(profile_image)
                }
                let eachItem = PartyPeopleCellData(image: image, name_string: name, phonenumber: phoneNumber, pmode: pmode, img_off_lc: img_off_lc, img_on_lc: img_on_lc, img_pending_lc: img_pending_lc, user_state: user_state)
                pmodeMembersArrayOfDB.append(eachItem)
            }
        }
        sharedInstance.database!.close()
        return pmodeMembersArrayOfDB
    }
    func getPmodeMemberData(_ phonenumber:String) -> PmodeMemberCellData {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM pmode_members WHERE phonenumber=?", withArgumentsIn: [phonenumber])
        var pmodeMemberData : PmodeMemberCellData!
        if (resultSet != nil) {
            while resultSet.next() {
                let phoneNumber = resultSet.string(forColumn: "phonenumber")!
                let name = resultSet.string(forColumn: "name")!
                let last_modified_pmode = Int(resultSet.int(forColumn: "last_modified_pmode"))
                let pmode = Int(resultSet.int(forColumn: "pmode"))
                let pmode_time = Int(resultSet.int(forColumn: "pmode_time"))
                let user_state = Int(resultSet.int(forColumn: "user_state"))
                let partified_time = Int(resultSet.int(forColumn: "partified_time"))
                //let profile_image = resultSet.string(forColumn: "profile_image")!
                let img_off_lc = Int(resultSet.int(forColumn: "img_off_lc"))
                let img_on_lc = Int(resultSet.int(forColumn: "img_on_lc"))
                let img_pending_lc = Int(resultSet.int(forColumn: "img_pending_lc"))
                
                pmodeMemberData = PmodeMemberCellData(name_string: name, phonenumber: phoneNumber, pmode: pmode, pmode_time: pmode_time, user_state: user_state, partified_time: partified_time, img_off_lc: img_off_lc, img_on_lc: img_on_lc, img_pending_lc: img_pending_lc, last_modified_pmode: last_modified_pmode)
                
                //PartyPeopleCellData(image: image, name_string: name, phonenumber: phoneNumber, pmode: pmode, img_off_lc: img_off_lc, img_on_lc: img_on_lc, img_pending_lc: img_pending_lc, user_state: user_state)
                
            }
        }
        sharedInstance.database!.close()
        return pmodeMemberData
    }
    func addPmodeMemberData(_ pmodeMemberInfo: PartyPeopleCellData) -> Bool {
        let profile_image_string = Base64Util().convertToBase64(pmodeMemberInfo.face_image)
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO pmode_members (phonenumber, name, pmode, pmode_time, user_state, profile_image, img_off_lc, img_on_lc, img_pending_lc, last_modified_pmode) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", withArgumentsIn: [pmodeMemberInfo.phonenumber, pmodeMemberInfo.name, pmodeMemberInfo.pmode, pmodeMemberInfo.pmode_time!, pmodeMemberInfo.user_state, profile_image_string, pmodeMemberInfo.img_off_lc, pmodeMemberInfo.img_on_lc, pmodeMemberInfo.img_pending_lc, pmodeMemberInfo.pmode])
        
        sharedInstance.database!.close()
        return isInserted
    }
    
    func updatePmodeMemberData(_ pmodeMemberInfo: PartyPeopleCellData) -> Bool {
        let profile_image_string = Base64Util().convertToBase64(pmodeMemberInfo.face_image)
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE pmode_members SET name=?, pmode=?, pmode_time=?,user_state=?, profile_image=?, img_off_lc=?, img_on_lc=?, img_pending_lc=? WHERE phonenumber=?", withArgumentsIn: [pmodeMemberInfo.name, pmodeMemberInfo.pmode, pmodeMemberInfo.pmode_time!, pmodeMemberInfo.user_state, profile_image_string, pmodeMemberInfo.img_off_lc, pmodeMemberInfo.img_on_lc, pmodeMemberInfo.img_pending_lc, pmodeMemberInfo.phonenumber])
        sharedInstance.database!.close()
        return isUpdated
    }
    func updatePartifiedtime(phonenumber:String, partified_time: Int) -> Bool {
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE pmode_members SET partified_time=? WHERE phonenumber=?", withArgumentsIn: [partified_time, phonenumber])
        sharedInstance.database!.close()
        return isUpdated
    }
    
    /****** ContactData  ******/
    func getAllContactNumbersData() -> [String] {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM contact_list", withArgumentsIn: nil)
        var contactsNumbersArrayOfDB = [String]()
        if (resultSet != nil) {
            while resultSet.next() {
                let each_phone_nr = resultSet.string(forColumn: "phone_nr")!
                contactsNumbersArrayOfDB.append(each_phone_nr)
            }
        }
        sharedInstance.database!.close()
        return contactsNumbersArrayOfDB
    }
    func getUser(_ phone_nr: String) -> PartyPeopleCellData {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM contact_list WHERE phone_nr=?", withArgumentsIn: [phone_nr])
        var searchedContactInfo = PartyPeopleCellData(image: UIImage(named: "nav_profile_inactive")!, name_string: "", phonenumber: "", pmode: 0, img_off_lc: 0, img_on_lc: 0, img_pending_lc: 0, user_state: 0)
        if (resultSet != nil) {
            while resultSet.next() {
                
                let interactions = Int(resultSet.int(forColumn: "interactions"))
                let pmode = Int(resultSet.int(forColumn: "pmode"))
                let user_state = Int(resultSet.int(forColumn: "user_state"))
                let pmode_time = Int(resultSet.int(forColumn: "pmode_time"))
                let partified_time = Int(resultSet.int(forColumn: "partified_time"))
                let in_addressbook = Int(resultSet.int(forColumn: "in_addressbook"))
                
                let name = resultSet.string(forColumn: "name")!
                let get_notification = Int(resultSet.int(forColumn: "get_notification"))
                //let img_off = resultSet.string(forColumn: "img_off")!
                let img_off_lc = Int(resultSet.int(forColumn: "img_off_lc"))
                //let img_on = resultSet.string(forColumn: "img_on")!
                let img_on_lc = Int(resultSet.int(forColumn: "img_on_lc"))
                //let img_pending = resultSet.string(forColumn: "img_pending")!
                let img_pending_lc = Int(resultSet.int(forColumn: "img_pending_lc"))
                let phone_nr = resultSet.string(forColumn: "phone_nr")!
                
                let faceImage = GlobalData.sharedInstance.getFaceImageFromContactsArray(phone_nr)
                searchedContactInfo = PartyPeopleCellData(image: faceImage, name_string: name, phonenumber: phone_nr, pmode: pmode, img_off_lc: img_off_lc, img_on_lc: img_on_lc, img_pending_lc: img_pending_lc, user_state: user_state)
            }
        }
        sharedInstance.database!.close()
        return searchedContactInfo
    }
    
    func addContactData(_ contactInfo: PartyPeopleCellData) -> Bool {
        
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO contact_list (phone_nr, name, pmode, img_off_lc, img_on_lc, img_pending_lc, user_state) VALUES (?, ?, ?, ?, ?, ?, ?)", withArgumentsIn: [contactInfo.phonenumber, contactInfo.name, contactInfo.pmode, contactInfo.img_off_lc, contactInfo.img_on_lc, contactInfo.img_pending_lc, contactInfo.user_state])
        
        sharedInstance.database!.close()
        return isInserted
    }
    
    func updateContactData(_ contactInfo: PartyPeopleCellData) -> Bool {
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE contact_list SET pmode=?, img_off_lc=?, img_on_lc=?, img_pending_lc=?, user_state=? WHERE phone_nr=?", withArgumentsIn: [contactInfo.pmode, contactInfo.img_off_lc, contactInfo.img_on_lc, contactInfo.img_pending_lc, contactInfo.user_state, contactInfo.phonenumber])
        sharedInstance.database!.close()
        return isUpdated
    }
    func deleteContactFromDB(_ phoneNumber:String) -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM contact_list WHERE phone_nr=?", withArgumentsIn: [phoneNumber])
        let isDeleted2 = sharedInstance.database!.executeUpdate("DELETE FROM pmode_members WHERE phonenumber=?", withArgumentsIn: [phoneNumber])
        sharedInstance.database!.close()
        return isDeleted
    }
    /*
    func deleteAllContactData() -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE * FROM contact_list", withArgumentsIn: nil)
        sharedInstance.database!.close()
        return isDeleted
    }
    */
    
    func setPartifyInfo(_ phone_nr: String, partified_time:Int) -> Bool {
        sharedInstance.database!.open()
        
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE contact_list SET partified_time=? WHERE phone_nr=?", withArgumentsIn: [partified_time, phone_nr])
        sharedInstance.database!.close()
        return isUpdated
    }

    
    func getPartifyInfo(_ phone_nr: String) -> Int {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM contact_list WHERE phone_nr=?", withArgumentsIn: [phone_nr])
        var partified_time: Int = 0
        if (resultSet != nil) {
            while resultSet.next() {
                partified_time = Int(resultSet.int(forColumn: "partified_time"))
                
            }
        }
        sharedInstance.database!.close()
        return partified_time
    }
    
    func setNotificationInfo(_ phone_nr: String, status:Int) -> Bool {
        sharedInstance.database!.open()
        
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE contact_list SET get_notification=? WHERE phone_nr=?", withArgumentsIn: [status, phone_nr])
        sharedInstance.database!.close()
        return isUpdated
    }
    func getNotificationInfo(_ phone_nr: String) -> Int {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM contact_list WHERE phone_nr=?", withArgumentsIn: [phone_nr])
        var notification_status: Int = 0
        if (resultSet != nil) {
            while resultSet.next() {
                notification_status = Int(resultSet.int(forColumn: "get_notification"))
                
            }
        }
        sharedInstance.database!.close()
        return notification_status
    }
    func setUserState(_ phone_nr: String, status:Int) -> Bool {
        sharedInstance.database!.open()
        
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE contact_list SET user_state=? WHERE phone_nr=?", withArgumentsIn: [status, phone_nr])
        sharedInstance.database!.close()
        return isUpdated
    }
    func setUserPmode(_ phone_nr: String, pmode:Int) -> Bool {
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE contact_list SET pmode=? WHERE phone_nr=?", withArgumentsIn: [pmode, phone_nr])
        sharedInstance.database!.close()
        return isUpdated
    }
    func setUserPmodeTime(_ phone_nr: String, pmode_time:Int) -> Bool {
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE contact_list SET pmode_time=? WHERE phone_nr=?", withArgumentsIn: [pmode_time, phone_nr])
        sharedInstance.database!.close()
        return isUpdated
    }
    /****** CrowdMember  ******/
    func getAllMembersArray(_ crowd_id:String) -> [String] {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM crowd_members WHERE crowd_id=?", withArgumentsIn: [crowd_id])
        var membersArray = [String]()
        if (resultSet != nil) {
            while resultSet.next() {
                let member = resultSet.string(forColumn: "member")!
                membersArray.append(member)
            }
        }
        sharedInstance.database!.close()
        return membersArray
    }
    func getAllMemberItemsArray(_ crowd_id:String) -> [CrowdMemberItem] {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM crowd_members WHERE crowd_id=?", withArgumentsIn: [crowd_id])
        var memberItemsArray = [CrowdMemberItem]()
        if (resultSet != nil) {
            while resultSet.next() {
                let phoneNumber = resultSet.string(forColumn: "member")!
                let status = Int(resultSet.int(forColumn: "status"))
                let msg = resultSet.string(forColumn: "msg")!
                
                let eachMemberItem = CrowdMemberItem(crowdId: crowd_id, phoneNumber: phoneNumber, status: status, msg: msg)
                memberItemsArray.append(eachMemberItem)
            }
        }
        
        sharedInstance.database!.close()
        return memberItemsArray
    }
    func addCrowdMembers(_ crowdMembers: [String], crowdId:String) -> Bool {
        sharedInstance.database!.open()
        for each in crowdMembers {
            _ = sharedInstance.database!.executeUpdate("INSERT INTO crowd_members (crowd_id, member, status, msg) VALUES (?, ?, ?, ?)", withArgumentsIn: [crowdId, each, Constants.CROWD_STATUS_PENDING, ""])
        }
        sharedInstance.database!.close()
        return true
    }
    func addCrowdMembers(_ crowdMembers: [String], crowdId:String, status:Int) -> Bool {
        sharedInstance.database!.open()
        for each in crowdMembers {
//            let isUpdated = self.updateCrowdMember(each, crowdId: crowdId)
//            if isUpdated == false {
                _ = sharedInstance.database!.executeUpdate("INSERT INTO crowd_members (crowd_id, member, status, msg) VALUES (?, ?, ?, ?)", withArgumentsIn: [crowdId, each, status, ""])
//            }
        }
        sharedInstance.database!.close()
        return true
    }
    func updateCrowdMemberData(_ crowdId: String, phoneNr: String, crowd_status: Int, msg:String) -> Bool {
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE crowd_members SET  status=?, msg=? WHERE crowd_id=? AND member=?", withArgumentsIn: [crowd_status, msg, crowdId, phoneNr])
        sharedInstance.database!.close()
        return isUpdated
    }
//    func updateCrowdMember(_ member_phoneNr: String, crowdId:String) -> Bool{
//        sharedInstance.database!.open()
//        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE crowd_members SET member=? WHERE crowd_id=?", withArgumentsIn: [member_phoneNr, crowdId])
//        sharedInstance.database!.close()
//        return isUpdated
//    }
    func DeleteCrowdMembers(_ crowdId:String) -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM crowd_members WHERE crowd_id=?", withArgumentsIn: [crowdId])
        sharedInstance.database!.close()
        return isDeleted
    }
    
    /****** CrowdData  ******/
    func addCrowdData(_ crowdInfo: PartyCrowdCellData) -> Bool {
        let int_invite_friends = crowdInfo.invite_friends ? 1 : 0 //Int(crowdInfo.invite_friends)
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO crowds (id, title, location, timestamp, time, invite_friends, status) VALUES (?, ?, ?, ?, ?, ?, ?)", withArgumentsIn: [crowdInfo.id, crowdInfo.title, crowdInfo.location, crowdInfo.partyTimeStamp, crowdInfo.partyTime, int_invite_friends, crowdInfo.status])

        sharedInstance.database!.close()
        return isInserted
    }
    func addCrowdData(_ crowdInfo: PartyCrowdCellData, owner_phoneNr: String, crowd_status: Int) -> Bool {
        let int_invite_friends = crowdInfo.invite_friends ? 1 : 0 //Int(crowdInfo.invite_friends)
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO crowds (id, title, location, timestamp, time, invite_friends, owner, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", withArgumentsIn: [crowdInfo.id, crowdInfo.title, crowdInfo.location, crowdInfo.partyTimeStamp, crowdInfo.partyTime, int_invite_friends, owner_phoneNr, crowd_status])
        
        sharedInstance.database!.close()
        return isInserted
    }
    
    func updateCrowdData(_ crowdInfo: PartyCrowdCellData, owner_phoneNr: String, crowd_status: Int) -> Bool {
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE crowds SET title=?, location=?, color=?, timestamp=?, time=?, invite_friends=?, owner=?, status=? WHERE id=?", withArgumentsIn: [crowdInfo.title, crowdInfo.location, crowdInfo.color, crowdInfo.partyTimeStamp, crowdInfo.partyTime, crowdInfo.invite_friends, owner_phoneNr, crowd_status, crowdInfo.id])
        sharedInstance.database!.close()
        return isUpdated
    }
    func updateCrowdData(_ crowdInfo: PartyCrowdCellData, crowd_status: Int) -> Bool {
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE crowds SET status=? WHERE id=?", withArgumentsIn: [crowd_status, crowdInfo.id])
        sharedInstance.database!.close()
        return isUpdated
    }
    func updateCrowdData(_ crowdInfo: PartyCrowdCellData) -> Bool {
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE crowds SET title=?, location=?, color=?, timestamp=?, time=?, invite_friends=? WHERE id=?", withArgumentsIn: [crowdInfo.title, crowdInfo.location, crowdInfo.color, crowdInfo.partyTimeStamp, crowdInfo.partyTime, crowdInfo.invite_friends, crowdInfo.id])
        sharedInstance.database!.close()
        return isUpdated
    }
    
    func deleteCrowdData(_ crowdInfo: PartyCrowdCellData) -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM crowds WHERE id=?", withArgumentsIn: [crowdInfo.id])
        sharedInstance.database!.close()
        if isDeleted == true {
            _ = self.deleteChatData(crowdInfo)
        }
        return isDeleted
    }
    func getCrowdUserStatus(_ id:String, phone_nr:String) -> Int{
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM crowds WHERE id=? AND owner=?", withArgumentsIn: [id, phone_nr])
        
        var crowdStatus = 10
        if (resultSet != nil) {
            while resultSet.next() {
               crowdStatus = Int(resultSet.int(forColumn: "status"))
            }
        }
        sharedInstance.database!.close()
        return crowdStatus
    }
    func getCrowd(_ id: String) -> PartyCrowdCellData {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM crowds WHERE id=?", withArgumentsIn: [id])
        var crowdInfo: PartyCrowdCellData = PartyCrowdCellData(id: "notExist", title: "", location: "", partyTimeStamp: 0, partyTime: "", invite_friends: false, color: 0, members: [], status:Constants.CROWD_STATUS_DO_NO_CHANGE_STATUS)
        if (resultSet != nil) {
            while resultSet.next() {
                
                let id = resultSet.string(forColumn: "id")!
                let title = resultSet.string(forColumn: "title")!
                let location = resultSet.string(forColumn: "location")!
                //                let color = Int(resultSet.int(forColumn: "color"))
                let partyTimeStamp = Int(resultSet.int(forColumn: "timestamp"))
                let partyTime = resultSet.string(forColumn: "time")!
                let invite_friends = Bool(resultSet.int(forColumn: "invite_friends") as NSNumber)
                let status = Int(resultSet.int(forColumn: "status"))
                let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM crowd_members WHERE crowd_id=?", withArgumentsIn: [id])
                var membersArray = [String]()
                if (resultSet != nil) {
                    while resultSet.next() {
                        let member = resultSet.string(forColumn: "member")!
                        membersArray.append(member)
                    }
                }
                
                crowdInfo = PartyCrowdCellData(id: id, title: title, location: location, partyTimeStamp: partyTimeStamp, partyTime: partyTime, invite_friends: invite_friends, color: 0, members: membersArray, status:status)
            }
        }
        sharedInstance.database!.close()
        return crowdInfo
    }
    func getAllCrowdsData() -> [PartyCrowdCellData] {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM crowds", withArgumentsIn: nil)
        var partyCrowdArray = [PartyCrowdCellData]()
        if (resultSet != nil) {
            while resultSet.next() {
                
                let id = resultSet.string(forColumn: "id")!
                let title = resultSet.string(forColumn: "title")!
                let location = resultSet.string(forColumn: "location")!
//                let color = Int(resultSet.int(forColumn: "color"))
                let partyTimeStamp = Int(resultSet.int(forColumn: "timestamp"))
                let partyTime = resultSet.string(forColumn: "time")!
                let invite_friends = Bool(resultSet.int(forColumn: "invite_friends") as NSNumber)
                let status = Int(resultSet.int(forColumn: "status"))
                
                let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM crowd_members WHERE crowd_id=?", withArgumentsIn: [id])
                var membersArray = [String]()
                if (resultSet != nil) {
                    while resultSet.next() {
                        let member = resultSet.string(forColumn: "member")!
                        membersArray.append(member)
                    }
                }
                
                let crowdInfo = PartyCrowdCellData(id: id, title: title, location: location, partyTimeStamp: partyTimeStamp, partyTime: partyTime, invite_friends: invite_friends, color: 0, members: membersArray, status:status)
                partyCrowdArray.append(crowdInfo)
            }
        }
        sharedInstance.database!.close()
        return partyCrowdArray
    }
    
    /****** Chat Message Data  ******/
    func addChatData(_ chatItem: PartyCrowdChatCellData) -> Bool {
        let int_is_msg = chatItem.is_img ? 1 : 0
        sharedInstance.database!.open()
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO crowd_messages (id, crowd_id, timestamp, sender, msg, img, delivered, time) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", withArgumentsIn: [chatItem.message_id, chatItem.crowdId, chatItem.time, chatItem.senderName, chatItem.msg, int_is_msg, chatItem.delivered, chatItem.time_string])
        
        sharedInstance.database!.close()
        return isInserted
    }
    
    func updateChatData(_ chatItem: PartyCrowdChatCellData) -> Bool {
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE crowd_messages SET delivered=?, timestamp=? WHERE id=?", withArgumentsIn: [chatItem.delivered, chatItem.time, chatItem.message_id])
        sharedInstance.database!.close()
        return isUpdated
    }
    
    func deleteChatData(_ selectedPartyCrowdItem:PartyCrowdCellData) -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM crowd_messages WHERE crowd_id=?", withArgumentsIn: [selectedPartyCrowdItem.id])
        sharedInstance.database!.close()
        return isDeleted
    }
    
    func getAllChatData(_ selectedPartyCrowdItem:PartyCrowdCellData) -> [PartyCrowdChatCellData] {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM crowd_messages WHERE crowd_id=?", withArgumentsIn: [selectedPartyCrowdItem.id])
        var crowdChatArray = [PartyCrowdChatCellData]()
        if (resultSet != nil) {
            while resultSet.next() {
                
                let id = Int(resultSet.int(forColumn: "id"))// .string(forColumn: "id")!
                let crowd_id = resultSet.string(forColumn: "crowd_id")!
                let timestamp = Int(resultSet.int(forColumn: "timestamp"))
                let sender = resultSet.string(forColumn: "sender")!
                let msg = resultSet.string(forColumn: "msg")!
                let delivered = Int(resultSet.int(forColumn: "delivered"))
                let is_img = Bool(resultSet.int(forColumn: "img") as NSNumber)
                let time = resultSet.string(forColumn: "time")!
                
                let addedChatItem = PartyCrowdChatCellData(message_id:id, crowdId: crowd_id, senderName: sender, msg: msg, is_img: is_img, time: timestamp, delivered: delivered, time_string: time)
                crowdChatArray.append(addedChatItem)
            }
        }
        sharedInstance.database!.close()
        return crowdChatArray
    }
    func getImageChatData(_ selectedPartyCrowdItem:PartyCrowdCellData) -> [PartyCrowdChatCellData] {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM crowd_messages WHERE crowd_id=? AND img=?", withArgumentsIn: [selectedPartyCrowdItem.id, 1])
        var crowdChatArray = [PartyCrowdChatCellData]()
        if (resultSet != nil) {
            while resultSet.next() {
                
                let id = Int(resultSet.int(forColumn: "id"))// .string(forColumn: "id")!
                let crowd_id = resultSet.string(forColumn: "crowd_id")!
                let timestamp = Int(resultSet.int(forColumn: "timestamp"))
                let sender = resultSet.string(forColumn: "sender")!
                let msg = resultSet.string(forColumn: "msg")!
                let delivered = Int(resultSet.int(forColumn: "delivered"))
                let is_img = Bool(resultSet.int(forColumn: "img") as NSNumber)
                let time = resultSet.string(forColumn: "time")!
                
                let addedChatItem = PartyCrowdChatCellData(message_id:id, crowdId: crowd_id, senderName: sender, msg: msg, is_img: is_img, time: timestamp, delivered: delivered, time_string: time)
                crowdChatArray.append(addedChatItem)
            }
        }
        sharedInstance.database!.close()
        return crowdChatArray
    }
}
