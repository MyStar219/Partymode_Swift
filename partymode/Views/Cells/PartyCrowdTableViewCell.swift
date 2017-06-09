//
//  PartyCrowdTableViewCell.swift
//  partymode
//
//  Created by Nikita on 1/18/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class PartyCrowdTableViewCell: UITableViewCell {
    
    @IBOutlet weak var partyname: UILabel!
    @IBOutlet weak var partyCreatorName: UILabel!
    @IBOutlet weak var partyTime: UILabel!
    @IBOutlet weak var partyLocation: UILabel!
    @IBOutlet weak var crowdswitch: UISwitch!
    @IBOutlet weak var editImage: UIImageView!
    @IBOutlet weak var transparentEditButton: UIButton!
    @IBOutlet weak var reactivateButton: UIButton!
    @IBOutlet weak var pending_switch_ImageView: UIImageView!
    
    var parentView: UIViewController!
    
    var eachData: PartyCrowdCellData! = nil
    var selfIndex: Int! = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setSwitchStyle()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func editButtonPressed(_ sender: Any) {
        UserDefaults.standard.set("false", forKey: "shouldgotoPartypeopleTab")
        let viewController =  parentView.storyboard?.instantiateViewController(withIdentifier: "CreatePartyCrowdViewController") as! CreatePartyCrowdViewController
        viewController.temp_createdPartyCrowdItem = eachData
        //viewController.shouldGoForward = true
        viewController.shouldGoToEdit = true
        GlobalData.sharedInstance.setSelectedPartyCrowdItem(eachData)
        parentView.navigationController?.pushViewController(viewController, animated: false)
    }
    
    @IBAction func reActivateButtonPressed(_ sender: Any) {
        UserDefaults.standard.set("false", forKey: "shouldgotoPartypeopleTab")
        let viewController =  parentView.storyboard?.instantiateViewController(withIdentifier: "CreatePartyCrowdViewController") as! CreatePartyCrowdViewController
        viewController.temp_createdPartyCrowdItem = eachData
        //viewController.shouldGoForward = true
        //viewController.shouldGoToEdit = true
        viewController.shouldBeReactivate = true
        UserDefaults.standard.set("true", forKey: "shouldBeReactivate")
        GlobalData.sharedInstance.setSelectedPartyCrowdItem(eachData)
        parentView.navigationController?.pushViewController(viewController, animated: false)
    }
    @IBAction func switchTouchEvent(_ sender: UISwitch) {
        if sender.isOn {
//            crowdswitch.backgroundColor = Constants.color_switch_on
//            GlobalData.sharedInstance.addSelectedPartyCrowdMemberToArray(eachData)
        }
        else {
//            crowdswitch.backgroundColor = Constants.color_switch_off
//            GlobalData.sharedInstance.removeSelectedPartyCrowdMemberFromArray(eachData)
        }
    }
    func setSwitchStyle(){
        crowdswitch.layer.cornerRadius = 17
        crowdswitch.tintColor = UIColor.clear
        crowdswitch.backgroundColor = Constants.color_switch_off
        crowdswitch.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)//CGAffineTransform(scaleX: 0.7, y: 0.7);
        crowdswitch.setOn(false, animated: false)
    }
    func showEditButton(){
        crowdswitch.isHidden = true
        editImage.isHidden = false
        transparentEditButton.isHidden = false
        reactivateButton.isHidden = true
        pending_switch_ImageView.isHidden = true
        
    }
    func showReactivateButton(){
        crowdswitch.isHidden = true
        editImage.isHidden = true
        transparentEditButton.isHidden = true
        reactivateButton.isHidden = false
        pending_switch_ImageView.isHidden = true
    }
    func hideReactivateButton(){
        crowdswitch.isHidden = true
        editImage.isHidden = true
        transparentEditButton.isHidden = true
        reactivateButton.isHidden = true
        pending_switch_ImageView.isHidden = true
    }
    
    func showSwitch_On(){
        reactivateButton.isHidden = true
        editImage.isHidden = true
        transparentEditButton.isHidden = true
        crowdswitch.isHidden = false
        crowdswitch.setOn(true, animated:false)
        pending_switch_ImageView.isHidden = true
    }
    func showSwitch_Off(){
        reactivateButton.isHidden = true
        editImage.isHidden = true
        transparentEditButton.isHidden = true
        crowdswitch.isHidden = false
        crowdswitch.setOn(false, animated:false)
        pending_switch_ImageView.isHidden = true
    }
    func showSwitch_Pending(){
        reactivateButton.isHidden = true
        editImage.isHidden = true
        transparentEditButton.isHidden = true
        crowdswitch.isHidden = true
        pending_switch_ImageView.isHidden = false
    }
}
