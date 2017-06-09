//
//  AcceptedPeopleTableViewCell.swift
//  partymode
//
//  Created by Nikita on 3/4/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class AcceptedPeopleTableViewCell: UITableViewCell {

    @IBOutlet var collectionView: UICollectionView!
    var collectionViewLayout: CustomImageFlowLayout!
    var acceptedPeopleArray = [PartyPeopleCellData]()
    let imageNames = ["face1", "face2", "face3", "face4", "face1","face2", "face3"]
    
    let gameNames = ["Me", "cut_the_ropes", "game_1", "little_pet_shop", "zuba","zuba","zuba"]
    
    let designed_width : CGFloat = 106
    let designed_height : CGFloat = 120
    let width_ratio = UIScreen.main.bounds.width / 320
    let height_ratio = UIScreen.main.bounds.height / 568
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionViewLayout = CustomImageFlowLayout()
        collectionView.collectionViewLayout = collectionViewLayout
        //collectionView.backgroundColor = .clear
    }
    func sortArrayForMeFirst (){
        let myPhoneNr = UserDefaults.standard.string(forKey: "phone_nr")
        var index = 0
        for each in self.acceptedPeopleArray {
            if each.phonenumber == myPhoneNr {
                let temp = each
                self.acceptedPeopleArray.remove(at: index)
                self.acceptedPeopleArray.insert(temp, at: 0)
                
            }
            index =  index + 1
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func makeAvatarBoderGreen(avatarImageView: UIImageView){
        avatarImageView.layer.cornerRadius = (designed_width * width_ratio - 32) / 2
        avatarImageView.layer.borderColor = Constants.avartar_color_green.cgColor
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.layer.masksToBounds = true
    }
    func makeAvatarBoderBlack(avatarImageView: UIImageView){
        avatarImageView.layer.cornerRadius = (designed_width * width_ratio - 32)  / 2
        avatarImageView.layer.borderColor = Constants.avartar_color_black.cgColor
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.layer.masksToBounds = true
    }
    func makeAvatarBoderRed(avatarImageView: UIImageView){
        avatarImageView.layer.cornerRadius = (designed_width * width_ratio - 32)  / 2
        avatarImageView.layer.borderColor = Constants.avartar_color_red.cgColor
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.layer.masksToBounds = true
    }

}
extension AcceptedPeopleTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return imageNames.count
        return acceptedPeopleArray.count
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let eachData: PartyPeopleCellData = self.acceptedPeopleArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellId_AcceptedPeopleCollectionView, for: indexPath) as! AcceptedPeopleCollectionViewCell
        
        cell.faceImageView.image = eachData.face_image//UIImage(named: imageNames[indexPath.row])
        
//        if eachData.name == "" {
//            cell.personNameLbl.text = eachData.phonenumber
//            let myPhoneNr = UserDefaults.standard.string(forKey: "phone_nr")
//            if eachData.phonenumber == myPhoneNr {
//                cell.personNameLbl.text = NSLocalizedString("me", comment: "")
//            }
//        
//        }
        let myPhoneNr = UserDefaults.standard.string(forKey: "phone_nr")
        if eachData.phonenumber == myPhoneNr {
            cell.personNameLbl.text = NSLocalizedString("me", comment: "")
            
            let partymode = UserDefaults.standard.integer(forKey: Constants.SP_PARTYMODE)
            if partymode == Constants.PARTYMODE_NA {//pending
                if UserDefaults.standard.string(forKey: "partymodePendingImageSaved") == "YES" {
                    cell.faceImageView.image = SaveLoadImageToLocalClass().getImage(imageNameWithExt: "partymodePending.jpg")
                }
                makeAvatarBoderBlack(avatarImageView: (cell.faceImageView))
            }
            if partymode == Constants.PARTYMODE_OFF {//off
                if UserDefaults.standard.string(forKey: "partymodeOFFImageSaved") == "YES" {
                    cell.faceImageView.image = SaveLoadImageToLocalClass().getImage(imageNameWithExt: "partymodeOFF.jpg")
                    makeAvatarBoderRed(avatarImageView: (cell.faceImageView))
                }
            }
            if partymode == Constants.PARTYMODE_ON {//on
                if UserDefaults.standard.string(forKey: "partymodeONImageSaved") == "YES" {
                    cell.faceImageView.image = SaveLoadImageToLocalClass().getImage(imageNameWithExt: "partymodeON.jpg")
                }
                makeAvatarBoderGreen(avatarImageView: (cell.faceImageView))
            }
        }
        else {
            cell.personNameLbl.text = eachData.name//gameNames[indexPath.row]
            if eachData.pmode == Constants.PARTYMODE_NA {//pending
                makeAvatarBoderBlack(avatarImageView: (cell.faceImageView))
                
            }
            if eachData.pmode == Constants.PARTYMODE_OFF {//off
                makeAvatarBoderRed(avatarImageView: (cell.faceImageView))
                
            }
            if eachData.pmode == Constants.PARTYMODE_ON {//on
                makeAvatarBoderGreen(avatarImageView: (cell.faceImageView))
                
            }
        }
        
        
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let clickedIndex = imageNames[indexPath.row]
        
        print(clickedIndex)
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width:designed_width * width_ratio, height:designed_height * height_ratio)
    }
}
