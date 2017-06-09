//
//  SettingsViewController.swift
//  partymode
//
//  Created by Nikita on 1/14/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit
import AudioToolbox

class SettingsViewController: UIViewController {

    @IBOutlet weak var vibration_switch: UISwitch!
    
    @IBOutlet weak var vibrateLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfGotoHomeView(_:)), name:NSNotification.Name(rawValue: "notificationId_gotoPartyPeopleTab"), object: nil)
        
    }
    func methodOfGotoHomeView(_ notification: Notification){
        //Take Action on Notification
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: false);
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        vibrateLabel.text = NSLocalizedString("vibrate", comment: "")
        logoutButton.setTitle(NSLocalizedString("logoff", comment: ""), for: UIControlState())
        logoutButtonStyle()
        
        let vibrate_status = UserDefaults.standard.bool(forKey: "vibrate")
        vibration_switch.setOn(vibrate_status, animated: false)
        
        self.displayAppVersionInfo()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func displayAppVersionInfo(){
        if let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.versionLabel.text = "Version \(versionNumber)"
        }
        
    }
    
    func logoutButtonStyle(){
        logoutButton.layer.cornerRadius = 5
        logoutButton.layer.borderColor = UIColor.black.cgColor
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.masksToBounds = true
    }
    
    func initLoginValues(){
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "sid")
        defaults.set(nil, forKey: "uid")
        defaults.synchronize()
    }
    func gotoLoginScreen(){
        
        _ = self.navigationController?.popToRootViewController(animated: true)
        
    }
    @IBAction func switchTouchEvent(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        if sender.isOn {
            defaults.set(true, forKey: "vibrate")
            defaults.synchronize()
            if #available(iOS 10.0, *) {
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
                feedbackGenerator.impactOccurred()
            } else {
                // Fallback on earlier versions
            }
            
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        else {
            defaults.set(false, forKey: "vibrate")
        }
    }
    func enableVibrateOnNotifications(){
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        } else {
            // Fallback on earlier versions
        }
        
    }

    @IBAction func logoutPressed(_ sender: Any) {
        
        self.initLoginValues()
        self.gotoLoginScreen()
    }
}
