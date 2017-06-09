//
//  PingAPICall.swift
//  partymode
//
//  Created by Nikita on 4/4/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import Alamofire

class PingAPICall {
    func request()
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
                "sid": sid!,
                "uid": uid!,
                "action": "ping"
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
                            print("ping sent to server successfully")
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
