//
//  SendContactsAPICall.swift
//  partymode
//
//  Created by Nikita on 1/30/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import Alamofire
import KVNProgress
import SwiftyJSON
class SendContactsAPICall {
    func request(_ sender:UIViewController, contactNumbers: [String], completionHandler: @escaping (_ post: [PartyPeopleCellData]) -> Void)
    {
       var partyONPeopleCount = 0
        let loader = HUDLoader()
        //loader.showWithStatus()
        
        //=====================parameters, url, headers=====================//
        
        let url: String = Constants.API_LINK
        
        
        let defaults = UserDefaults.standard
        let sid = defaults.string(forKey: "sid")
        let uid = defaults.string(forKey: "uid")
        
        print(contactNumbers.count)
        
        
        let parameters: Parameters = [
            "contacts": contactNumbers,//["+41787115573","+431111111111"],
            "sid": sid!,
            "uid": uid!,
            "action": "send_contacts"
        ]
        print(parameters)
        
        //=====================request=====================//
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).downloadProgress { progress in
            print("Download Progress: \(progress.fractionCompleted)")
            }.responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    //loader.showSuccess()
                    
                    let post = JSON as! NSDictionary
                    print(post)

                    let state = post.object(forKey: "state") as! String
                    if state == "success" {
                        //let contactsList = post.object(forKey: "contacts") as! [String: NSDictionary]
                       
                        let contactsList = post["contacts"] as! [String:Any]
                        
                        var partypeopleArray = [PartyPeopleCellData]()
                        var eachItem: PartyPeopleCellData!
                        for (key, value) in contactsList {
                            print("\(key) - \(value) ")
                            let phonenumber = key
                            let eachData = contactsList[key] as! NSDictionary
                            let pmode = eachData.object(forKey: "pmode") as! Int
                            
                            if pmode == Constants.PARTYMODE_ON {
                                partyONPeopleCount = partyONPeopleCount + 1
                            }
                            
                            var img_off_lc = 0
                            if let img_off_lc_value = eachData.object(forKey: "img_off_lc") {
                                
                                img_off_lc = img_off_lc_value as! Int
                            }
                            
                            var img_on_lc = 0
                            if let img_on_lc_value = eachData.object(forKey: "img_on_lc") {
                                
                                img_on_lc = img_on_lc_value as! Int
                            }
                            
                            var img_pending_lc = 0
                            if let img_pending_lc_value = eachData.object(forKey: "img_pending_lc") {
                                
                                img_pending_lc = img_pending_lc_value as! Int
                            }
                            
                            var pmode_time = 0
                            if let pmode_time_value = eachData.object(forKey: "pmode_time") {
                                
                                pmode_time = pmode_time_value as! Int
                            }
                            
//                            let img_on_lc = eachData.object(forKey: "img_on_lc") as! Int
//                            let img_pending_lc = eachData.object(forKey: "img_pending_lc") as! Int
                            let user_state = eachData.object(forKey: "user_state") as! Int
                            
                            eachItem = PartyPeopleCellData(image: UIImage(named: "nav_profile_inactive")!, name_string: "", phonenumber: phonenumber, pmode: pmode, img_off_lc: img_off_lc, img_on_lc: img_on_lc, img_pending_lc: img_pending_lc, user_state: user_state, pmode_time: pmode_time)
                            partypeopleArray.append(eachItem)
                            let isUpdated = DBManager.getInstance().updateContactData(eachItem)
                            _ = DBManager.getInstance().updatePmodeCacheData(phonenumber, pmode_time: pmode_time, pmode: pmode)
                            
                            

                        }
                        let partypOnPeopleCount_string = String(describing: partyONPeopleCount)
                        UserDefaults.standard.set(partypOnPeopleCount_string, forKey: "partypeople_count")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_updatePartyPeopleCount"), object: nil)
                        completionHandler(partypeopleArray)
                        
                    }
                    else{
                        _ = sender.navigationController?.popToRootViewController(animated: true)
                    }
                    
                case .failure(let error):
                    //loader.showError()
                    print(error)
                    
                    //NoInternetConnectionAlertClass().showAlert()
                }
        }
        
    }
    
    func goToMainScreen(sender:UIViewController){
        let viewController =  sender.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        viewController.title = "partymode"
        sender.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
}
