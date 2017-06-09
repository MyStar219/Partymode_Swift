//
//  AlertClass.swift
//  partymode
//
//  Created by Nikita on 2/1/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class AlertClass {

    
    func showAlert(sender:UIViewController, title:String, msg:String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        sender.present(alert, animated: true, completion: nil)
    }

}
