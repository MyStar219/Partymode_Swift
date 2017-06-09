//
//  PartyPeopleCellData.swift
//  partymode
//
//  Created by Nikita on 2/2/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
struct PartyPeopleCellData {
    
    var face_image : UIImage
    var name : String
    var phonenumber:String
    var pmode: Int
    var img_off_lc:Int
    var img_on_lc:Int
    var img_pending_lc:Int
    var user_state:Int
    var pmode_time:Int?
    
    init(image: UIImage, name_string : String, phonenumber : String, pmode : Int, img_off_lc : Int, img_on_lc : Int, img_pending_lc : Int, user_state : Int) {
        
        self.face_image = image
        self.name = name_string
        self.phonenumber = phonenumber
        self.pmode = pmode
        self.img_off_lc = img_off_lc
        self.img_on_lc = img_on_lc
        self.img_pending_lc = img_pending_lc
        self.user_state = user_state
        self.pmode_time = 0
        
    }
    
    init(image: UIImage, name_string : String, phonenumber : String, pmode : Int, img_off_lc : Int, img_on_lc : Int, img_pending_lc : Int, user_state : Int, pmode_time: Int) {
        
        self.face_image = image
        self.name = name_string
        self.phonenumber = phonenumber
        self.pmode = pmode
        self.img_off_lc = img_off_lc
        self.img_on_lc = img_on_lc
        self.img_pending_lc = img_pending_lc
        self.user_state = user_state
        self.pmode_time = pmode_time
    }
}
