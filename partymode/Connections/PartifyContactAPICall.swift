//
//  PartifyContactAPICall.swift
//  partymode
//
//  Created by Nikita on 1/31/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import Alamofire
import KVNProgress
import SwiftyJSON
class PartifyContactAPICall {
    func request(_ sender:UIViewController, phone_nrToPartify: String, completionHandler: @escaping (_ post: String) -> Void)
    {
        
        let loader = HUDLoader()
        //loader.showWithStatus()
        //=====================parameters, url, headers=====================//
        let url: String = Constants.API_LINK
        let defaults = UserDefaults.standard
        let sid = defaults.string(forKey: "sid")
        let uid = defaults.string(forKey: "uid")
        
        let parameters: Parameters = [
            "partify": phone_nrToPartify,//"+4369913186982",
            "sid": sid!,
            "uid": uid!,
            "action": "partify"
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
                        let partified_time = Int(NSDate().timeIntervalSince1970)
                        let isUpdated = DBManager.getInstance().setPartifyInfo(phone_nrToPartify, partified_time: partified_time)
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
