//
//  AddFriendsToCrowdAPICall.swift
//  partymode
//
//  Created by Nikita on 5/3/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import Alamofire
import KVNProgress
import SwiftyJSON
class AddFriendsToCrowdAPICall {
    
    func request(id: String, title: String, location: String, partyTimeStamp: Int, partyTime:String, invite_friends: Bool, color: Int, members: [String], completionHandler: @escaping (_ post: NSDictionary) -> Void)
    {
        
        let loader = HUDLoader()
        loader.show()
        
        //=====================parameters, url, headers=====================//
        
        let url: String = Constants.API_LINK
        let defaults = UserDefaults.standard
        let sid = defaults.string(forKey: "sid")
        let uid = defaults.string(forKey: "uid")
        
        let parameters: Parameters = [
            "id": id,
            //"title": title,
            //"location": location,
            //"time": partyTimeStamp,
            //"invite_friends": invite_friends,
            //"color": color,
            "members": members,
            "sid": sid!,
            "uid": uid!,
            "action": "add_to_crowd"
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
                    else {
                        loader.showError()
                    }
                    
                case .failure(let error):
                    loader.showError()
                    print(error)
                    //completionHandler("failed")
                    //NoInternetConnectionAlertClass().showAlert()
                }
        }
        
    }
    
}

