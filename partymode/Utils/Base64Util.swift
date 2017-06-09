//
//  Base64Util.swift
//  partymode
//
//  Created by Nikita on 2/23/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
class Base64Util {
    func convertToBase64 (_ image:UIImage) -> String {
        let imageData =  UIImagePNGRepresentation(image)
        var base64String = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        //        base64String = base64String.replacingOccurrences(of: "+", with: "%2B", options: NSString.CompareOptions.literal, range: nil)
        //        base64String = base64String.replacingOccurrences(of: "/", with: "%2F", options: NSString.CompareOptions.literal, range: nil)
        
        return base64String
    }
    func decodedFromBase64(_ base64String:String) -> UIImage {
        var encodedString = base64String.replacingOccurrences(of: "%2B", with: "+", options: NSString.CompareOptions.literal, range: nil)
        encodedString = encodedString.replacingOccurrences(of: "%2F", with: "/", options: NSString.CompareOptions.literal, range: nil)
        let imageData = encodedString//base64String//
        let dataDecode:NSData? = NSData(base64Encoded: imageData, options:.ignoreUnknownCharacters)
        var decodedImage:UIImage? = nil
        if dataDecode != nil {
            decodedImage = UIImage(data: dataDecode as! Data)!
        }
        
        return decodedImage!
    }
    //    func otherDecodedFromBase64(_ base64String:String) -> UIImage {
    //
    //        let dataDecode:NSData = NSData(base64Encoded: base64String, options:.ignoreUnknownCharacters)!
    //        let decodedImage:UIImage = UIImage(data: dataDecode as Data)!
    //        return decodedImage
    //    }
}
