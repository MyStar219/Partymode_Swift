//
//  PartyProfileEditViewController.swift
//  partymode
//
//  Created by Nikita on 1/15/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit
import Photos
import TOCropViewController
class PartyProfileEditViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate, UIAlertViewDelegate,UINavigationControllerDelegate, TOCropViewControllerDelegate {

    @IBOutlet weak var button_addPic_partymodeOFF: UIButton!
    @IBOutlet weak var button_addPic_pending: UIButton!
    @IBOutlet weak var button_addPic_partymodeON: UIButton!
    
    @IBOutlet weak var button_gender_female: UIButton!
    @IBOutlet weak var button_gender_male: UIButton!
    
    var datePicker : UIDatePicker!
    
    @IBOutlet weak var birthTextField: UITextField!
    @IBOutlet weak var partyNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var homeCityTextField: UITextField!
    @IBOutlet weak var mailAddressTextField: UITextField!
    
    @IBOutlet weak var partymodeOFFLabel: UILabel!
    @IBOutlet weak var partymodeONLabel: UILabel!
    @IBOutlet weak var partymodePendingLabel: UILabel!
    
    @IBOutlet weak var partyname_expalinLabel: UILabel!
    @IBOutlet weak var enterData_explainLabel: UILabel!
    @IBOutlet weak var female_Label: UITextField!
    @IBOutlet weak var male_Label: UITextField!
    
    
    var whichButtonPressed:String!
    var selectedGender = -1//"Female"
    var base64String_profile_pic_off = ""
    var base64String_profile_pic_pending = ""
    var base64String_profile_pic_on = ""
    
    
    var birthday_timestamp:Int!
    
    
    var picker:UIImagePickerController?=UIImagePickerController()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfGotoHomeView(_:)), name:NSNotification.Name(rawValue: "notificationId_gotoPartyPeopleTab"), object: nil)
    }
    func methodOfGotoHomeView(_ notification: Notification){
        //Take Action on Notification
        _ = navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set("false", forKey: "shouldgotoPartypeopleTab")
        setupRightItemButton()
        birthday_timestamp = 0
        
        self.title = NSLocalizedString("editpartyprofile", comment: "")
        partymodeOFFLabel.text = NSLocalizedString("partymodeoff", comment: "")
        partymodeONLabel.text = NSLocalizedString("partymodeon", comment: "")
        partymodePendingLabel.text = NSLocalizedString("modepending", comment: "")
        
        partyNameTextField.placeholder = NSLocalizedString("partyname", comment: "")
        firstNameTextField.placeholder = NSLocalizedString("firstname", comment: "")
        lastNameTextField.placeholder = NSLocalizedString("lastname", comment: "")
        female_Label.text = NSLocalizedString("female", comment: "")
        male_Label.text = NSLocalizedString("male", comment: "")
        birthTextField.placeholder = NSLocalizedString("birthday", comment: "")
        homeCityTextField.placeholder = NSLocalizedString("address", comment: "")
        mailAddressTextField.placeholder = NSLocalizedString("emailaddress", comment: "")
        enterData_explainLabel.text = NSLocalizedString("provideyourdata", comment: "")
        partyname_expalinLabel.text = NSLocalizedString("partynamedescription", comment: "")
        
        self.automaticallyAdjustsScrollViewInsets = false
        navigationController?.navigationBar.barTintColor = Constants.tab_color_partyprofile
        self.navigationController?.navigationBar.isHidden = false
        ButtonsStyle()
        self.pickUpDate(self.birthTextField)
        self.loadProfileDataFromLocal()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupRightItemButton(){
        self.navigationItem.rightBarButtonItem  = nil
        let button1 = UIBarButtonItem(image: UIImage(named: "ico-check"), style: .plain, target: self, action:#selector(self.navigationBarRightCheckButtonTapped))
        self.navigationItem.rightBarButtonItem  = button1
    }
    func navigationBarRightCheckButtonTapped(){
        
//        if checkIfEmpty() == true {
//            AlertClass().showAlert(sender: self, title: "", msg: "Please fill in the form")
//        }
//        else{
            self.saveProfileDataInLocal(completionHandler: {(post) -> Void in
                
            })
            
            SendProfileAPICall().request(self, partyname: partyNameTextField.text!, firstname: firstNameTextField.text!, lastname: lastNameTextField.text!, address: homeCityTextField.text!, email: mailAddressTextField.text!, birthdayStamp: birthday_timestamp, birthdayText: birthTextField.text!, gender: selectedGender, img_pending: base64String_profile_pic_pending, img_on: base64String_profile_pic_on, img_off: base64String_profile_pic_off, completionHandler: {(post) -> Void in
                _ = self.navigationController?.popViewController(animated: true)
            })
//        }
        
    }

    @IBAction func partymodeOFFButtonPressed(_ sender: Any) {
        whichButtonPressed = "Off"
        self.selectImageCategory()
    }
    
    @IBAction func pendingButtonPressed(_ sender: Any) {
        whichButtonPressed = "Pending"
        self.selectImageCategory()
    }
    
    @IBAction func partymodeONButtonPressed(_ sender: Any) {
        whichButtonPressed = "On"
        self.selectImageCategory()
    }
    
    @IBAction func femaleButtonPressed(_ sender: Any) {
        self.selectedGender = Constants.SP_PROFILE_GENDER_FEMALE//"Female"
        button_gender_female.backgroundColor = Constants.color_gender_check_background
        button_gender_male.backgroundColor = UIColor.white
    }
    
    @IBAction func maleButtonPressed(_ sender: Any) {
        self.selectedGender =  Constants.SP_PROFILE_GENDER_MALE//"Male"
        button_gender_male.backgroundColor = Constants.color_gender_check_background
        button_gender_female.backgroundColor = UIColor.white
    }
    
    func ButtonsStyle(){
        button_addPic_partymodeON.layer.cornerRadius = button_addPic_partymodeON.bounds.width / 2
        button_addPic_partymodeON.layer.borderColor = Constants.avartar_color_green.cgColor
        button_addPic_partymodeON.layer.borderWidth = 3
        button_addPic_partymodeON.layer.masksToBounds = true
        
        button_addPic_pending.layer.cornerRadius = button_addPic_pending.bounds.width / 2
        button_addPic_pending.layer.borderColor = Constants.avartar_color_black.cgColor
        button_addPic_pending.layer.borderWidth = 3
        button_addPic_pending.layer.masksToBounds = true
        
        button_addPic_partymodeOFF.layer.cornerRadius = button_addPic_partymodeOFF.bounds.width / 2
        button_addPic_partymodeOFF.layer.borderColor = Constants.avartar_color_red.cgColor
        button_addPic_partymodeOFF.layer.borderWidth = 3
        button_addPic_partymodeOFF.layer.masksToBounds = true
        
        button_gender_female.layer.cornerRadius = button_gender_female.bounds.width / 2
        button_gender_female.layer.borderColor = Constants.avartar_color_black.cgColor
        button_gender_female.layer.borderWidth = 0.7
        button_gender_female.layer.masksToBounds = true
        
        button_gender_male.layer.cornerRadius = button_gender_female.bounds.width / 2
        button_gender_male.layer.borderColor = Constants.avartar_color_black.cgColor
        button_gender_male.layer.borderWidth = 0.7
        button_gender_male.layer.masksToBounds = true
        
    }
    func selectImageCategory(){
        let alert:UIAlertController=UIAlertController(title: NSLocalizedString("image_content_description", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cameraAction = UIAlertAction(title: NSLocalizedString("camera", comment: ""), style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openCamera()
            
        }
        let gallaryAction = UIAlertAction(title: NSLocalizedString("fromgallery", comment: ""), style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
            
        }
        
        // Add the actions
        picker?.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            self.present(alert, animated: true, completion: nil)
            //popover=UIPopoverController(contentViewController: alert)
            //popover!.present(from: userImageButton.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }
    func openCamera()
    {
        let assetType = Demo.types[1]
        let allowMultipleType = true//!(indexPath.row == 0 && indexPath.section == 3)
        let sourceType: DKImagePickerControllerSourceType = .camera
        let allowsLandscape = true
        let singleSelect = false
        
        showImagePickerWithAssetType(
            assetType,
            allowMultipleType: allowMultipleType,
            sourceType: sourceType,
            allowsLandscape: allowsLandscape,
            singleSelect: singleSelect
        )
        
    }
    func openGallary()
    {
        let assetType = Demo.types[1]
        let allowMultipleType = true//!(indexPath.row == 0 && indexPath.section == 3)
        let sourceType: DKImagePickerControllerSourceType = .both
        let allowsLandscape = true
        let singleSelect = true
        
        showImagePickerWithAssetType(
            assetType,
            allowMultipleType: allowMultipleType,
            sourceType: sourceType,
            allowsLandscape: allowsLandscape,
            singleSelect: singleSelect
        )
        
    }
    struct Demo {
        static let titles = [
            ["Pick All", "Pick photos only", "Pick videos only", "Pick All (only photos or videos)"],
            ["Take a picture"],
            ["Hides camera"],
            ["Allows landscape"],
            ["Single select"]
        ]
        static let types: [DKImagePickerControllerAssetType] = [.allAssets, .allPhotos, .allVideos, .allAssets]
    }
    func showImagePickerWithAssetType(_ assetType: DKImagePickerControllerAssetType,
                                      allowMultipleType: Bool,
                                      sourceType: DKImagePickerControllerSourceType = .both,
                                      allowsLandscape: Bool,
                                      singleSelect: Bool) {
        
        let pickerController = DKImagePickerController()
        
        // Custom camera
        //		pickerController.UIDelegate = CustomUIDelegate()
        //		pickerController.modalPresentationStyle = .OverCurrentContext
        
        pickerController.assetType = assetType
        pickerController.allowsLandscape = allowsLandscape
        pickerController.allowMultipleTypes = allowMultipleType
        pickerController.sourceType = sourceType
        pickerController.singleSelect = singleSelect
        
        pickerController.maxSelectableCount = 1
        pickerController.showsCancelButton = true
        pickerController.showsEmptyAlbums = false
        pickerController.defaultAssetGroup = PHAssetCollectionSubtype.smartAlbumFavorites
        
        // Clear all the selected assets if you used the picker controller as a single instance.
        pickerController.defaultSelectedAssets = nil
        
        //pickerController.defaultSelectedAssets = self.assets
        
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            
            for asset in assets {
                asset.fetchOriginalImage(true){
                    (image:UIImage?, info:[AnyHashable: Any]?) in
                    
                    
                    
                    if image != nil
                    {
                        let cropController:TOCropViewController = TOCropViewController(croppingStyle: TOCropViewCroppingStyle.circular, image: image!)
                        cropController.delegate=self
                        //self.navigationController?.pushViewController(cropController, animated: true)
                        self.present(cropController, animated: true, completion: nil)
                    }
                    
                }
                
                
            }
            
        }
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            pickerController.modalPresentationStyle = .formSheet
        }
        
        self.present(pickerController, animated: true) {}
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: { () -> Void in })
    }
    
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
    //        Cropper Delegate
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int)
    {
        cropViewController.dismiss(animated: true) { () -> Void in
            var selectedImage : UIImage = image
            selectedImage = self.resizeImage(selectedImage, newWidth: 64)
            
            if self.whichButtonPressed == "Off" {
                self.button_addPic_partymodeOFF.setImage(selectedImage, for: UIControlState.normal)
                self.base64String_profile_pic_off = Base64Util().convertToBase64(selectedImage)
            }
            else if self.whichButtonPressed == "Pending" {
                self.button_addPic_pending.setImage(selectedImage, for: UIControlState.normal)
                self.base64String_profile_pic_pending = Base64Util().convertToBase64(selectedImage)
            }
            else if self.whichButtonPressed == "On" {
                self.button_addPic_partymodeON.setImage(selectedImage, for: UIControlState.normal)
                self.base64String_profile_pic_on = Base64Util().convertToBase64(selectedImage)
            }
            
            //let filename:String = self.usernameTextField.text!.replacingOccurrences(of: " ", with: "_") + "_profile.jpg"
            
        }
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool)
    {
        cropViewController.dismiss(animated: true) { () -> Void in  }
    }
    
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        return newImage!
    }
    
    func pickUpDate(_ textField : UITextField){
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        self.datePicker.datePickerMode = UIDatePickerMode.date
        textField.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = Constants.tab_color_partyprofile
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: NSLocalizedString("done", comment: ""), style: .plain, target: self, action: #selector(self.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("cancel", comment: ""), style: .plain, target: self, action: #selector(self.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
        
        let currentDate = Date()
        self.datePicker.maximumDate = currentDate
        
        let dateString = "1990-01-01"
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let date = df.date(from: dateString)
        if let unwrappedDate = date {
            self.datePicker.setDate(unwrappedDate, animated: false)
        }
    }
    // MARK:- Button Done and Cancel
    func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "dd.MM.yyyy"//"yyyy-MM-dd"
        //dateFormatter1.dateStyle = .MediumStyle
        //dateFormatter1.timeStyle = .NoStyle
        birthTextField.text = dateFormatter1.string(from: datePicker.date)
        birthTextField.resignFirstResponder()
        birthday_timestamp = Int(TimeStampClass().convertToTimestamp(date: datePicker.date))!
    }
    func cancelClick() {
        birthTextField.resignFirstResponder()
    }
    
    func checkIfEmpty() -> Bool{
        if birthTextField.text == "" || partyNameTextField.text == "" || firstNameTextField.text == "" || lastNameTextField.text == "" || homeCityTextField.text == "" || mailAddressTextField.text == "" {
            
            return true
        }
        else {
            return false
        }
    }
    
    func saveProfileDataInLocal(completionHandler: @escaping () -> Void){
        let defaults = UserDefaults.standard
        defaults.set(partyNameTextField.text!, forKey: "partyname")
        defaults.set(firstNameTextField.text!, forKey: "firstname")
        defaults.set(lastNameTextField.text!, forKey: "lastname")
        defaults.set(homeCityTextField.text!, forKey: "address")
        defaults.set(birthTextField.text!, forKey: "birthday")
        defaults.set(birthday_timestamp, forKey: "birthdayTimeStamp")
        defaults.set(mailAddressTextField.text!, forKey: "email")
        defaults.set(selectedGender, forKey: "gender")
        defaults.synchronize()
        
        if base64String_profile_pic_off != "" {
            SaveLoadImageToLocalClass().saveImageDocumentDirectory(image: button_addPic_partymodeOFF.image(for: UIControlState.normal)!, imageNameWithExt: "partymodeOFF.jpg")
            UserDefaults.standard.set("YES", forKey: "partymodeOFFImageSaved")
        }
        if base64String_profile_pic_pending != "" {
            SaveLoadImageToLocalClass().saveImageDocumentDirectory(image: button_addPic_pending.image(for: UIControlState.normal)!, imageNameWithExt: "partymodePending.jpg")
            UserDefaults.standard.set("YES", forKey: "partymodePendingImageSaved")
        }
        if base64String_profile_pic_on != "" {
            SaveLoadImageToLocalClass().saveImageDocumentDirectory(image: button_addPic_partymodeON.image(for: UIControlState.normal)!, imageNameWithExt: "partymodeON.jpg")
            UserDefaults.standard.set("YES", forKey: "partymodeONImageSaved")
        }
        completionHandler()

    }
    
    func loadProfileDataFromLocal(){
        let defaults = UserDefaults.standard
        if let partyname = defaults.string(forKey: "partyname"){
            self.partyNameTextField.text = partyname
        }
        if let firstname = defaults.string(forKey: "firstname"){
            self.firstNameTextField.text = firstname
        }
        if let lastname = defaults.string(forKey: "lastname"){
            self.lastNameTextField.text = lastname
        }
        if let address = defaults.string(forKey: "address"){
            self.homeCityTextField.text = address
        }
        if let birthday = defaults.string(forKey: "birthday"){
            self.birthTextField.text = birthday
            self.birthday_timestamp = defaults.integer(forKey: "birthdayTimeStamp")
        }
        
        if let email = defaults.string(forKey: "email"){
            self.mailAddressTextField.text = email
        }
        
        if defaults.object(forKey: "gender") != nil {
            let gender_int = defaults.integer(forKey: "gender")
            if gender_int == Constants.SP_PROFILE_GENDER_FEMALE {
                self.femaleButtonPressed(self)
            }
            else if gender_int == Constants.SP_PROFILE_GENDER_MALE{
                self.maleButtonPressed(self)
            }
        }
        
        self.button_addPic_partymodeOFF.setImage(SaveLoadImageToLocalClass().getImage(imageNameWithExt: "partymodeOFF.jpg"), for: UIControlState.normal)
        self.button_addPic_pending.setImage(SaveLoadImageToLocalClass().getImage(imageNameWithExt: "partymodePending.jpg"), for: UIControlState.normal)
        self.button_addPic_partymodeON.setImage(SaveLoadImageToLocalClass().getImage(imageNameWithExt: "partymodeON.jpg"), for: UIControlState.normal)
        
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            // The back button was pressed or interactive gesture used
            NotificationCenter.default.post(name:Notification.Name(rawValue:"Notification_LoadProfileDataFromLocal"),
                    object: nil,
                    userInfo: nil)
            
            
            
        }
    }
    
}
