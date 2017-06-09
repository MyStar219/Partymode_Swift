//
//  PartyPeopleTableViewCell.swift
//  partymode
//
//  Created by Nikita on 1/17/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class PartyPeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var partyfyIcon: UIImageView!
    @IBOutlet weak var partyfyButton: UIButton!
    //@IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var phonenumberLabel: UILabel!
    
    var partifyEnabled = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImage.contentMode = UIViewContentMode.scaleAspectFill
        //avatarImage.image = UIImage(named: "nav_profile_inactive")
        partyfyIcon.image = UIImage(named: "ico_partyfy01")
        partyfyButton.setTitle(NSLocalizedString("partify", comment: "").uppercased(), for: UIControlState())
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func partyfyButtonPressed(_ sender: Any) {
        print("partyfyButtonPressed")
        if partifyEnabled != true {
            self.enblePartify()
            
        }
        else {
            //self.disablePartify()
            
        }
    }
    
    func hide_partify(){
        partyfyIcon.isHidden = true
        partyfyButton.isHidden = true
    }
    func disablePartify(){
        partifyEnabled = false
        partyfyIcon.image = UIImage(named: "ico_partyfy01")
        partyfyButton.setTitleColor(Constants.color_partify_disabled, for: .normal)
        self.partyfyButton.isUserInteractionEnabled = true
    }
    
    func enblePartify(){
        partifyEnabled = true
        partyfyIcon.image = UIImage(named: "ico_partyfy05")
        partyfyButton.setTitleColor(Constants.avartar_color_green, for: .normal)
        self.partyfyButton.isUserInteractionEnabled = false
    }
    

    
}
