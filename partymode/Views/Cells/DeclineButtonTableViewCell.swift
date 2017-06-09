//
//  DeclineButtonTableViewCell.swift
//  partymode
//
//  Created by Nikita on 3/20/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class DeclineButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var regretButton: MKButton!
    var currentPartyCrowdItem: PartyCrowdCellData! = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        regretButton.setTitle(NSLocalizedString("stilldecline", comment: ""), for: UIControlState())
        
        let isFromPartyHistory = UserDefaults.standard.string(forKey: "isFromPartyHistory")
        if isFromPartyHistory == "YES"{
            regretButton.isHidden = true
        }
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func regretButtonPressed(_ sender: Any) {
//        declinedProcessInDB(reason: "")
    }
    func declinedProcessInDB(reason:String){
//        let myPhoneNr = UserDefaults.standard.string(forKey: "phone_nr")
//        let isUpdated = DBManager.getInstance().updateCrowdMemberData(self.currentPartyCrowdItem.id, phoneNr: myPhoneNr!, crowd_status: Constants.CROWD_STATUS_DECLINED, msg: reason)
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_reloadMembersData"), object: nil)
    }

}
