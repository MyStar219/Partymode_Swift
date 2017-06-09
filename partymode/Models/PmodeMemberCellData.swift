//
//  PmodeMemberCellData.swift
//  partymode
//
//  Created by Nikita on 5/10/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
struct PmodeMemberCellData {
    
    var name : String
    var phonenumber:String
    var last_modified_pmode: Int
    var pmode: Int
    var pmode_time: Int
    var user_state:Int
    var partified_time:Int
    //var profile_image : String
    var img_off_lc:Int
    var img_on_lc:Int
    var img_pending_lc:Int
    
    
    init(name_string : String, phonenumber : String, pmode : Int, pmode_time : Int, user_state : Int, partified_time : Int, img_off_lc : Int, img_on_lc : Int, img_pending_lc : Int, last_modified_pmode:Int) {
        
        self.name = name_string
        self.phonenumber = phonenumber
        self.pmode = pmode
        self.pmode_time = pmode_time
        self.user_state = user_state
        self.partified_time = partified_time
        //self.profile_image = image
        self.img_off_lc = img_off_lc
        self.img_on_lc = img_on_lc
        self.img_pending_lc = img_pending_lc
        self.last_modified_pmode = last_modified_pmode
        
    }
}
