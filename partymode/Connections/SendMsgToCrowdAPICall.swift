//
//  SendMsgToCrowdAPICall.swift
//  partymode
//
//  Created by Nikita on 1/31/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import Alamofire
import KVNProgress
import SwiftyJSON
class SendMsgToCrowdAPICall {
    func request(id: String, isimg: Bool, msg: String, completionHandler: @escaping (_ post: Int) -> Void)
    {
        
        let loader = HUDLoader()
        //loader.showWithStatus()
        //=====================parameters, url, headers=====================//
        let url: String = Constants.API_LINK
        let defaults = UserDefaults.standard
        let sid = defaults.string(forKey: "sid")
        let uid = defaults.string(forKey: "uid")
       
        let parameters: Parameters = [
            "id": id,//"579dcfe748a6605411bee512",
            "isimg": isimg,//false
            "msg": msg,//"Hallo",
            "sid": sid!,
            "uid": uid!,
            "action": "send_msg"
        ]
        //print(parameters)
        //=====================request=====================//
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).downloadProgress { progress in
            print("Download Progress: \(progress.fractionCompleted)")
            }.responseJSON { response in
                //print(response)
                switch response.result {
                case .success(let JSON):
                    //loader.showSuccess()
                    let post = JSON as! NSDictionary
                    print(post)
                    
                    let state = post.object(forKey: "state") as! String
                    let msgtime = post.object(forKey: "msgtime") as! Int
                    if state == "success" {
                        completionHandler(msgtime)
                    }
                    else {
                        completionHandler(0)
                    }
                    
                case .failure(let error):
                    loader.showError()
                    completionHandler(0)
                    print(error)
                    //NoInternetConnectionAlertClass().showAlert()
                }
        }
        
    }
    
}
