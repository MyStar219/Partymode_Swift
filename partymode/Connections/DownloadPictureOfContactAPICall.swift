//
//  DownloadPictureOfContactAPICall.swift
//  partymode
//
//  Created by Nikita on 1/31/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import Alamofire
import KVNProgress
import SwiftyJSON
class DownloadPictureOfContactAPICall {
    func request(phone_nr: String, imagemode: Int, completionHandler: @escaping (_ post: UIImage) -> Void)
    {
        
        let loader = HUDLoader()
        //loader.show()
        //=====================parameters, url, headers=====================//
        let url: String = Constants.API_LINK
        let defaults = UserDefaults.standard
        let sid = defaults.string(forKey: "sid")
        let uid = defaults.string(forKey: "uid")
        var imagemode_str: String!
        if imagemode == 0 {
            imagemode_str = "img_pending"
        }
        if imagemode == 1 {
            imagemode_str = "img_off"
        }
        if imagemode == 2 {
            imagemode_str = "img_on"
        }
        
        let parameters: Parameters = [
            "phone_nr": phone_nr,//"+4369913186982",
            "imagemode": imagemode_str,//"img_pending",
            "sid": sid!,
            "uid": uid!,
            "action": "get_img"
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
                        if let img = post.object(forKey: "img") as? String {
                            let base64_str = post.object(forKey: "img") as! String
                            if base64_str.characters.count > 0 {
                                let fetchedImage = Base64Util().decodedFromBase64(base64_str)
                                completionHandler(fetchedImage)
                            }
                            
                        }
                        
                    }
                    
                case .failure(let error):
                    //loader.showError()
                    print(error)
                    //NoInternetConnectionAlertClass().showAlert()
                }
        }
        
    }
    
}
