//
//  SendProfileAPICall.swift
//  partymode
//
//  Created by Nikita on 1/31/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import Alamofire
import KVNProgress
import SwiftyJSON
class SendProfileAPICall {
    func request(_ sender:UIViewController, partyname: String, firstname: String, lastname: String, address: String, email: String, birthdayStamp: Int, birthdayText: String, gender: Int, img_pending: String, img_on: String, img_off: String, completionHandler: @escaping (_ post: NSDictionary) -> Void)
    {
        
        let loader = HUDLoader()
        loader.show()
        //=====================parameters, url, headers=====================//
        let url: String = Constants.API_LINK
        let defaults = UserDefaults.standard
        let sid = defaults.string(forKey: "sid")
        let uid = defaults.string(forKey: "uid")
        
        let parameters: Parameters = [
            "partyname": partyname,//"Partybär",
            "firstname": firstname,//"Thomas",
            "lastname": lastname,//"Feierstan",
            "address": address,//"Ludwigshafen",
            "email": email,//"tom@feier.at",
            "birthday": birthdayStamp,//946681200,
            "gender": gender,//-1,
            "img_pending": img_pending,//"base64EncodedString",
            "img_on": img_on,//"base64EncodedString",
            "img_off": img_off,//"base64EncodedString",
            "sid": sid!,
            "uid": uid!,
            "action": "send_profile"
        ]
        print(parameters)
        //=====================request=====================//
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).downloadProgress { progress in
            print("Download Progress: \(progress.fractionCompleted)")
            }.responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    loader.showSuccess()
                    let post = JSON as! NSDictionary
                    print(post)
                    
                    let state = post.object(forKey: "state") as! String
                    if state == "success" {
                                                
                        completionHandler(post)
                    }
                    
                case .failure(let error):
                    loader.showError()
                    print(error)
                    //NoInternetConnectionAlertClass().showAlert()
                }
        }
        
    }
    
}
