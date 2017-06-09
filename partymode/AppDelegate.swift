//
//  AppDelegate.swift
//  partymode
//
//  Created by Nikita on 1/12/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit
import UserNotifications
import Fabric
import DigitsKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import AudioToolbox
import CRToast
import Crashlytics
import Alamofire
import AlamofireImage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate  {
    //var root:UINavigationController!
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var temp_received_notification_info : [AnyHashable: Any]!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        UINavigationBar.appearance().isTranslucent = false
        UserDefaults.standard.set("", forKey: "currentScreen")
        UserDefaults.standard.set("", forKey: "currentChatScreen_CrowdId")
        UserDefaults.standard.set("false", forKey: "shouldBeReactivate")
        UserDefaults.standard.set("false", forKey: "appIsInBackground")
        DBUtil.copyFile("partymode.sqlite")
        
        Fabric.with([Digits.self, Crashlytics.self])
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        /* Customizing Back button  */
        
        UINavigationBar.appearance().tintColor = UIColor.black
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60.0), for: .default)
        
        
        
        FIRApp.configure()
        
        if #available(iOS 10.0, *) {
            let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        
        PingAPICall().request()
        _ = DBManager.getInstance().deleteAllImageCacheData()
        //After tapping received notification
        // Check if launched from notification
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            print(notification)
            let temp_received_notification_info = notification//notification["aps"] as! [String: AnyObject]
            //let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeviewcontroller = HomeViewController()
            
            
            //let root =
            let root = self.window?.rootViewController as! UINavigationController
            
            if temp_received_notification_info != nil {
                if temp_received_notification_info["phone_nr"] != nil {
                    //let topviewcontroller = UIApplication.topViewController()
                    //let root = UINavigationController(rootViewController: topviewcontroller!)
                    let root = self.window?.rootViewController as! UINavigationController
                    var rcvd_action:String!
                    var rcvd_phone_nr:String!
                    //let userInfo = remoteMessage.appData
                    if let action = temp_received_notification_info["action"] {
                        print("action: \(action)")
                        rcvd_action = action as! String
                    }
                    if let phone_nr = temp_received_notification_info["phone_nr"] {
                        print("phone_nr: \(phone_nr)")
                        rcvd_phone_nr = phone_nr as! String
                    }
                    if let pushid = temp_received_notification_info["gcm.notification.pushid"] {
                        print("pushid: \(pushid)")
                        let pushNotification_id = pushid as! String
                        ConfirmPushAPICall().request(pushNotification_id)
                    }
                    //var contactItem: PartyPeopleCellData!
                    if rcvd_phone_nr != nil {
                        //contactItem = DBManager.getInstance().getUser(rcvd_phone_nr)
                    }
                    else {
                        if let phone_nr = temp_received_notification_info["owner"] {
                            print("phone_nr: \(phone_nr)")
                            rcvd_phone_nr = phone_nr as! String
                            //contactItem = DBManager.getInstance().getUser(rcvd_phone_nr)
                        }
                    }
                    
                    UserDefaults.standard.set("NO", forKey: "isFromPartyHistory")
                    
                    switch rcvd_action {
                    case "set_pmode":
                        let when = DispatchTime.now() + 1.5
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_gotoPartyPeopleTab"), object: nil)
                        }
                        
                        break
                    case "partify":
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_gotoPartyPeopleTab"), object: nil)
                        break
                    case "create_crowd":
                        let id = temp_received_notification_info["id"] as! String
                        let title = temp_received_notification_info["title"] as! String
                        let location = temp_received_notification_info["location"] as! String
                        let invite_friends_str = temp_received_notification_info["invite_friends"] as! String
                        let invite_friends:Bool!
                        if (invite_friends_str == "true") {
                            invite_friends = true;
                        } else {
                            invite_friends = false;
                        }
                        
                        let time_str = temp_received_notification_info["time"] as! String
                        var time = 0;
                        var color = 0;
                        time = Int(time_str)!
                        if let color_str = temp_received_notification_info["color"] as? String {
                            color = Int(color_str)!
                        }
                        
                        // Get old crowd
                        let crowdItemOld: PartyCrowdCellData = DBManager.getInstance().getCrowd(id)
                        
                        
                        let time_str_date = TimeStampClass().convertFromTimestamp(seconds: time)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"//"yyyy/MM/dd HH:mm"
                        let dateStr = dateFormatter.string(from: time_str_date)
                        
                        let crowdInfo = PartyCrowdCellData(id: id, title: title, location: location, partyTimeStamp: time, partyTime: dateStr, invite_friends: invite_friends, color: color, members: [], status: Constants.CROWD_STATUS_PENDING)
                        
                        if crowdItemOld.id == "notExist"{//add
                            let isInserted = DBManager.getInstance().addCrowdData(crowdInfo, owner_phoneNr: rcvd_phone_nr, crowd_status: Constants.CROWD_STATUS_PENDING)
                        }
                        else {//update
                            let isUpdated = DBManager.getInstance().updateCrowdData(crowdInfo, owner_phoneNr: rcvd_phone_nr, crowd_status: crowdItemOld.status)
                            let isDeleted = DBManager.getInstance().DeleteCrowdMembers(id)
                        }
                        
                        // Crowd members
                        var members_pending_array = [String]()
                        var members_accepted_array = [String]()
                        var members_declined_array = [String]()
                        if let members = temp_received_notification_info["pending"] as? String {
                            print(members)
                            if members != "[]" {
                                members_pending_array = convertToArrayOfString(members)
                            }
                        }
                        if let members = temp_received_notification_info["accepted"] as? String {
                            print(members)
                            if members != "[]" {
                                members_accepted_array = convertToArrayOfString(members)
                            }
                            
                        }
                        if let members = temp_received_notification_info["declined"] as? String {
                            print(members)
                            if members != "[]" {
                                members_declined_array = convertToArrayOfString(members)
                            }
                            
                        }
                        
                        //members_accepted_array.append(rcvd_phone_nr)//Also insert the owner!
                        
                        _ = DBManager.getInstance().addCrowdMembers(members_pending_array, crowdId: id, status:Constants.CROWD_STATUS_PENDING)
                        _ = DBManager.getInstance().addCrowdMembers(members_accepted_array, crowdId: id, status:Constants.CROWD_STATUS_ACCEPTED)
                        _ = DBManager.getInstance().addCrowdMembers(members_declined_array, crowdId: id, status:Constants.CROWD_STATUS_DECLINED)
                        
                            //let id = temp_received_notification_info["id"] as! String
                            // Get crowd by id From DB
                            let crowdItem: PartyCrowdCellData = DBManager.getInstance().getCrowd(id)
                            let stb = UIStoryboard(name: "Main", bundle: nil)
                            let viewController =  stb.instantiateViewController(withIdentifier: "CreatePartyCrowdViewController") as! CreatePartyCrowdViewController
                            viewController.temp_createdPartyCrowdItem = crowdItem
                            viewController.shouldGoForward = true
                            //viewController.shouldGoToEdit = true
                            GlobalData.sharedInstance.setSelectedPartyCrowdItem(crowdItem)
                            let when = DispatchTime.now() + 1
                            DispatchQueue.main.asyncAfter(deadline: when) {
                                UserDefaults.standard.set("false", forKey: "shouldgotoPartypeopleTab")
                                root.pushViewController(viewController, animated: true)
                            }
                        
                        break
                    case "dec_crowd":
                        
                            let id = temp_received_notification_info["id"] as! String
                            // Get crowd by id From DB
                            let crowdItem: PartyCrowdCellData = DBManager.getInstance().getCrowd(id)
                            let stb = UIStoryboard(name: "Main", bundle: nil)
                            let viewController =  stb.instantiateViewController(withIdentifier: "CreatePartyCrowdViewController") as! CreatePartyCrowdViewController
                            viewController.temp_createdPartyCrowdItem = crowdItem
                            viewController.shouldGoForward = true
                            //viewController.shouldGoToEdit = true
                            GlobalData.sharedInstance.setSelectedPartyCrowdItem(crowdItem)
                            let when = DispatchTime.now() + 1
                            DispatchQueue.main.asyncAfter(deadline: when) {
                                UserDefaults.standard.set("false", forKey: "shouldgotoPartypeopleTab")
                                root.pushViewController(viewController, animated: true)
                            }
                          
                        break
                    case "send_msg":
                        
                        let id = temp_received_notification_info["id"] as! String
                        let msg = temp_received_notification_info["msg"] as! String
                        let is_img_str = temp_received_notification_info["isimg"] as! String
                        var is_img = false
                        if is_img_str == "true" {
                            is_img = true
                            let image_full_url = Constants.API_LINK + Constants.API_IMAGES + msg
                            Alamofire.request(image_full_url).responseImage { response in
                                
                                if let receivedImage = response.result.value {
                                    self.saveImageToGallary(receivedImage: receivedImage, filename: msg)
                                }
                            }
                        }
                        else {
                            is_img = false
                        }
                        
                        let time = Int(temp_received_notification_info["msgtime"] as! String)
                        var delivered = Constants.CROWD_MSG_DELIVERED_NOT
                        if (is_img) {
                            delivered = Constants.CROWD_MSG_IMG_NOT_DOWNLOADED;
                        } else {
                            delivered = Constants.CROWD_MSG_DELIVERED_SUCCESS;
                        }
                        
                        let dateFormatter1 = DateFormatter()
                        dateFormatter1.dateFormat = "dd.MM.yyyy HH:mm"//"yyyy/MM/dd HH:mm"
                        let time_str_date = TimeStampClass().convertFromTimestamp(seconds: time!)
                        let current_date_string = dateFormatter1.string(from: time_str_date)
                        
                        //let sent_timestamp = Int(TimeStampClass().convertToTimestamp(date: current_date))!
                        
                        let newMsg = PartyCrowdChatCellData(message_id: time!, crowdId: id, senderName: rcvd_phone_nr!, msg: msg, is_img: is_img, time: time!, delivered: delivered, time_string: current_date_string)
                        
                        
                        let isInserted = DBManager.getInstance().addChatData(newMsg)
                        if isInserted {
                            print("new chat item inserted to db successfully")
                        } else {
                            print("new chat insert failed")
                        }
                        
                            //let id = temp_received_notification_info["id"] as! String
                            // Get crowd by id From DB
                            let crowdItem: PartyCrowdCellData = DBManager.getInstance().getCrowd(id)
                            let stb = UIStoryboard(name: "Main", bundle: nil)
                            let viewController =  stb.instantiateViewController(withIdentifier: "CreatePartyCrowdViewController") as! CreatePartyCrowdViewController
                            viewController.temp_createdPartyCrowdItem = crowdItem
                            viewController.shouldGoForward = true
                            GlobalData.sharedInstance.setSelectedPartyCrowdItem(crowdItem)
                            
                        
                            let when = DispatchTime.now() + 1
                            DispatchQueue.main.asyncAfter(deadline: when) {
                                UserDefaults.standard.set("false", forKey: "shouldgotoPartypeopleTab")
                                root.pushViewController(viewController, animated: true)
                            }
                        break
                    case "campaign":
                        break
                    default:
                        break
                        
                    }
                }
                else {
                    
                }
                
            }
            
        }

        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo)
        temp_received_notification_info = userInfo
        self.processOfReceivedNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.noData)
        
        
        //FIRMessaging.messaging().appDidReceiveMessage(userInfo)
    }
    func processOfReceivedNotification(_ userInfo: [AnyHashable: Any]){
        var rcvd_action:String!
        var rcvd_phone_nr:String!
        var pushNotification_id:String!
        //let userInfo = remoteMessage.appData
        if let action = userInfo["action"] {
            print("action: \(action)")
            rcvd_action = action as! String
            
            if let phone_nr = userInfo["phone_nr"] {
                print("phone_nr: \(phone_nr)")
                rcvd_phone_nr = phone_nr as! String
            }
            
            
            
            if let pushid = userInfo["gcm.notification.pushid"] {
                print("pushid: \(pushid)")
                pushNotification_id = pushid as! String
                ConfirmPushAPICall().request(pushNotification_id)
            }
            var contactItem: PartyPeopleCellData!
            if rcvd_phone_nr != nil {
                contactItem = DBManager.getInstance().getUser(rcvd_phone_nr)
            }
            else {
                if let phone_nr = userInfo["owner"] {
                    print("phone_nr: \(phone_nr)")
                    rcvd_phone_nr = phone_nr as! String
                    contactItem = DBManager.getInstance().getUser(rcvd_phone_nr)
                }
            }
            
            if contactItem != nil {
                
            }
            if (contactItem.user_state == Constants.STATE_BLOCKED) { return; }
            
            
            
            switch rcvd_action {
            case "set_pmode":
                
                if (contactItem.user_state == Constants.STATE_CONTACT) {
                    _ = DBManager.getInstance().setUserState(rcvd_phone_nr, status: Constants.STATE_PM_USER)
                    _ = DBManager.getInstance().setNotificationInfo(rcvd_phone_nr, status: Constants.NOTIFICATION_TRUE)
                }
                var partymode = 0;
                var partymode_time = 0;
                let partymode_s = userInfo["pmode"] as! String
                let partymode_time_s = userInfo["pmode_time"] as! String
                
                partymode = Int(partymode_s)!
                partymode_time = Int(partymode_time_s)!
                
                _ = DBManager.getInstance().updatePmodeCacheData(rcvd_phone_nr, pmode_time: partymode_time, pmode: partymode)
                
                var temp_partypeopleArray = GlobalData.sharedInstance.getPartyPeopleArray()
                var index = 0
                var wasPartypeople = false
                let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
                queue.sync{
                    print("First Block")
                    for each in temp_partypeopleArray {
                        if each.phonenumber == rcvd_phone_nr {
                            var itemToModify = each
                            
                            itemToModify.pmode = partymode
                            itemToModify.pmode_time = partymode_time
                            _ = DBManager.getInstance().updatePmodeMemberData(itemToModify)
                            
                            
                            GlobalData.sharedInstance.updatePartyPeopleArray(index: index, newArray: itemToModify)
                            GlobalData.sharedInstance.sortPartyPeopleArray()
                            
                            wasPartypeople = true
                        }
                        index = index + 1
                    }
                }
                
                print("Second Block")
                if wasPartypeople == false {
                    contactItem.pmode = partymode
                    GlobalData.partypeopleArray.append(contactItem)
                    GlobalData.sharedInstance.removeItemFromUnduplicatedArray(contactItem)
                    GlobalData.sharedInstance.sortPartyPeopleArray()
                    
                }
                GlobalData.sharedInstance.loadImageOfPartyperson(rcvd_phone_nr, pmode:partymode)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_refreshContacts"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_receivedPmodePush"), object: nil)
                
                
                
                // Partymode timed out?
                if ((partymode == Constants.PARTYMODE_OFF && partymode_time + Constants.PARTYMODEOFF_DURATION < Int(NSDate().timeIntervalSince1970)) ||
                    partymode == Constants.PARTYMODE_ON && partymode_time + Constants.PARTYMODEON_DURATION < Int(NSDate().timeIntervalSince1970)) {
                    return;
                }
                // Update database
                
                _ = DBManager.getInstance().setUserPmode(rcvd_phone_nr, pmode: partymode)
                _ = DBManager.getInstance().setUserPmodeTime(rcvd_phone_nr, pmode_time: partymode_time)
                
                let notification_status = DBManager.getInstance().getNotificationInfo(rcvd_phone_nr)
                if (notification_status == Constants.NOTIFICATION_TRUE) {
                    // If partymode is set to ON
                    if (partymode == Constants.PARTYMODE_ON) {
                        // Get user's name
                        let name = contactItem.name
                        
                        //                    showToastOnStatusBar("\(name) \(NSLocalizedString("notification_title_partymodeon", comment: ""))  \(NSLocalizedString("notification_body_partymodeon", comment: ""))")
                        
                        //playPushSound()
                        notify("\(name) \(NSLocalizedString("notification_title_partymodeon", comment: ""))", body: NSLocalizedString("notification_body_partymodeon", comment: ""), img: contactItem.face_image)
                        
                    }
                }
                
                break
            case "partify":
                
                if (contactItem.user_state == Constants.STATE_CONTACT) {
                    _ = DBManager.getInstance().setUserState(rcvd_phone_nr, status: Constants.STATE_PM_USER)
                    _ = DBManager.getInstance().setNotificationInfo(rcvd_phone_nr, status: Constants.NOTIFICATION_TRUE)
                }
                let timestamp_s = userInfo["timestamp"] as! String
                
                let timestamp = Int(timestamp_s)!
                
                // Partify timed out?
                if (timestamp + Constants.PARTIFY_TIMEOUT < Int(NSDate().timeIntervalSince1970)) {
                    return;
                }
                
                let notification_status = DBManager.getInstance().getNotificationInfo(rcvd_phone_nr)
                if (notification_status == Constants.NOTIFICATION_TRUE) {
                    // Get user's name
                    let name = contactItem.name
                    //                showToastOnStatusBar("\(name) \(NSLocalizedString("notification_title_partify", comment: ""))  \(NSLocalizedString("notification_body_partify", comment: ""))")
                    //playPushSound()
                    notify("\(name) \(NSLocalizedString("notification_title_partify", comment: ""))", body: NSLocalizedString("notification_body_partify", comment: ""), img: contactItem.face_image)
                }
                break
            case "create_crowd":
                let id = userInfo["id"] as! String
                let title = userInfo["title"] as! String
                let location = userInfo["location"] as! String
                let invite_friends_str = userInfo["invite_friends"] as! String
                let invite_friends:Bool!
                if (invite_friends_str == "true") {
                    invite_friends = true;
                } else {
                    invite_friends = false;
                }
                
                let time_str = userInfo["time"] as! String
                var time = 0;
                var color = 0;
                time = Int(time_str)!
                if let color_str = userInfo["color"] as? String {
                    color = Int(color_str)!
                }
                
                
                // Get old crowd
                let crowdItemOld: PartyCrowdCellData = DBManager.getInstance().getCrowd(id)
                
                
                let time_str_date = TimeStampClass().convertFromTimestamp(seconds: time)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"//"yyyy/MM/dd HH:mm"
                let dateStr = dateFormatter.string(from: time_str_date)
                
                let crowdInfo = PartyCrowdCellData(id: id, title: title, location: location, partyTimeStamp: time, partyTime: dateStr, invite_friends: invite_friends, color: color, members: [], status: Constants.CROWD_STATUS_PENDING)
                
                if crowdItemOld.id == "notExist"{//add
                    let isInserted = DBManager.getInstance().addCrowdData(crowdInfo, owner_phoneNr: rcvd_phone_nr, crowd_status: Constants.CROWD_STATUS_PENDING)
                }
                else {//update
                    let isUpdated = DBManager.getInstance().updateCrowdData(crowdInfo, owner_phoneNr: rcvd_phone_nr, crowd_status: crowdItemOld.status)
                    let isDeleted = DBManager.getInstance().DeleteCrowdMembers(id)
                }
                
                // Crowd members
                var members_pending_array = [String]()
                var members_accepted_array = [String]()
                var members_declined_array = [String]()
                if let members = userInfo["pending"] as? String {
                    print(members)
                    if members != "[]" {
                        members_pending_array = convertToArrayOfString(members)
                    }
                }
                if let members = userInfo["accepted"] as? String {
                    print(members)
                    if members != "[]" {
                        members_accepted_array = convertToArrayOfString(members)
                    }
                    
                }
                if let members = userInfo["declined"] as? String {
                    print(members)
                    if members != "[]" {
                        members_declined_array = convertToArrayOfString(members)
                    }
                    
                }
                
                //members_accepted_array.append(rcvd_phone_nr)//Also insert the owner!
                
                _ = DBManager.getInstance().addCrowdMembers(members_pending_array, crowdId: id, status:Constants.CROWD_STATUS_PENDING)
                _ = DBManager.getInstance().addCrowdMembers(members_accepted_array, crowdId: id, status:Constants.CROWD_STATUS_ACCEPTED)
                _ = DBManager.getInstance().addCrowdMembers(members_declined_array, crowdId: id, status:Constants.CROWD_STATUS_DECLINED)
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_reloadTab3Screen"), object: nil)
                //            Intent intent = new Intent(this, ActivityCrowd.class);
                //            intent.putExtra(ActivityCrowd.CROWD_ID, id);
                if (crowdItemOld.id != "notExist") {
                    // Notification time
                    if (crowdItemOld.partyTimeStamp != time) {
                        let body = String(format: NSLocalizedString("notification_body_postponed_crowd", comment: ""), contactItem.name)
                        notify(title, body: body, img: contactItem.face_image)
                        
                    }
                    // Notification title
                    if (crowdItemOld.title != title) {
                        let body = String(format: NSLocalizedString("notification_body_crowd_title", comment: ""), crowdItemOld.title, title)
                        notify(title, body: body, img: contactItem.face_image)
                        
                    }
                    // Notification location
                    if (crowdItemOld.location != location) {
                        let body = String(format: NSLocalizedString("notification_body_crowd_location", comment: ""), location)
                        notify(title, body: body, img: contactItem.face_image)
                    }
                } else {
                    let body = String(format: NSLocalizedString("notification_body_create_crowd", comment: ""), contactItem.name)
                    notify(title, body: body, img: contactItem.face_image)
                }
                break
            case "dec_crowd":
                let id = userInfo["id"] as! String
                
                let status_str = userInfo["status"] as! String
                let timestamp_s = userInfo["timestamp"] as! String
                let timestamp = Int(timestamp_s)!
                var status = 0;
                status = Int(status_str)!
                let myPhoneNr = UserDefaults.standard.string(forKey: "phone_nr")
                // Get own status
                let own_status = DBManager.getInstance().getCrowdUserStatus(id, phone_nr: myPhoneNr!)
                // Get previous status
                let prev_status = DBManager.getInstance().getCrowdUserStatus(id, phone_nr: rcvd_phone_nr!)
                
                // Update database
                //            let newMemberArray = [rcvd_phone_nr]
                //            _ = DBManager.getInstance().addCrowdMembers(newMemberArray as! [String], crowdId: id, status:status)
                
                // Notification
                let notification_status = DBManager.getInstance().getNotificationInfo(rcvd_phone_nr)
                if (notification_status == Constants.NOTIFICATION_TRUE) {
                    var body = "";
                    let dateFormatter1 = DateFormatter()
                    dateFormatter1.dateFormat = "dd.MM.yyyy HH:mm"//"yyyy/MM/dd HH:mm"
                    let time_str_date = TimeStampClass().convertFromTimestamp(seconds: timestamp)
                    let current_date_string = dateFormatter1.string(from: time_str_date)
                    //let sent_timestamp = Int(TimeStampClass().convertToTimestamp(date: current_date))!
                    
                    switch (status) {
                    case Constants.CROWD_STATUS_ACCEPTED:
                        //if (prev_status != Constants.CROWD_STATUS_ACCEPTED) {
                        //    if (own_status != Constants.CROWD_STATUS_DECLINED) {
                        body = "\(contactItem.name) \(NSLocalizedString("enteredchat", comment: ""))"
                        
                        let isUpdated = DBManager.getInstance().updateCrowdMemberData(id, phoneNr: rcvd_phone_nr!, crowd_status: Constants.CROWD_STATUS_ACCEPTED, msg: "")
                        
                        let newMsg = PartyCrowdChatCellData(message_id: timestamp, crowdId: id, senderName: myPhoneNr!, msg: body, is_img: false, time: timestamp, delivered: Constants.CROWD_MSG_DELIVERED_SYSTEM, time_string: current_date_string)
                        
                        let isInserted = DBManager.getInstance().addChatData(newMsg)
                        if isInserted {
                            print("new chat item inserted to db successfully")
                        } else {
                            print("new chat insert failed")
                        }
                        
                        //    }
                        // }
                        
                        break;
                    case Constants.CROWD_STATUS_DECLINED:
                        // if (prev_status == Constants.CROWD_STATUS_ACCEPTED) {
                        //     if (own_status != Constants.CROWD_STATUS_DECLINED) {
                        body = "\(contactItem.name) \(NSLocalizedString("leftchat", comment: ""))"
                        
                        let isUpdated = DBManager.getInstance().updateCrowdMemberData(id, phoneNr: rcvd_phone_nr!, crowd_status: Constants.CROWD_STATUS_DECLINED, msg: "")
                        
                        let newMsg = PartyCrowdChatCellData(message_id: timestamp, crowdId: id, senderName: myPhoneNr!, msg: body, is_img: false, time: timestamp, delivered: Constants.CROWD_MSG_DELIVERED_SYSTEM, time_string: current_date_string)
                        
                        let isInserted = DBManager.getInstance().addChatData(newMsg)
                        if isInserted {
                            print("new chat item inserted to db successfully")
                        } else {
                            print("new chat insert failed")
                        }
                        
                        
                        break;
                    default:
                        return;
                    }
                    var title = ""
                    let crowdData = DBManager.getInstance().getCrowd(id)
                    if (crowdData.title == "notExist" || crowdData.title == "") {
                        title = "Partycrowd";
                    }
                    notify(title, body: body, img: contactItem.face_image)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_reloadTab3Screen"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_reloadMembersData"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_reloadChatData"), object: nil)
                }
                break
            case "send_msg":
                let id = userInfo["id"] as! String
                let msg = userInfo["msg"] as! String
                let is_img_str = userInfo["isimg"] as! String
                var is_img = false
                if is_img_str == "true" {
                    is_img = true
                    let image_full_url = Constants.API_LINK + Constants.API_IMAGES + msg
                    Alamofire.request(image_full_url).responseImage { response in
                        
                        if let receivedImage = response.result.value {
                            self.saveImageToGallary(receivedImage: receivedImage, filename: msg)
                        }
                    }
                }
                else {
                    is_img = false
                }
                
                let time = Int(userInfo["msgtime"] as! String)
                var delivered = Constants.CROWD_MSG_DELIVERED_NOT
                if (is_img) {
                    delivered = Constants.CROWD_MSG_IMG_NOT_DOWNLOADED;
                } else {
                    delivered = Constants.CROWD_MSG_DELIVERED_SUCCESS;
                }
                
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateFormat = "dd.MM.yyyy HH:mm"//"yyyy/MM/dd HH:mm"
                let time_str_date = TimeStampClass().convertFromTimestamp(seconds: time!)
                let current_date_string = dateFormatter1.string(from: time_str_date)
                
                //let sent_timestamp = Int(TimeStampClass().convertToTimestamp(date: current_date))!
                
                let newMsg = PartyCrowdChatCellData(message_id: time!, crowdId: id, senderName: rcvd_phone_nr!, msg: msg, is_img: is_img, time: time!, delivered: delivered, time_string: current_date_string)
                
                
                let isInserted = DBManager.getInstance().addChatData(newMsg)
                if isInserted {
                    print("new chat item inserted to db successfully")
                } else {
                    print("new chat insert failed")
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_reloadChatData"), object: nil)
                
                var title = ""
                let crowdData = DBManager.getInstance().getCrowd(id)
                if (crowdData.title == "notExist" || crowdData.title == "") {
                    title = "Partycrowd";
                }
                else {
                    title = crowdData.title
                }
                
                // Count unread messages
                
                var unreadMessages: Int = 0
                
                if UserDefaults.standard.integer(forKey: Constants.SP_NOTIFICATION_UNREAD_MSG_COUNT) > 0 {
                    unreadMessages = UserDefaults.standard.integer(forKey: Constants.SP_NOTIFICATION_UNREAD_MSG_COUNT)
                    unreadMessages = unreadMessages + 1
                    UserDefaults.standard.set(unreadMessages, forKey: Constants.SP_NOTIFICATION_UNREAD_MSG_COUNT)
                }
                else {
                    unreadMessages = unreadMessages + 1
                    UserDefaults.standard.set(unreadMessages, forKey: Constants.SP_NOTIFICATION_UNREAD_MSG_COUNT)
                }
                
                var body = ""
                if (unreadMessages == 1) {
                    body = NSLocalizedString("notification_body_one_msg", comment: "")
                } else {
                    body = String(format: NSLocalizedString("notification_body_msg", comment: ""), unreadMessages)
                }
                
                let currentChatScreen_CrowdId = UserDefaults.standard.string(forKey: "currentChatScreen_CrowdId")
                let appIsInBackground = UserDefaults.standard.string(forKey: "appIsInBackground")
                
                if currentChatScreen_CrowdId != id{
                    notify(title, body: body, img: contactItem.face_image)
                }
                else {
                    if appIsInBackground == "true" {
                        notify(title, body: body, img: contactItem.face_image)
                    }
                }
                
                
                // Notify list view to update - after notification, or it cannot be cancelled!
                
                
                break
            case "show_notification":
                let notif_title = userInfo["title"] as! String
                let notif_body = userInfo["body"] as! String
                
                //            showToastOnStatusBar("\(notif_title) \(notif_body))")
                //            playPushSound()
                notify(notif_title, body: notif_body)
                
                break
            case "campaign":
                break
            default:
                break
            }
        }
        else {
            print("Push notifications when app was in status of force closed")
        }
        
        
    }
    func saveImageToGallary(receivedImage:UIImage, filename:String){
        let image = self.resizeImage(receivedImage, newWidth: 150)
        let base64Str = Base64Util().convertToBase64 (image)
        _ = DBManager.getInstance().addImageCacheData(filename, imageData: base64Str)
        SaveLoadImageToLocalClass().saveImageToGallery(image: receivedImage, imageNameWithExt: filename)
        
    }
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func notify(_ title:String, body:String, img:UIImage){
        // Deliver the notification in 0.1 seconds.
        let content = UNMutableNotificationContent()
        content.title = title
        //content.subtitle = "Lets code,Talk is cheap"
        content.body = body
        content.sound = UNNotificationSound.default()
        
        //To Present image in notification
        if let attachment = UNNotificationAttachment.create(identifier: "pushAttachImage", image: img, options: nil) {
            // where myImage is any UIImage that follows the
            content.attachments = [attachment]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier:"partymode_notify", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request){(error) in
            
            if (error != nil){
                
                print(error?.localizedDescription)
            }
        }
    }
    func notify(_ title:String, body:String){
        // Deliver the notification in 0.1 seconds.
        let content = UNMutableNotificationContent()
        content.title = title
        //content.subtitle = "Lets code,Talk is cheap"
        content.body = body
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier:"partymode_notify", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request){(error) in
            
            if (error != nil){
                
                print(error?.localizedDescription)
            }
        }
    }
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            UserDefaults.standard.set(refreshedToken, forKey: "gcm_device_token")
            
        }
        
        connectToFcm()
    }
    func connectToFcm() {
        
        guard FIRInstanceID.instanceID().token() != nil else {
            return;
        }
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    func playPushSound(){
        let allowVibration = UserDefaults.standard.bool(forKey: "vibrate")
        if allowVibration {
            //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            AudioServicesPlaySystemSound(1054)
        }
    }
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        UNUserNotificationCenter.current().delegate = self
        print(remoteMessage.appData)
        self.processOfReceivedNotification(remoteMessage.appData)

    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        FIRInstanceID.instanceID().setAPNSToken(deviceToken as Data, type:FIRInstanceIDAPNSTokenType.sandbox)
        //FIRInstanceID.instanceID().setAPNSToken(deviceToken, type:FIRInstanceIDAPNSTokenType.Prod)
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFcm()
        UserDefaults.standard.set("false", forKey: "appIsInBackground")
        
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        UserDefaults.standard.set("true", forKey: "appIsInBackground")
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
        
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        UserDefaults.standard.set("false", forKey: "appIsInBackground")
        /*
        let defaults = UserDefaults.standard
        let sid = defaults.string(forKey: "sid")
        let uid = defaults.string(forKey: "uid")
        if sid != nil && uid != nil{
            let rootViewController = self.window!.rootViewController
            DispatchQueue.main.async(execute: {
                //GlobalData.sharedInstance.startLoadingData(sender:rootViewController!)
                let topviewcontroller = UIApplication.topViewController()
                //let root = UINavigationController(rootViewController: topviewcontroller!)
                GlobalData.sharedInstance.startLoadingIfNewContactAddedOrDeleted(topviewcontroller!)
                
            })
            
        }
        */
    }
    
    func showToastOnStatusBar(_ string:String){
        let options:[NSObject:AnyObject]  = [
//            kCRToastNotificationPresentationTypeKey as NSObject : 1 as AnyObject,
            kCRToastTextKey as NSObject : string as AnyObject,
            kCRToastBackgroundColorKey as NSObject : UIColor.orange,
            kCRToastTextColorKey as NSObject: UIColor.white,
            kCRToastFontKey as NSObject: UIFont(name:"HelveticaNeue", size: 11)!,
            kCRToastTextMaxNumberOfLinesKey as NSObject: 1 as AnyObject,
            kCRToastTimeIntervalKey as NSObject: NSNumber(value: 6) as AnyObject,
            kCRToastUnderStatusBarKey as NSObject : NSNumber(value: false),
            kCRToastImageAlignmentKey as NSObject : NSNumber(value: NSTextAlignment.left.rawValue) as AnyObject,
            kCRToastTextAlignmentKey as NSObject : NSNumber(value: NSTextAlignment.center.rawValue) as AnyObject,
            //kCRToastImageKey as NSObject : UIImage(named: "alert_icon")!,
            kCRToastNotificationTypeKey as NSObject : NSNumber(value: CRToastType.statusBar.rawValue) as AnyObject,
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
    
    //local push deletgate method
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {//called when user taps received push notification.
        //print(temp_received_notification_info)
        print("Tapped in notification")
        if temp_received_notification_info != nil {
            if temp_received_notification_info["phone_nr"] != nil {
                //let topviewcontroller = UIApplication.topViewController()
                //let root = UINavigationController(rootViewController: topviewcontroller!)
                let root = self.window?.rootViewController as! UINavigationController
                var rcvd_action:String!
                var rcvd_phone_nr:String!
                //let userInfo = remoteMessage.appData
                if let action = temp_received_notification_info["action"] {
                    print("action: \(action)")
                    rcvd_action = action as! String
                }
                if let phone_nr = temp_received_notification_info["phone_nr"] {
                    print("phone_nr: \(phone_nr)")
                    rcvd_phone_nr = phone_nr as! String
                }
                //var contactItem: PartyPeopleCellData!
                if rcvd_phone_nr != nil {
                    //contactItem = DBManager.getInstance().getUser(rcvd_phone_nr)
                }
                else {
                    if let phone_nr = temp_received_notification_info["owner"] {
                        print("phone_nr: \(phone_nr)")
                        rcvd_phone_nr = phone_nr as! String
                        //contactItem = DBManager.getInstance().getUser(rcvd_phone_nr)
                    }
                }
                
                //UserDefaults.standard.set("NO", forKey: "isFromPartyHistory")
                
                switch rcvd_action {
                case "set_pmode":
                    //let shouldgotoPartypeopleTab = UserDefaults.standard.string(forKey: "shouldgotoPartypeopleTab")
                    //if shouldgotoPartypeopleTab == "true" {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_gotoPartyPeopleTab"), object: nil)
                    //}
                    break
                case "partify":
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_gotoPartyPeopleTab"), object: nil)
                    break
                case "create_crowd":
                    let currentScreen = UserDefaults.standard.string(forKey: "currentScreen")
                    if currentScreen != "crowdchat"{
                        let id = temp_received_notification_info["id"] as! String
                        // Get crowd by id From DB
                        let crowdItem: PartyCrowdCellData = DBManager.getInstance().getCrowd(id)
                        let stb = UIStoryboard(name: "Main", bundle: nil)
                        let viewController =  stb.instantiateViewController(withIdentifier: "CreatePartyCrowdViewController") as! CreatePartyCrowdViewController
                        viewController.temp_createdPartyCrowdItem = crowdItem
                        viewController.shouldGoForward = true
                        //viewController.shouldGoToEdit = true
                        GlobalData.sharedInstance.setSelectedPartyCrowdItem(crowdItem)
                        UserDefaults.standard.set("false", forKey: "shouldgotoPartypeopleTab")
                        root.pushViewController(viewController, animated: false)
                    }
                    break
                case "dec_crowd":
                    let currentScreen = UserDefaults.standard.string(forKey: "currentScreen")
                    if currentScreen != "crowdchat"{
                        let id = temp_received_notification_info["id"] as! String
                        // Get crowd by id From DB
                        let crowdItem: PartyCrowdCellData = DBManager.getInstance().getCrowd(id)
                        let stb = UIStoryboard(name: "Main", bundle: nil)
                        let viewController =  stb.instantiateViewController(withIdentifier: "CreatePartyCrowdViewController") as! CreatePartyCrowdViewController
                        viewController.temp_createdPartyCrowdItem = crowdItem
                        viewController.shouldGoForward = true
                        //viewController.shouldGoToEdit = true
                        GlobalData.sharedInstance.setSelectedPartyCrowdItem(crowdItem)
                        UserDefaults.standard.set("false", forKey: "shouldgotoPartypeopleTab")
                        root.pushViewController(viewController, animated: false)
                    }
                    break
                case "send_msg":
                    let currentScreen = UserDefaults.standard.string(forKey: "currentChatScreen_CrowdId")
                    let id = temp_received_notification_info["id"] as! String
                    if currentScreen != id{
                        let id = temp_received_notification_info["id"] as! String
                        // Get crowd by id From DB
                        let crowdItem: PartyCrowdCellData = DBManager.getInstance().getCrowd(id)
                        let stb = UIStoryboard(name: "Main", bundle: nil)
                        let viewController =  stb.instantiateViewController(withIdentifier: "CreatePartyCrowdViewController") as! CreatePartyCrowdViewController
                        viewController.temp_createdPartyCrowdItem = crowdItem
                        viewController.shouldGoForward = true
                        GlobalData.sharedInstance.setSelectedPartyCrowdItem(crowdItem)
                        UserDefaults.standard.set("false", forKey: "shouldgotoPartypeopleTab")
                        root.pushViewController(viewController, animated: true)
                    }
                    break
                case "campaign":
                    break
                default:
                    break
                    
                }
            }
            else {
                
            }

        }
        
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {//called when app is in foreground
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        if notification.request.identifier == "partymode_notify"{
            
            completionHandler( [.alert,.sound,.badge])
            
        }
    }
    
    func convertToArrayOfString(_ string:String) -> [String]{
        //var returnedArray = [String]()
        let removed_symbol_str = string.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "\"", with: "")
        print(removed_symbol_str)
        let converted_array = removed_symbol_str.components(separatedBy: ",")
        return converted_array
    }
}
extension UNNotificationAttachment {
    
    static func create(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier+".png"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            guard let imageData = UIImagePNGRepresentation(image) else {
                return nil
            }
            try imageData.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
}
extension UIApplication {
    class func topViewController(base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
