//
//  PartyPeopleHeaderCell.swift
//  partymode
//
//  Created by Nikita on 2/4/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class PartyPeopleHeaderCell: UITableViewCell {

    @IBOutlet weak var headerTitle: UILabel!
    
    @IBOutlet weak var header_edit_Button: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
