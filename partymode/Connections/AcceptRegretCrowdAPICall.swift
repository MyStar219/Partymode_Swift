//
//  AcceptRegretCrowdAPICall.swift
//  partymode
//
//  Created by Nikita on 1/31/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import Alamofire
import KVNProgress
import SwiftyJSON
class AcceptRegretCrowdAPICall {
    func request(_ sender:UIViewController, id: String, status: Int, msg: String, completionHandler: @escaping (_ post: String) -> Void)
    {
        
        let loader = HUDLoader()
        loader.show()
        //=====================parameters, url, headers=====================//
        let url: String = Constants.API_LINK
        let defaults = UserDefaults.standard
        let sid = defaults.string(forKey: "sid")
        let uid = defaults.string(forKey: "uid")
        
        let parameters: Parameters = [
            "id": id,//"579dcfe748a6605411bee512",
            "status": status,//2,
            "msg": msg,//"I’m busy",
            "sid": sid!,
            "uid": uid!,
            "action": "dec_crowd"
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
                        completionHandler("success")
                    }
                    else {
                        completionHandler("failed")
                    }
                    
                case .failure(let error):
                    loader.showError()
                    completionHandler("failed")
                    print(error)
                    //NoInternetConnectionAlertClass().showAlert()
                }
        }
        
    }
    
}
