//
//  SetPartyModeAPICall.swift
//  partymode
//
//  Created by Nikita on 1/31/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import Alamofire
import KVNProgress
import SwiftyJSON
class SetPartyModeAPICall {
    func request(_ sender:UIViewController, partymode: Int)
    {
        let loader = HUDLoader()
//        if partymode == Constants.PARTYMODE_ON {
//            loader.showWithStatus()
//        }
        
        //=====================parameters, url, headers=====================//
        
        let url: String = Constants.API_LINK
        
        let pmode = partymode
        let pmode_time = Int(NSDate().timeIntervalSince1970)
        let defaults = UserDefaults.standard
        let sid = defaults.string(forKey: "sid")
        let uid = defaults.string(forKey: "uid")
        
        let parameters: Parameters = [
            "pmode": pmode,
            "pmode_time": pmode_time,
            "sid": sid!,
            "uid": uid!,
            "action": "set_pmode"
        ]
        print(parameters)
        
        //=====================request=====================//
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).downloadProgress { progress in
            print("Download Progress: \(progress.fractionCompleted)")
            }.responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    
                    let post = JSON as! NSDictionary
                    print(post)
                    
                    let state = post.object(forKey: "state") as! String
                    if state == "success" {
                        let defaults = UserDefaults.standard
                        defaults.set(partymode, forKey: Constants.SP_PARTYMODE)
                        defaults.set(pmode_time, forKey: Constants.SP_PARTYMODE_TIME)
//                        if partymode == Constants.PARTYMODE_ON {
//                            loader.showSuccess()
//                        }
                        
                    }
                    else {
                        loader.showError()
                        self.gotoLoginScreen(sender)
                    }
                    
                case .failure(let error):
                    loader.showError()
                    print(error)
                    //NoInternetConnectionAlertClass().showAlert()
                }
        }
        
    }
    func gotoLoginScreen(_ sender:UIViewController){
        _ = sender.navigationController?.popToRootViewController(animated: true)
    }
    
}
