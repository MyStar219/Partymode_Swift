//
//  PicTabViewController.swift
//  partymode
//
//  Created by Nikita on 2/20/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit
import Photos
import TOCropViewController
import AlamofireImage
import Alamofire

class PicTabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate,UIPopoverControllerDelegate, UIAlertViewDelegate,UINavigationControllerDelegate, TOCropViewControllerDelegate {
    
    var chatDataArray = [PartyCrowdChatCellData]()

    @IBOutlet weak var addPicButtonView: UIView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var emptyImage: UIImageView!
    var selectedPartyCrowdItem: PartyCrowdCellData! = nil
    
    var base64String_pic = ""
    var picker:UIImagePickerController?=UIImagePickerController()
    var shouldSendMessage = false
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(PicTabViewController.methodOfReloadChatData(_:)), name:NSNotification.Name(rawValue: "notificationId_reloadChatData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfRefreshProfileImages(_:)), name:NSNotification.Name(rawValue: "notificationId_refreshContacts"), object: nil)
    }
    func methodOfReloadChatData(_ notification: Notification){
        self.chatDataArray = DBManager.getInstance().getImageChatData(self.selectedPartyCrowdItem)
        self.chatTableView.reloadData()
        UserDefaults.standard.set(0, forKey: Constants.SP_NOTIFICATION_UNREAD_MSG_COUNT)
        scrollToLastChatWithoutAnimation()//scrollToLastChat()
        self.reloadForLoadingRemoteImages()
    }
    func methodOfRefreshProfileImages(_ notification: Notification){
        self.chatTableView.reloadData()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyImage.image = UIImage(named: NSLocalizedString("imagename_empty_partycrowdpic", comment: ""))
        
        self.selectedPartyCrowdItem = GlobalData.sharedInstance.getSelectedPartyCrowdItem()
        makeAddPicButtonCircleShadow()
        self.chatDataArray = DBManager.getInstance().getImageChatData(self.selectedPartyCrowdItem)
        self.chatTableView.estimatedRowHeight = 50
        self.chatTableView.rowHeight = UITableViewAutomaticDimension
        scrollToLastChatWithoutAnimation()//scrollToLastChat()
        
        let isFromPartyHistory = UserDefaults.standard.string(forKey: "isFromPartyHistory")
        if isFromPartyHistory == "YES"{
            self.disableInterActions()
        }
        self.reloadForLoadingRemoteImages()
    }
    func reloadForLoadingRemoteImages(){
        if self.chatDataArray.count > 0 {
            for index in 0...self.chatDataArray.count - 1 {
                let each = self.chatDataArray[index]
                if each.is_img == true {
                    if let cachedImageData = DBManager.getInstance().getImageCacheData(each.msg) {
                        let cachedImage = Base64Util().decodedFromBase64(cachedImageData)
                        self.chatDataArray[index].receivedImage = cachedImage
                        self.chatTableView.reloadData()
                        self.scrollToLastChatWithoutAnimation()
                    }
                    else {
                        let when = DispatchTime.now() + 0
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            let myPhoneNr = UserDefaults.standard.string(forKey: "phone_nr")
                            if each.senderName != myPhoneNr {
                                let image_full_url = Constants.API_LINK + Constants.API_IMAGES + each.msg
                                Alamofire.request(image_full_url).responseImage { response in
                                    
                                    if let receivedImage = response.result.value {
                                        self.chatDataArray[index].receivedImage = self.resizeImage(receivedImage, newWidth: 150)//receivedImage
                                        self.chatTableView.reloadData()
                                        self.scrollToLastChatWithoutAnimation()
                                    }
                                }
                            }
                            
                        }
                    }
                }
                
            }
        }
        
    }
    
    func makeAddPicButtonCircleShadow(){
        addPicButtonView.layer.cornerRadius = addPicButtonView.bounds.width / 2
        addPicButtonView.layer.shadowColor = UIColor.gray.cgColor
        addPicButtonView.layer.shadowOpacity = 1
        addPicButtonView.layer.shadowOffset = CGSize(width: 2, height: 2)
        addPicButtonView.layer.borderWidth = 0
    }
    @IBAction func AddPicButtonPressed(_ sender: Any) {
        self.selectImageCategory()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if chatDataArray.count == 0 {
            self.emptyImage.isHidden = false
        }
        else {
            self.emptyImage.isHidden = true
        }
        return self.chatDataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eachItem = self.chatDataArray[indexPath.row]
        let cell = chatTableView.dequeueReusableCell(withIdentifier: Constants.cellId_ChatTableView, for: indexPath as IndexPath) as! ChatReceivedCell
        
        let defaults = UserDefaults.standard
        let myPhoneNr = defaults.string(forKey: "phone_nr")
        let contactItem = DBManager.getInstance().getUser(eachItem.senderName)
        if eachItem.senderName != myPhoneNr {
            //cell.myChatItem = eachItem
            cell.parentView = self
            cell.chatTextLabel.text = ""
            cell.chatImageView.image = nil
            cell.imageHeightConstraint.constant = 0
            if contactItem.name == "" {
                cell.usernameOrPhoneNumberLabel.text = eachItem.senderName
            }
            else {
                cell.usernameOrPhoneNumberLabel.text = contactItem.name//eachItem.senderName
            }
            cell.faceImage.image = contactItem.face_image//UIImage(named: "nav_profile_inactive")!
            if eachItem.is_img == true{
//                let image_full_url = Constants.API_LINK + Constants.API_IMAGES + eachItem.msg
//                let placeholder = UIImage(named: "ico_attach")
                
//                Alamofire.request(image_full_url).responseImage { response in
//                    
//                    if let image = response.result.value {
//                        print("image downloaded: \(image)")
//                        cell.chatImageView.image = image
//                        let aspectratio = (image.size.height) / (image.size.width)
//                        //cell.imageHeightConstraint.constant = cell.chatImageView.bounds.width * aspectratio
//                        
//                        cell.imageHeightConstraint.constant = 100//cell.chatImageView.bounds.height
//                    }
//                    
//                }
                
                if eachItem.receivedImage != nil {
                    let aspectratio = eachItem.receivedImage!.size.height/eachItem.receivedImage!.size.width
                    cell.imageHeightConstraint.constant = cell.chatImageView.bounds.width * aspectratio
                    cell.chatImageView.image = eachItem.receivedImage!
                }
                
            }
            else {
                cell.chatTextLabel.text = eachItem.msg
            }
            cell.sentTimeLabel.text = TimeStampClass().filterTimeStampForChat(stamp: eachItem.time, time: eachItem.time_string)
            if contactItem.pmode == Constants.PARTYMODE_NA {//pending
                makeAvatarBoderBlack(avatarImageView: (cell.faceImage))
                //cell.disablePartify()
            }
            if contactItem.pmode == Constants.PARTYMODE_OFF {//off
                makeAvatarBoderRed(avatarImageView: (cell.faceImage))
                //cell.disablePartify()
            }
            if contactItem.pmode == Constants.PARTYMODE_ON {//on
                makeAvatarBoderGreen(avatarImageView: (cell.faceImage))
                //cell.enblePartify()
            }
            
        }
        else {
            let cell2 = chatTableView.dequeueReusableCell(withIdentifier: Constants.cellId_ChatTableSentView, for: indexPath as IndexPath) as! ChatSentCell
            //cell2.myChatItem = eachItem
            //cell2.arrayCount = self.chatDataArray.count
            cell2.parentView = self
            cell2.chatTextLabel.text = ""
            cell2.chatImageView.image = nil
            cell2.imageHeightConstraint.constant = 0
            
            cell2.selfIndex = indexPath.row
            if contactItem.name == "" {
                cell2.usernameOrPhoneNumberLabel.text = "  " + NSLocalizedString("me", comment: "")//eachItem.senderName
            }
            else {
                cell2.usernameOrPhoneNumberLabel.text = contactItem.name//eachItem.senderName
            }
            cell2.selfSizingUserNameWidth()
            cell2.faceImage.image = contactItem.face_image//UIImage(named: "nav_profile_inactive")!
            let partymode = UserDefaults.standard.integer(forKey: Constants.SP_PARTYMODE)
            if partymode == Constants.PARTYMODE_NA {//pending
                if UserDefaults.standard.string(forKey: "partymodePendingImageSaved") == "YES" {
                    cell2.faceImage.image = SaveLoadImageToLocalClass().getImage(imageNameWithExt: "partymodePending.jpg")
                }
                makeAvatarBoderBlack(avatarImageView: (cell2.faceImage))
            }
            if partymode == Constants.PARTYMODE_OFF {//off
                if UserDefaults.standard.string(forKey: "partymodeOFFImageSaved") == "YES" {
                    cell2.faceImage.image = SaveLoadImageToLocalClass().getImage(imageNameWithExt: "partymodeOFF.jpg")
                    makeAvatarBoderRed(avatarImageView: (cell2.faceImage))
                }
            }
            if partymode == Constants.PARTYMODE_ON {//on
                if UserDefaults.standard.string(forKey: "partymodeONImageSaved") == "YES" {
                    cell2.faceImage.image = SaveLoadImageToLocalClass().getImage(imageNameWithExt: "partymodeON.jpg")
                }
                makeAvatarBoderGreen(avatarImageView: (cell2.faceImage))
            }
            
            if eachItem.is_img == true{
                let sentImage = Base64Util().decodedFromBase64(eachItem.msg)
                
                let aspectratio = sentImage.size.height/sentImage.size.width
                cell2.imageHeightConstraint.constant = cell2.chatImageView.bounds.width * aspectratio
                cell2.chatImageView.image = sentImage

            }
            else {
                cell2.chatTextLabel.text = eachItem.msg
            }
            if eachItem.delivered == Constants.CROWD_MSG_DELIVERED_SUCCESS {
                cell2.sentTimeLabel.isHidden = false
                cell2.hideSendingActivityIndicator()
            }
            else {
                cell2.sentTimeLabel.isHidden = true
                cell2.showErrorImage()
            }
            cell2.sentTimeLabel.text = TimeStampClass().filterTimeStampForChat(stamp: eachItem.time, time: eachItem.time_string)
            
            if indexPath.row == self.chatDataArray.count - 1 { //cell2.sentTimeLabel.isHidden == true
                if  shouldSendMessage == true{
                    self.shouldSendMessage = false
                    cell2.showSendingAcitivityIndicator()
                    SendMsgToCrowdAPICall().request(id: eachItem.crowdId, isimg: eachItem.is_img, msg: eachItem.msg, completionHandler: {(result) -> Void in
                        
                        if result != 0 {
                            cell2.hideSendingActivityIndicator()
                            let newItem: PartyCrowdChatCellData! = PartyCrowdChatCellData(message_id:eachItem.time, crowdId: eachItem.crowdId, senderName: eachItem.senderName, msg: eachItem.msg, is_img: eachItem.is_img, time: result, delivered: Constants.CROWD_MSG_DELIVERED_SUCCESS, time_string: eachItem.time_string)
                            self.updateMessageFromDB(newMsg: newItem)
                            cell2.sentTimeLabel.text = TimeStampClass().filterTimeStampForChat(stamp: result, time: eachItem.time_string)
                            cell2.sentTimeLabel.isHidden = false
                            self.chatTableView.reloadData()
                            
                        }
                        else {
                            cell2.sentTimeLabel.isHidden = true
                            cell2.showErrorImage()
                        }
                        self.scrollToLastMessage()
                        
                    })
                }
                
            }
            
            
            return cell2
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    @IBAction func attachButtonPressed(_ sender: Any) {
        self.selectImageCategory()
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
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
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
                        var resizedImage = image!.fixOrientation()
                        //let resizedImage = self.resizeImage(image!, newWidth: 128)
                        print(resizedImage.size.width)
                        if resizedImage.size.width > 500 {
                            resizedImage = self.resizeImage(image!, newWidth: 500)
                        }
                        //let resizedImage = self.resizeImage(image!, newWidth: 128)
                        print(resizedImage.size.width)
                        self.base64String_pic = Base64Util().convertToBase64(resizedImage)
                        self.sendPic()
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
    
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func sendPic(){
        let selectedPartyCrowdItem: PartyCrowdCellData! = GlobalData.sharedInstance.getSelectedPartyCrowdItem()
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy/MM/dd HH:mm"
        let current_date:Date = NSDate() as Date
        let current_date_string = dateFormatter1.string(from: current_date)
        
        
        let sent_timestamp = Int(TimeStampClass().convertToTimestamp(date: current_date))!
        
        let defaults = UserDefaults.standard
        let myPhoneNr = defaults.string(forKey: "phone_nr")
        
        let newItem: PartyCrowdChatCellData!
        
        newItem = PartyCrowdChatCellData(message_id: sent_timestamp, crowdId: selectedPartyCrowdItem.id, senderName: myPhoneNr!, msg: self.base64String_pic, is_img: true, time: sent_timestamp, delivered: Constants.CROWD_MSG_DELIVERED_FAILED, time_string: current_date_string)
        
        shouldSendMessage = true
        self.insertMessageToDB(newMsg: newItem)
        self.chatTableView.reloadData()
        Thread.sleep(forTimeInterval: 0.4)
        self.scrollToLastMessage()
        scrollToLastChatWithoutAnimation()//scrollToLastChat()
    }
    func insertMessageToDB(newMsg:PartyCrowdChatCellData){
        self.chatDataArray.append(newMsg)
        let isInserted = DBManager.getInstance().addChatData(newMsg)
        if isInserted {
            print("new chat item inserted to db successfully")
        } else {
            print("new chat insert failed")
        }
        
        
    }
    func updateMessageFromDB(newMsg: PartyCrowdChatCellData){
        self.chatDataArray.removeLast()
        self.chatDataArray.append(newMsg)
        let isUpdated = DBManager.getInstance().updateChatData(newMsg)
        if isUpdated {
            print("new chat item Updated to db successfully")
        } else {
            print("new chat Updated failed")
        }
    }
    func scrollToLastMessage(){
        let numberOfSections = self.chatTableView.numberOfSections
        let numberOfRows = self.chatTableView.numberOfRows(inSection: numberOfSections-1)
        
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows - 1, section: (numberOfSections-1))
            self.chatTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
        }
    }
    func scrollToLastChat(){
        let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            //scrolling to bottom in tableview
            let numberOfSections = self.chatTableView.numberOfSections
            let numberOfRows = self.chatTableView.numberOfRows(inSection: numberOfSections-1)
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.chatTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
            }
        }
    }
    func scrollToLastChatWithoutAnimation(){
        let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            //scrolling to bottom in tableview
            let numberOfSections = self.chatTableView.numberOfSections
            let numberOfRows = self.chatTableView.numberOfRows(inSection: numberOfSections-1)
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.chatTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
            }
        }
    }

    func makeAvatarBoderGreen(avatarImageView: UIImageView){
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.layer.borderColor = Constants.avartar_color_green.cgColor
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.layer.masksToBounds = true
    }
    func makeAvatarBoderBlack(avatarImageView: UIImageView){
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.layer.borderColor = Constants.avartar_color_black.cgColor
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.layer.masksToBounds = true
    }
    func makeAvatarBoderRed(avatarImageView: UIImageView){
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.layer.borderColor = Constants.avartar_color_red.cgColor
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.layer.masksToBounds = true
    }
    func disableInterActions(){
        self.addPicButtonView.isHidden = true
    }
}
