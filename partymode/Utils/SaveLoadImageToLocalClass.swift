//
//  SaveLoadImageToLocalClass.swift
//  partymode
//
//  Created by Nikita on 2/1/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
class SaveLoadImageToLocalClass {
    func saveImageDocumentDirectory(image:UIImage,imageNameWithExt:String){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageNameWithExt)
        //let image = UIImage(named: "ico_addpic")
        print(paths)
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    func getImage(imageNameWithExt:String) -> UIImage{
        let fileManager = FileManager.default
        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(imageNameWithExt)
        if fileManager.fileExists(atPath: imagePAth){
            //self.imageView.image = UIImage(contentsOfFile: imagePAth)
            return UIImage(contentsOfFile: imagePAth)!
        }else{
            print("No Image")
            let default_image:UIImage = UIImage(named: "ico_addpic")!
            return default_image
        }
    }
    func createDirectory(){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("customDirectory")
        if !fileManager.fileExists(atPath: paths){
            try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
        }else{
            print("Already dictionary created.")
        }
    }
    func deleteDirectory(){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("customDirectory")
        if fileManager.fileExists(atPath: paths){
            try! fileManager.removeItem(atPath: paths)
        }else{
            print("Something wronge.")
        }
    }
    func saveImageToGallery(image:UIImage,imageNameWithExt:String){
//        let fileManager = FileManager.default
//        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("/dedicated partymode folder/" + imageNameWithExt)
//        //let image = UIImage(named: "ico_addpic")
//        print(paths)
//        let imageData = UIImageJPEGRepresentation(image, 0.5)
//        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        
        CustomPhotoAlbum().save(image: image)
        
    }
    
}
