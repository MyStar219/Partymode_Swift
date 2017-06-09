//
//  SplashViewController.swift
//  partymode
//
//  Created by Nikita on 5/14/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
class SplashViewController: UIViewController {
    var myTimer = Timer()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        GlobalData.sharedInstance.loadPmodeUsersDataFromDB()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SplashViewController.gotoMainViewController), userInfo: nil, repeats: false)

    }
    func gotoMainViewController()
    {
        let stb = UIStoryboard(name: "Main", bundle: nil)
        let viewController = stb.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        
        
        let navigation = UINavigationController(rootViewController: viewController!)
        self.present(navigation, animated: true, completion: nil)
        //self.navigationController?.pushViewController(viewController!, animated: true)
        self.myTimer.invalidate()
        
    }
}
