//
//  SetGCMTokenAPICall.swift
//  partymode
//
//  Created by Nikita on 1/31/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import Alamofire
import KVNProgress
import SwiftyJSON
class SetGCMTokenAPICall {
    func request()
    {
        
//        let loader = HUDLoader()
        //loader.showWithStatus()
        
        //=====================parameters, url, headers=====================//
        
        let url: String = Constants.API_LINK
        let defaults = UserDefaults.standard
        let sid = defaults.string(forKey: "sid")
        let uid = defaults.string(forKey: "uid")
        
        let language = NSLocalizedString("currentLanuguage", comment: "")
        
        if sid != nil && uid != nil {
            var gcm_token:String
            if UserDefaults.standard.string(forKey: "gcm_device_token") != nil {
                gcm_token = UserDefaults.standard.string(forKey: "gcm_device_token")!
            }
            else {
                gcm_token = ""
            }
            let parameters: Parameters = [
                "gcm_token": gcm_token,
                "sid": sid!,
                "uid": uid!,
                "action": "gcm",
                "lang": language,
                "os": "ios"
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
                            
                        }
                        
                    case .failure(let error):
                        //loader.showError()
                        print(error)
                        //NoInternetConnectionAlertClass().showAlert()
                    }
            }
        }
        
        
    }
    
}
