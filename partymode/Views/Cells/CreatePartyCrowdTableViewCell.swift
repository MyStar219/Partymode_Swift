//
//  CreatePartyCrowdTableViewCell.swift
//  partymode
//
//  Created by Nikita on 2/9/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class CreatePartyCrowdTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var phonenumberLabel: UILabel!
    @IBOutlet weak var crowdswitch: UISwitch!
    var eachData: PartyPeopleCellData! = nil
    var selfIndex: Int! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImage.contentMode = UIViewContentMode.scaleAspectFill
        self.setSwitchStyle()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func switchTouchEvent(_ sender: UISwitch) {
        if sender.isOn {
            //crowdswitch.backgroundColor = Constants.color_switch_on
            GlobalData.sharedInstance.addSelectedPartyCrowdMemberToArray(eachData)
        }
        else {
            //crowdswitch.backgroundColor = Constants.color_switch_off
            GlobalData.sharedInstance.removeSelectedPartyCrowdMemberFromArray(eachData)
        }
    }
    
    func setSwitchStyle(){
        crowdswitch.layer.cornerRadius = 17
        crowdswitch.tintColor = UIColor.clear
        crowdswitch.backgroundColor = Constants.color_switch_off
        crowdswitch.transform = CGAffineTransform(scaleX: 0.9, y: 0.9);//CGAffineTransform(scaleX: 0.7, y: 0.7);
        crowdswitch.setOn(false, animated: false)
    }
    func setSwitchOn(){
        self.crowdswitch.setOn(true, animated: false)
        GlobalData.sharedInstance.addSelectedPartyCrowdMemberToArray(eachData)
    }
    func setSwitchOff(){
        self.crowdswitch.setOn(false, animated: false)
    }
    func hiddenSwitch(){
        self.crowdswitch.isHidden = true
    }
    func showSwitch(){
        self.crowdswitch.isHidden = false
    }
    
}
