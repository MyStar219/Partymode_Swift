//
//  ConfirmPushAPICall.swift
//  partymode
//
//  Created by Nikita on 4/4/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ConfirmPushAPICall {
    func request(_ pushId:String)
    {
        
        let loader = HUDLoader()
        //loader.showWithStatus()
        
        //=====================parameters, url, headers=====================//
        
        let url: String = Constants.API_LINK
        let defaults = UserDefaults.standard
        let sid = defaults.string(forKey: "sid")
        let uid = defaults.string(forKey: "uid")
        
        if sid != nil && uid != nil {
            
            let parameters: Parameters = [
                "pushid": pushId,
                "sid": sid!,
                "uid": uid!,
                "action": "confirm_push"
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
                            print("confirm message of push #\(pushId) has been sent")
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
