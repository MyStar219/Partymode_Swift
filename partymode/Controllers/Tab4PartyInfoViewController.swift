//
//  Tab4PartyInfoViewController.swift
//  partymode
//
//  Created by Nikita on 1/12/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class Tab4PartyInfoViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var topHeaderView: UIView!
    
    @IBOutlet weak var left1_avartar: UIImageView!//blackborder->pending
    @IBOutlet weak var left2_avartar: UIImageView!//redborder->off
    
    @IBOutlet weak var center_avartar: UIImageView!//greeborder->on
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var partyname: UITextField!
    
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var birthday: UILabel!
    @IBOutlet weak var homecity: UILabel!
    @IBOutlet weak var mailaddress: UILabel!
    
    @IBOutlet weak var genderTwoColumnView: UIView!
    @IBOutlet weak var birthdayTwoColumnView: UIView!
    @IBOutlet weak var homecityTwoColumnView: UIView!
    @IBOutlet weak var emailTwoColumnView: UIView!
    
    @IBOutlet weak var genderValueLabel: UILabel!
    @IBOutlet weak var genderPlaceholderLabel: UILabel!
    
    @IBOutlet weak var birthdayValueLabel: UILabel!
    @IBOutlet weak var birthdayPlaceholderLabel: UILabel!
    
    @IBOutlet weak var homecityValueLabel: UILabel!
    @IBOutlet weak var homecityPlaceholderLabel: UILabel!
    
    @IBOutlet weak var mailaddressValueLabel: UILabel!
    @IBOutlet weak var mailaddressPlaceholderLabel: UILabel!
    
    func showGenderTowColumnValueLabel(){
        self.gender.isHidden = true
        self.genderTwoColumnView.isHidden = false
        
    }
    func showBirthdayTowColumnValueLabel(){
        self.birthday.isHidden = true
        self.birthdayTwoColumnView.isHidden = false
        
    }
    func showHomecityTowColumnValueLabel(){
        self.homecity.isHidden = true
        self.homecityTwoColumnView.isHidden = false
        
    }
    func showMailaddressTowColumnValueLabel(){
        self.mailaddress.isHidden = true
        self.emailTwoColumnView.isHidden = false
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(forName:Notification.Name(rawValue:"Notification_LoadProfileDataFromLocal"),
                       object:nil, queue:nil) {
                        notification in
                        // Handle notification
                        self.loadProfileDataFromLocal()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //Localization
        username.placeholder = NSLocalizedString("addname", comment: "")
        partyname.placeholder = NSLocalizedString("addpic", comment: "")
        
        makeTopHeaderViewShadow()
        avartarStyle()
        
        gender.text = NSLocalizedString("gender", comment: "")
        genderPlaceholderLabel.text = NSLocalizedString("gender", comment: "")
        birthday.text = NSLocalizedString("birthday", comment: "")
        birthdayPlaceholderLabel.text = NSLocalizedString("birthday", comment: "")
        homecity.text = NSLocalizedString("address", comment: "")
        homecityPlaceholderLabel.text = NSLocalizedString("address", comment: "")
        mailaddress.text = NSLocalizedString("emailaddress", comment: "")
        mailaddressPlaceholderLabel.text = NSLocalizedString("emailaddress", comment: "")

        
        self.loadProfileDataFromLocal()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeTopHeaderViewShadow(){
        topHeaderView.layer.shadowColor = UIColor.gray.cgColor
        topHeaderView.layer.shadowOpacity = 1
        topHeaderView.layer.shadowOffset = CGSize(width: 0, height: 0.1)
        topHeaderView.layer.borderWidth = 0
    }
    func avartarStyle(){
        center_avartar.layer.cornerRadius = center_avartar.bounds.width / 2
        center_avartar.layer.borderColor = Constants.avartar_color_green.cgColor
        center_avartar.layer.borderWidth = 3
        center_avartar.layer.masksToBounds = true
        
        left1_avartar.layer.cornerRadius = left1_avartar.bounds.width / 2
        left1_avartar.layer.borderColor = Constants.avartar_color_black.cgColor
        left1_avartar.layer.borderWidth = 1.5
        left1_avartar.layer.masksToBounds = true
        
        left2_avartar.layer.cornerRadius = left2_avartar.bounds.width / 2
        left2_avartar.layer.borderColor = Constants.avartar_color_red.cgColor
        left2_avartar.layer.borderWidth = 1.5
        left2_avartar.layer.masksToBounds = true
        
    }
    
    @IBAction func largeButtonToEdit(_ sender: Any) {
        self.editButtonClicked(sender)
    }
    @IBAction func editButtonClicked(_ sender: Any) {
        let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "PartyProfileEditViewController") as! PartyProfileEditViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func moreButtonClicked(_ sender: Any) {
        moreButtonTapped()
    }
    
    func moreButtonTapped(){
        let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "MoreItemsViewController") as! MoreItemsViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func loadProfileDataFromLocal(){
        left2_avartar.image = UIImage(named: "nav_profile_inactive")
        left1_avartar.image = UIImage(named: "nav_profile_inactive")
        center_avartar.image = UIImage(named: "nav_profile_inactive")
        if UserDefaults.standard.string(forKey: "partymodeOFFImageSaved") == "YES" {
            left2_avartar.image = SaveLoadImageToLocalClass().getImage(imageNameWithExt: "partymodeOFF.jpg")
        }
        if UserDefaults.standard.string(forKey: "partymodePendingImageSaved") == "YES" {
            left1_avartar.image = SaveLoadImageToLocalClass().getImage(imageNameWithExt: "partymodePending.jpg")
        }
        if UserDefaults.standard.string(forKey: "partymodeONImageSaved") == "YES" {
            center_avartar.image = SaveLoadImageToLocalClass().getImage(imageNameWithExt: "partymodeON.jpg")
        }
        
        let defaults = UserDefaults.standard
        if let partyname = defaults.string(forKey: "partyname"){
            self.partyname.text = partyname
        }
        if let firstname = defaults.string(forKey: "firstname"), let lastname = defaults.string(forKey: "lastname"){
            self.username.text = "\(firstname) \(lastname)"
        }
        if let address = defaults.string(forKey: "address"){
            self.homecityValueLabel.text = address
            self.showHomecityTowColumnValueLabel()
        }
        if let birthday = defaults.string(forKey: "birthday"){
            self.birthdayValueLabel.text = birthday
            showBirthdayTowColumnValueLabel()
        }
        if let email = defaults.string(forKey: "email"){
            self.mailaddressValueLabel.text = email
            showMailaddressTowColumnValueLabel()
        }
        
        if UserDefaults.standard.object(forKey: "gender") != nil {
            let gender_int = defaults.integer(forKey: "gender")
            if gender_int == Constants.SP_PROFILE_GENDER_FEMALE {
                genderValueLabel.text = NSLocalizedString("female", comment: "")//"Female"
                showGenderTowColumnValueLabel()
            }
            else if gender_int == Constants.SP_PROFILE_GENDER_MALE{
                genderValueLabel.text = NSLocalizedString("male", comment: "")//"Male"
                showGenderTowColumnValueLabel()
            }
        }
        
        
        
//        if gender.text?.characters.count == 0 || gender.text == NSLocalizedString("gender", comment: ""){
//            gender.text = NSLocalizedString("gender", comment: "")
//            gender.textColor = UIColor.lightGray
//        }
//        if birthday.text?.characters.count == 0 {
//            birthday.text = NSLocalizedString("birthday", comment: "")
//            birthday.textColor = UIColor.lightGray
//        }
//        if homecity.text?.characters.count == 0 {
//            homecity.text = NSLocalizedString("address", comment: "")
//            homecity.textColor = UIColor.lightGray
//        }
//        if mailaddress.text?.characters.count == 0 {
//            mailaddress.text = NSLocalizedString("emailaddress", comment: "")
//            mailaddress.textColor = UIColor.lightGray
//        }
        
        
        
        
    }
}
