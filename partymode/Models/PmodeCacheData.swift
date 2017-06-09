//
//  PmodeCacheData.swift
//  partymode
//
//  Created by Nikita on 5/12/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
class PmodeCacheData {
    var phonenumber : String
    var last_pmode_time:Int
    var last_pmode:Int
    
    init(phonenumber: String, last_pmode_time : Int, last_pmode:Int) {
        self.phonenumber = phonenumber
        self.last_pmode_time = last_pmode_time
        self.last_pmode = last_pmode
    }
}
