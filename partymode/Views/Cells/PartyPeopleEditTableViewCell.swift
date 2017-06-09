//
//  PartyPeopleEditTableViewCell.swift
//  partymode
//
//  Created by Nikita on 1/18/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit
protocol PartypeopleEditCellDelegate: class {
    func moveToBlockLists(item: PartyPeopleCellData, indexOfArray:Int)
    func moveToVisibleLists(item: PartyPeopleCellData, indexOfArray:Int)
    
}

class PartyPeopleEditTableViewCell: UITableViewCell {
    weak var delegate: PartypeopleEditCellDelegate?
    @IBOutlet weak var visibleStatusButton: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var notificationStatusButton: UIButton!
    @IBOutlet weak var phonenumberLabel: UILabel!
    var notificatinStatus = true
    var eachData: PartyPeopleCellData! = nil
    var selfIndex: Int! = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImage.contentMode = UIViewContentMode.scaleAspectFill
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func visibleStatusButtonPressed(_ sender: Any) {
        if eachData.user_state == Constants.STATE_PM_USER {//visible status
            let user_state = Constants.STATE_BLOCKED
            BlockContactAPICall().request(phone_nr: eachData.phonenumber, user_state: user_state, completionHandler: {(post) -> Void in
                if post == "success" {
                    print("This user is gonna move to blocked list")
                    let updatedItem = PartyPeopleCellData(image: self.eachData.face_image, name_string: self.eachData.name, phonenumber: self.eachData.phonenumber, pmode: self.eachData.pmode, img_off_lc: self.eachData.img_off_lc, img_on_lc: self.eachData.img_on_lc, img_pending_lc: self.eachData.img_pending_lc, user_state: user_state)
                    
                    self.eachData = updatedItem
                    self.delegate?.moveToBlockLists(item: self.eachData, indexOfArray: self.selfIndex)
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_updatePartyPeopleOriginalArray"), object: self.eachData)
                }
            })
        }
        else {//blocked status
            let user_state = Constants.STATE_PM_USER
            BlockContactAPICall().request(phone_nr: eachData.phonenumber, user_state: user_state, completionHandler: {(post) -> Void in
                if post == "success" {
                    print("This user is gonna move to blocked list")
                    let updatedItem = PartyPeopleCellData(image: self.eachData.face_image, name_string: self.eachData.name, phonenumber: self.eachData.phonenumber, pmode: self.eachData.pmode, img_off_lc: self.eachData.img_off_lc, img_on_lc: self.eachData.img_on_lc, img_pending_lc: self.eachData.img_pending_lc, user_state: user_state)
                    self.eachData = updatedItem
                    self.delegate?.moveToVisibleLists(item: self.eachData, indexOfArray: self.selfIndex)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_updatePartyPeopleOriginalArray"), object: self.eachData)
                }
            })
        }
    }
    
    @IBAction func notificationStatusButtonPressed(_ sender: Any) {
        if notificatinStatus == true {
            let isUpdated = DBManager.getInstance().setNotificationInfo(self.eachData.phonenumber, status: Constants.NOTIFICATION_FALSE)
            self.changeTodisabledNotificationIcon()
            
        }
        else {
            let isUpdated = DBManager.getInstance().setNotificationInfo(self.eachData.phonenumber, status: Constants.NOTIFICATION_TRUE)
            self.changeToEnabledNotificationIcon()
            
        }
        
    }

    func changeToBlockStatusIcon(){
        visibleStatusButton.setImage(UIImage(named: "ico_blocked")!, for: UIControlState.normal)
    }
    
    func changeToVisibleStatusIcon(){
        visibleStatusButton.setImage(UIImage(named: "ico_visible")!, for: UIControlState.normal)
    }
    func hiddenNotificationStatusButton(){
        notificationStatusButton.isHidden = true
        
    }
    func showNotificationStatusButton(){
        notificationStatusButton.isHidden = false
        
    }
    func changeToEnabledNotificationIcon(){
        notificationStatusButton.setImage(UIImage(named: "ico_add_notification")!, for: UIControlState.normal)
        notificatinStatus = true
        
    }
    func changeTodisabledNotificationIcon(){
        notificationStatusButton.setImage(UIImage(named: "ico_delete_notification")!, for: UIControlState.normal)
        notificatinStatus = false
        
    }
    
}
