//
//  LoginAPICall.swift
//  partymode
//
//  Created by Nikita on 1/23/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import Alamofire
import KVNProgress
class LoginAPICall {
    func request(_ sender:UIViewController, auth_header_key1: String, auth_header_value1:String, auth_header_key2:String, auth_header_value2:String)
    {
        let loader = HUDLoader()
        //loader.showWithStatus()
        //=====================parameters, url, headers=====================//
        let url: String = Constants.API_LINK
        let infoParam: String = "{\"action\":\"login\"}"
        print("\(auth_header_key1) : \(auth_header_value1)")
        print("\(auth_header_key2) : \(auth_header_value2)")
        let headers = [
            "Content-Type": "application/json",
            auth_header_key1: auth_header_value1,
            auth_header_key2: auth_header_value2
        ]
        
        let parameters: Parameters = [
            "action": "login"
        ]
        print(infoParam)
        print(headers)
        //=====================request=====================//
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).downloadProgress { progress in
            print("Download Progress: \(progress.fractionCompleted)")
            }.responseJSON { response in
            switch response.result {
            case .success(let JSON):
                //loader.showSuccess()
                let post = JSON as! NSDictionary
                print(post)
                let state = post.object(forKey: "state") as! String
                if state == "success" {
                    let phone_nr = post.object(forKey: "phone_nr") as! String
                    let sid = post.object(forKey: "sid") as! String
                    let uid = post.object(forKey: "uid") as! String
                    
                    let defaults = UserDefaults.standard
                    
                    defaults.set(phone_nr, forKey: "phone_nr")
                    defaults.set(sid, forKey: "sid")
                    defaults.set(uid, forKey: "uid")
                    defaults.synchronize()
                    /* Registering GCM TOKEN */
                    SetGCMTokenAPICall().request()
                    self.goToMainScreen(sender: sender)
                    
                }
            case .failure(let error):
                loader.showError()
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
