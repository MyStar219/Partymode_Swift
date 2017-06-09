//
//  Tab1PartymodeViewController.swift
//  partymode
//
//  Created by Nikita on 1/12/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit
import Crashlytics


class Tab1PartymodeViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var modeSwitchBackground: UIImageView!
    @IBOutlet weak var discoball: UIImageView!
    @IBOutlet weak var modeStatusBar: UIImageView!
    @IBOutlet weak var modeStatusText: UILabel!
    @IBOutlet weak var partyMemberCountLabel: UILabel!
    @IBOutlet weak var switchView: UIView!
    
    @IBOutlet weak var tvAlert_BackgroundView: UIView!
    @IBOutlet weak var tvAlertView: UIView!
    @IBOutlet weak var tvAlert_movienight_label: UILabel!
    @IBOutlet weak var tvAlert_bodyText_label: UILabel!
    @IBOutlet weak var tvAlert_cancel_button: UIButton!
    @IBOutlet weak var tvAlert_ok_button: UIButton!
    
    
    @IBOutlet weak var showFriendsLabel: UILabel!
    @IBOutlet weak var discoball_leading_constraint: NSLayoutConstraint!
    @IBOutlet weak var discoball_trailing_constraint: NSLayoutConstraint!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.partyPeopleCountUpdate(_:)), name:NSNotification.Name(rawValue: "notificationId_updatePartyPeopleCount"), object: nil)
        
        self.getPartymodeStatus()
    }
    func partyPeopleCountUpdate(_ notification: Notification){
        //Take Action on Notification
        updatePartyPeopleCount()
    }
    func updatePartyPeopleCount(){
        let pmodeON_count = UserDefaults.standard.string(forKey: "partypeople_count")
        if pmodeON_count != nil {
            partyMemberCountLabel.text = pmodeON_count
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Localizatin
        showFriendsLabel.text = NSLocalizedString("showyourfriendsyourmode", comment: "")
        
        tvAlert_movienight_label.text = NSLocalizedString("tvmedia_title", comment: "")
        tvAlert_bodyText_label.text = NSLocalizedString("tvmedia_body", comment: "")
        tvAlert_cancel_button.setTitle(NSLocalizedString("cancel", comment: ""), for: UIControlState())
        //setPendingBackground()
        makeDiscoBallShadow()
        discoball.isUserInteractionEnabled = true
        
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(self.detectPan(_:)))
        self.discoball.addGestureRecognizer(panRecognizer)
        makeTVAlertShadowStyle()
        
        //updatePartyPeopleCount()
        
//        let button = UIButton(type: .roundedRect)
//        button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
//        button.setTitle("Crash", for: [])
//        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
//        view.addSubview(button)

    }
//    @IBAction func crashButtonTapped(_ sender: AnyObject) {
//        Crashlytics.sharedInstance().crash()
//    }

    func detectPan( _ gestureRecognizer:UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.switchView)
        print(gestureRecognizer.view!.center.x)
        let ballWidth : CGFloat = self.discoball.bounds.width
        let bgMarginMin : CGFloat = self.switchView.bounds.origin.x + ballWidth / 2 + 1
        let bgMarginMax : CGFloat = self.switchView.bounds.origin.x + self.switchView.bounds.width - ballWidth / 2 - 1
        let bgMarginMid : CGFloat = (bgMarginMin + bgMarginMax) / 2
        var x_cord: CGFloat = gestureRecognizer.view!.center.x + translation.x/5
        
        if gestureRecognizer.state == UIGestureRecognizerState.changed {
            if (x_cord > bgMarginMax){
                x_cord = bgMarginMax
            }
            if (x_cord < bgMarginMin){
                x_cord = bgMarginMin
            }
            gestureRecognizer.view!.center = CGPoint(x: x_cord, y: gestureRecognizer.view!.center.y)
            
            if (x_cord < bgMarginMid) {
                modeSwitchBackground.image = UIImage(named: "mode_big_01")
                
                let alpha : CGFloat = 1 - (1 / (bgMarginMid - bgMarginMin) * (x_cord - bgMarginMin))
                modeSwitchBackground.alpha = alpha
                
            } else {
                modeSwitchBackground.image = UIImage(named: "mode_big_07")
                
                let alpha : CGFloat = 1 / (bgMarginMid - bgMarginMin) * ((x_cord - bgMarginMin) - (bgMarginMid - bgMarginMin))
                modeSwitchBackground.alpha = alpha
                
            }
        }
        
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            if (x_cord < bgMarginMin + 0){
                
                modeSwitchBackground.image = UIImage(named: "mode_big_01")
                gestureRecognizer.view!.center = CGPoint(x: bgMarginMin, y: gestureRecognizer.view!.center.y)
                modeStatusBar.image = UIImage(named: "mode_bar_off")
                modeStatusText.text = NSLocalizedString("partymodeoff", comment: "")//"partymodeOFF"
                modeStatusText.textColor = Constants.switch_color_off
                setPartyModeOFFBackground()
            }
            else if (x_cord > bgMarginMax - 0){
                
                modeSwitchBackground.image = UIImage(named: "mode_big_07")
                gestureRecognizer.view!.center = CGPoint(x: bgMarginMax, y: gestureRecognizer.view!.center.y)
                modeStatusBar.image = UIImage(named: "mode_bar_on")
                modeStatusText.text = NSLocalizedString("partymodeon", comment: "")//"partymodeON"
                modeStatusText.textColor = Constants.switch_color_on
                setPartyModeONBackground()
            }
            else {
                
                modeSwitchBackground.image = UIImage(named: "mode_big_04")
                gestureRecognizer.view!.center = CGPoint(x: bgMarginMid, y: gestureRecognizer.view!.center.y)
                modeStatusBar.image = UIImage(named: "mode_bar_pending")
                modeStatusText.text = NSLocalizedString("modepending", comment: "")//"Pending"
                modeStatusText.textColor = Constants.switch_color_pending
                setPendingBackground()
            }
        
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setPendingBackground(){
        self.backgroundImageView.image = UIImage(named: "bg-partymode_pending")
        SetPartyModeAPICall().request(self, partymode: Constants.PARTYMODE_NA)
    }
    func setPartyModeOFFBackground(){
        self.backgroundImageView.image = UIImage(named: "bg-partymode_off")
        SetPartyModeAPICall().request(self, partymode: Constants.PARTYMODE_OFF)
        /*
        UIView.animate(withDuration: 0.6, animations: {
            self.tvAlert_BackgroundView.alpha = 1
            
        })
        */
        
    }
    func setPartyModeONBackground(){
        self.backgroundImageView.image = UIImage(named: "bg-partymode_on")
        SetPartyModeAPICall().request(self, partymode: Constants.PARTYMODE_ON)
    }
    
    @IBAction func partypeopleImageTapped(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_gotoPartyPeopleTab"), object: nil)
        
    }
    func visitTVPage(){
        let url = URL(string: Constants.TV_LINK)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func tvAlert_Cancel_Pressed(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.tvAlert_BackgroundView.alpha = 0
            
        })
    }
    
    @IBAction func tvAlert_OK_Pressed(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.tvAlert_BackgroundView.alpha = 0
            
        })
        visitTVPage()
    }
    func makeTVAlertShadowStyle(){
        tvAlertView.layer.cornerRadius = 10
        tvAlertView.layer.shadowColor = UIColor.black.cgColor
        tvAlertView.layer.shadowOpacity = 1
        tvAlertView.layer.shadowOffset = CGSize(width: 3, height: 3)
        tvAlertView.layer.borderWidth = 0
    }
    func makeDiscoBallShadow(){
        discoball.layer.cornerRadius = discoball.bounds.width / 2
        discoball.layer.shadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
        discoball.layer.shadowOpacity = 1
        discoball.layer.shadowOffset = CGSize(width: -2, height: 0)
        discoball.layer.borderWidth = 0
    }
    
    func getPartymodeStatus(){
        let defaults = UserDefaults.standard
        var partymode = defaults.integer(forKey: Constants.SP_PARTYMODE)
        let partymode_time = defaults.integer(forKey: Constants.SP_PARTYMODE_TIME)
        let current_time = Int(NSDate().timeIntervalSince1970)
        if partymode == Constants.PARTYMODE_ON {
            if current_time - partymode_time > Constants.PARTYMODEON_DURATION || current_time < partymode_time {
                defaults.set(Constants.PARTYMODE_NA, forKey: Constants.SP_PARTYMODE)
                partymode = Constants.PARTYMODE_NA
            }
        }
        if partymode == Constants.PARTYMODE_OFF {
            if current_time - partymode_time > Constants.PARTYMODEOFF_DURATION || current_time < partymode_time {
                defaults.set(Constants.PARTYMODE_NA, forKey: Constants.SP_PARTYMODE)
                partymode = Constants.PARTYMODE_NA
            }
            
        }
        if partymode == Constants.PARTYMODE_NA {
//            PartyDB partyDB = new PartyDB();
//            long nextCrowd = partyDB.getNextCrowdTime(getContext());
//            
//            if (nextCrowd > pmode_time) {
//                pmode_time = nextCrowd;
//            } else {
//                pmode_time = 0;
//            }
//            if (System.currentTimeMillis()/1000 > pmode_time && System.currentTimeMillis()/1000<pmode_time+Globals.PARTYMODEON_DURATION) {
//                // Partymode set due to crowd
//                editor.putInt(Globals.SP_PARTYMODE, Globals.PARTYMODE_ON);
//                pmode = Globals.PARTYMODE_ON;
//                // Send it to server
//                sendPmode.setPmode(pmode);
//            }
        }
        
        setPmodeGUI(partymode: partymode)
    }
    
    func setPmodeGUI(partymode: Int){
        discoball.translatesAutoresizingMaskIntoConstraints = false
        let ballWidth : CGFloat = self.discoball.bounds.width
        let bgMarginMin : CGFloat = self.switchView.bounds.origin.x + ballWidth / 2 + 1
        let bgMarginMax : CGFloat = self.switchView.bounds.origin.x + self.switchView.bounds.width - ballWidth / 2 - 1
        let bgMarginMid : CGFloat = (bgMarginMin + bgMarginMax) / 2
        switch (partymode) {
        case Constants.PARTYMODE_ON:
            modeSwitchBackground.image = UIImage(named: "mode_big_07")
            discoball_leading_constraint.constant = bgMarginMax - ballWidth / 2 + 1
            modeStatusBar.image = UIImage(named: "mode_bar_on")
            modeStatusText.text = NSLocalizedString("partymodeon", comment: "")//"partymodeON"
            modeStatusText.textColor = Constants.switch_color_on
            self.backgroundImageView.image = UIImage(named: "bg-partymode_on")
            break;
        case Constants.PARTYMODE_OFF:
            modeSwitchBackground.image = UIImage(named: "mode_big_01")
            discoball_leading_constraint.constant = bgMarginMin - ballWidth / 2
            modeStatusBar.image = UIImage(named: "mode_bar_off")
            modeStatusText.text = NSLocalizedString("partymodeoff", comment: "")//"partymodeOFF"
            modeStatusText.textColor = Constants.switch_color_off
            self.backgroundImageView.image = UIImage(named: "bg-partymode_off")
            break;
        case Constants.PARTYMODE_NA:
            modeSwitchBackground.image = UIImage(named: "mode_big_04")
            discoball_leading_constraint.constant = bgMarginMid - ballWidth / 2
            modeStatusBar.image = UIImage(named: "mode_bar_pending")
            modeStatusText.text = NSLocalizedString("modepending", comment: "")//"Pending"
            modeStatusText.textColor = Constants.switch_color_pending
            self.backgroundImageView.image = UIImage(named: "bg-partymode_pending")
            break;
            
        default:
            break;
        }
        
    }
    
}
