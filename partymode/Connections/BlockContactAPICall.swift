//
//  BlockContactAPICall.swift
//  partymode
//
//  Created by Nikita on 1/31/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import Alamofire
import KVNProgress
import SwiftyJSON
class BlockContactAPICall {
    func request(phone_nr: String, user_state: Int, completionHandler: @escaping (_ post: String) -> Void)
    {
        
        let loader = HUDLoader()
        //loader.showWithStatus()
        //=====================parameters, url, headers=====================//
        let url: String = Constants.API_LINK
        let defaults = UserDefaults.standard
        let sid = defaults.string(forKey: "sid")
        let uid = defaults.string(forKey: "uid")
       
        let parameters: Parameters = [
            "phone_nr": phone_nr,//"+4369913186982",
            "user_state": user_state,//"2",
            "sid": sid!,
            "uid": uid!,
            "action": "block"
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
                        completionHandler("success")
                    }
                    else {
                        completionHandler("failed")
                    }
                    
                case .failure(let error):
                    loader.showError()
                    print(error)
                    completionHandler("failed")
                    //NoInternetConnectionAlertClass().showAlert()
                }
        }
        
    }
    
}
