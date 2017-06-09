//
//  ViewController.swift
//  partymode
//
//  Created by Nikita on 1/12/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit
import DigitsKit
import TwitterCore
import Alamofire
import Crashlytics


class ViewController: UIViewController, DGTAuthEventDelegate {
    
    var viewController: UIViewController!
    
    @IBOutlet weak var topHeaderLabel: UILabel!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var welcomeLabel: FRHyperLabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var topHeaderBottomBorderLine: UILabel!
    @IBOutlet weak var sendingAcitivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var magicDoubleTapView: UIView!
    
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        GlobalData.sharedInstance.loadPmodeUsersDataFromDB()
    }
//    func makeNavigationBarTransparent(){
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 2
        tap.addTarget(self, action: #selector(ViewController.freeLogin))
        magicDoubleTapView.isUserInteractionEnabled = true
        magicDoubleTapView.addGestureRecognizer(tap)
        
        if UserDefaults.standard.string(forKey: "executedFlag") == nil {
            magicDoubleTapView.isHidden = false
            UserDefaults.standard.set("true", forKey: "executedFlag")
        }
        else {
            magicDoubleTapView.isHidden = true
        }
        
        
        self.navigationController?.navigationBar.isTranslucent = true
        self.title = "partymode"
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "ico_back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "ico_back")
        //self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        //makeNavigationBarTransparent()
        self.sendingAcitivityIndicator.isHidden = true
        logoImageView.layer.masksToBounds = true
        logoImageView.layer.cornerRadius = 61
        showUnderlineLinkTOS()
        loginButton.setTitle(NSLocalizedString("login", comment: ""), for: UIControlState())
        makeLoginButtonShadow()
        
        let defaults = UserDefaults.standard
        let sid = defaults.string(forKey: "sid")
        let uid = defaults.string(forKey: "uid")
        if sid != nil && uid != nil{
            
            /* Registering GCM TOKEN */
            SetGCMTokenAPICall().request()
            logUser()
            self.goToMainScreen()
        }
//        viewController =  self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
//        viewController.title = "partymode"
//        self.navigationController?.pushViewController(viewController, animated: true)

    }
    func logUser() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
        
        let myPhoneNr = UserDefaults.standard.string(forKey: "phone_nr")
        //Crashlytics.sharedInstance().setUserEmail(myPhoneNr)
        Crashlytics.sharedInstance().setUserIdentifier(myPhoneNr)
        //Crashlytics.sharedInstance().setUserName(myPhoneNr)
    }
    func freeLogin(){
        print("double tapped")
        let defaults = UserDefaults.standard
        
        defaults.set(Constants.demoPhoneNumber, forKey: "phone_nr")
        defaults.set(Constants.demo_sid, forKey: "sid")
        defaults.set(Constants.demo_uid, forKey: "uid")
        defaults.synchronize()
        
        let sid = defaults.string(forKey: "sid")
        let uid = defaults.string(forKey: "uid")
        if sid != nil && uid != nil{
            
            /* Registering GCM TOKEN */
            SetGCMTokenAPICall().request()
            logUser()
            self.goToMainScreen()
        }
        
    }
    func showUnderlineLinkTOS(){
        let tos_string = NSLocalizedString("login_signup_rules",comment:"")
//        let attributes = [NSForegroundColorAttributeName: UIColor.black,
//                          NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 13)!]
        
        
        //Localization
        welcomeLabel.text = tos_string
        //welcomeLabel.attributedText = NSAttributedString(string: tos_string, attributes: attributes)//NSLocalizedString("welcome", comment: "")
        welcomeLabel.setLineHeight(lineHeight: 1.2)
        //makeTopHeaderViewShadow()
        // Define a selection handler block
        let handler = {
            (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            if substring == "Terms of Service" || substring == "ANB"{
                self.TOSButtonClicked()
            }
            if substring == "Privacy Policy" || substring == "DSB"{
                self.PrivacyButtonClicked()
            }
        }
        //Step 3: Add link substrings
        let lang = NSLocalizedString("currentLanuguage",comment:"")
        if lang == "en" {
            welcomeLabel.setLinksForSubstrings(["Terms of Service", "Privacy Policy"], withLinkHandler: handler)
        }
        if lang == "de" {
            welcomeLabel.setLinksForSubstrings(["ANB", "DSB"], withLinkHandler: handler)
        }
        
        
    }
    func TOSButtonClicked() {
        print("TOS Pressed")
        let url = URL(string: "http://www.partymode.cc/appanb")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }

    }
    func PrivacyButtonClicked() {
        print("Privacy Pressed")
        let url = URL(string: "http://www.partymode.cc/appdsb")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }

    }
    func makeLoginButtonShadow(){
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOpacity = 1
        loginButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        loginButton.layer.borderWidth = 0
    }
    @IBAction func LoginClicked(_ sender: Any) {
        self.showSendingAcitivityIndicator()
        self.didTapButton()
    }
    func didTapButton() {
        
        let auth_header_key1:String = "X-Auth-Service-Provider"
        var auth_header_value1:String!
        let auth_header_key2: String = "X-Verify-Credentials-Authorization"
        var auth_header_value2:String!
        
        let digits = Digits.sharedInstance()
        
        
        digits.authenticate { (session, error) in
            // Inspect session/error objects
            let when = DispatchTime.now() + 4
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.hideSendingActivityIndicator()
            }
            if (session != nil) {
                
                print(session?.phoneNumber! as Any)
                print(session?.userID! as Any)
                print(session?.authToken! as Any)
                
                let oauthSigning = DGTOAuthSigning(authConfig:Digits.sharedInstance().authConfig, authSession:digits.session())
                let authHeaders = oauthSigning?.oAuthEchoHeadersToVerifyCredentials()
                
                
                for each in authHeaders!{
                    print("\(each.key) : \(each.value)")
                    let key:String = "\(each.key)"
                    //let value:String = "\(each.value)"
                    if key == auth_header_key1 {
                        print("\(each.value)")
                        auth_header_value1 = "\(each.value)"
                    }
                    else {
                        print("\(each.value)")
                        auth_header_value2 = "\(each.value)"
                    }
                   
                }                
                
                // Tie crashes to a Digits user ID in Crashlytics.
                //Crashlytics.sharedInstance().setUserIdentifier(session.userID)
                /*
                let message = "Phone number: \(session!.phoneNumber!)"
                let alertController = UIAlertController(title: "You are logged in!", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: .none))
                self.present(alertController, animated: true, completion: .none)
                 */
                LoginAPICall().request(self, auth_header_key1: auth_header_key1, auth_header_value1: auth_header_value1, auth_header_key2: auth_header_key2, auth_header_value2: auth_header_value2)
                
                
            } else {
                NSLog("Authentication error: %@", error!.localizedDescription)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func goToMainScreen(){
        //GlobalData.sharedInstance.startLoadingData()
        let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        viewController.title = "partymode"
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showSendingAcitivityIndicator(){
        loginButton.setTitleColor(UIColor.darkGray, for: .normal)
        self.sendingAcitivityIndicator.isHidden = false
        self.sendingAcitivityIndicator.hidesWhenStopped = true
        self.sendingAcitivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.sendingAcitivityIndicator.startAnimating()
    }
    
    func hideSendingActivityIndicator(){
        loginButton.setTitleColor(UIColor.white, for: .normal)
//        self.sendingAcitivityIndicator.isHidden = false
        self.sendingAcitivityIndicator.stopAnimating()
        
    }

}
extension UILabel {
    func setLineHeight(lineHeight: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.0
        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.alignment = self.textAlignment
        
        let attrString = NSMutableAttributedString(string: self.text!)
        attrString.addAttribute(NSFontAttributeName, value: self.font, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        self.attributedText = attrString
    }
}
