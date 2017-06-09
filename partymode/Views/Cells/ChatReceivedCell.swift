//
//  ChatReceivedCell.swift
//  partymode
//
//  Created by Nikita on 2/20/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class ChatReceivedCell: UITableViewCell {

    @IBOutlet weak var faceImage: UIImageView!
    @IBOutlet weak var usernameOrPhoneNumberLabel: UILabel!
    
    @IBOutlet weak var chatTextLabel: UILabel!
    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var sentTimeLabel: UILabel!
    var myChatItem : PartyCrowdChatCellData!
    var arrayCount: Int!
    var selfIndex: Int!
    var parentView: UIViewController!
    override func awakeFromNib() {
        super.awakeFromNib()
        faceImage.contentMode = UIViewContentMode.scaleAspectFill
        self.makeAvatarBoderBlack(avatarImageView: faceImage)
//        self.chatTextLabel.layoutIfNeeded()
//        self.chatTextLabel.setNeedsLayout()
        //let imageTap = UITapGestureRecognizer(target: self, action:#selector(self.tappedImage(_:)))
        //chatImageView.addGestureRecognizer(imageTap)
        //chatImageView.isUserInteractionEnabled = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func tappedImage(_ gestureRecognizer: UITapGestureRecognizer) {
        //print("Image4 Tapped");
        if chatImageView.image != nil {
            
            UserDefaults.standard.set(UIImagePNGRepresentation(chatImageView.image!), forKey: "selectedAttachImage")
            let imageProvider = SomeImageProvider()
            let buttonAssets = CloseButtonAssets(normal: UIImage(named:"close_normal")!, highlighted: UIImage(named: "close_highlighted"))
            let configuration = ImageViewerConfiguration(imageSize: CGSize(width: 1920, height: 1080), closeButtonAssets: buttonAssets)
            
            let imageViewer = ImageViewerController(imageProvider: imageProvider, configuration: configuration, displacedView: parentView.view)
            parentView.presentImageViewer(imageViewer)
        }
        
    }
    func makeAvatarBoderGreen(avatarImageView: UIImageView){
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.layer.borderColor = Constants.avartar_color_green.cgColor
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.layer.masksToBounds = true
    }
    func makeAvatarBoderBlack(avatarImageView: UIImageView){
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.layer.borderColor = Constants.avartar_color_black.cgColor
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.layer.masksToBounds = true
    }
    func makeAvatarBoderRed(avatarImageView: UIImageView){
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.layer.borderColor = Constants.avartar_color_red.cgColor
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.layer.masksToBounds = true
    }
    func selfSizingUserNameWidth(){
        let myString: String = self.usernameOrPhoneNumberLabel.text!
        //let size: CGSize = myString.size(attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: self.usernameOrPhoneNumberLabel.font.pointSize)])
        usernameWidthConstraint.constant = CGFloat(myString.characters.count) * 10
    }
    class SomeImageProvider: ImageProvider {
        let images = [
            UIImage(named: "0"),
            UIImage(named: "1"),
            UIImage(named: "2"),
            UIImage(named: "3"),
            UIImage(named: "4"),
            UIImage(named: "5"),
            UIImage(named: "6"),
            UIImage(named: "7"),
            UIImage(named: "8"),
            UIImage(named: "9")]
        
        var imageCount: Int {
            return images.count
        }
        
        func provideImage(_ completion: (UIImage?) -> Void) {
            //let selectedImage: UIImage!
            if let imageData = UserDefaults.standard.object(forKey: "selectedAttachImage"),
                let selectedImage = UIImage(data: imageData as! Data){
                // use your image here...
                completion(selectedImage)
            }
            
        }
        
        func provideImage(atIndex index: Int, completion: (UIImage?) -> Void) {
            completion(images[index])
        }
    }
}
