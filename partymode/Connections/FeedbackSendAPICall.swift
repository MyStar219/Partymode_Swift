//
//  FeedbackSendAPICall.swift
//  partymode
//
//  Created by Nikita on 1/21/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import Alamofire
class FeedbackSendAPICall {
    func request(_ sender:UIViewController, feedbackString: String, stars: Int, completionHandler: @escaping (_ post: NSDictionary) -> Void)
    {
        
        let loader = HUDLoader()
        //loader.show()
        //=====================parameters, url, headers=====================//
        let url: String = Constants.API_LINK
        let defaults = UserDefaults.standard
        let sid = defaults.string(forKey: "sid")
        let uid = defaults.string(forKey: "uid")
        
        let parameters: Parameters = [
            "feedback": feedbackString,//"FeedbackText",
            "stars": stars,//5
            "sid": sid!,
            "uid": uid!,
            "action": "feedback"
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
                        completionHandler(post)
                    }
                    else{
                        _ = sender.navigationController?.popToRootViewController(animated: true)
                    }
                    
                case .failure(let error):
                    loader.showError()
                    print(error)
                    //NoInternetConnectionAlertClass().showAlert()
                }
        }
        
    }
//    
//    func request(_ sender:UIViewController)
//    {
//        
////        let loader = SBAnimatedLoaderView()
////        loader.show()
//        
//        //=====================parameters, url, headers=====================//
//        
//        let url: String = Constants.API_LINK
//        
//          //  {"sid": "awFzDE6J+CgbDcbixxwuXiew",	"uid": "57503791fc419a088fafbb73", "action": "feedback", "feedback": "Freetext", "stars": 5}
//        //Stars is mandatory and of numeric type 1 to 5.
//        
//        let infoParam: String = "{\"sid\":\"awFzDE6J+CgbDcbixxwuXiew\",\"uid\":\"57503791fc419a088fafbb73\",\"action\":\"feedback\",\"feedback\":\"Freetext\",\"stars\":5}"
//        
//        let parameters: Parameters = [
//            "contacts": ["+431111111111"],
//            "sid": sid!,
//            "uid": uid!,
//            "action": "get_usrname"
//        ]
//        print(infoParam)
//        //=====================request=====================//
//        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { response in
//            switch response.result {
//            case .success(let JSON):
//                let post = JSON as! NSDictionary
//                //let success = (post["success"]! as AnyObject).stringValue
//                print(post)
////                DispatchQueue.main.async{
////                    loader.hide()
////                }
////                if success == "1" {
////                    print("Your profile has been updated sucessfully")
////                    let alert_deletedAccount = NSLocalizedString("alert_deletedAccount",comment:"")
////                    let alertController = UIAlertController(title: "Medlanes", message: alert_deletedAccount, preferredStyle: .alert)
////                    let OKAction = UIAlertAction(title: NSLocalizedString("OK",comment:""), style: .default) {
////                        (action:UIAlertAction!) in
////                        
////                    }
////                    
////                    alertController.addAction(OKAction)
////                    
////                    sender.present(alertController, animated: true, completion:nil)
////                }
////                else{
////                    BackendConnectionErrorAlert().show()
////                    
////                    
////                }
//            case .failure(let error):
//                print(error)
//                NoInternetConnectionAlertClass().showAlert()
////                DispatchQueue.main.async{
////                    loader.hide()
////                }
//                //---------------------------//
//                
//            }
//        }
//        
//    }
//    
}
