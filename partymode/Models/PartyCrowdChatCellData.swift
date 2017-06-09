//
//  PartyCrowdChatCellData.swift
//  partymode
//
//  Created by Nikita on 2/22/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
struct PartyCrowdChatCellData {
    
    var message_id:Int
    var crowdId : String
    var senderName : String
    var msg:String
    var is_img: Bool
    var time:Int
    var delivered:Int
    var time_string:String
    var receivedImage: UIImage?
    
    init(message_id: Int, crowdId: String, senderName : String, msg : String, is_img : Bool, time : Int, delivered : Int, time_string:String) {
        self.message_id = message_id
        self.crowdId = crowdId
        self.senderName = senderName
        self.msg = msg
        self.is_img = is_img
        self.time = time
        self.delivered = delivered
        self.time_string =  time_string
    }
    
}
