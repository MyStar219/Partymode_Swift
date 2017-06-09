//
//  FeedbackViewController.swift
//  partymode
//
//  Created by Nikita on 1/14/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, FloatRatingViewDelegate {

    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var ratingParentView: UIView!
    @IBOutlet weak var feedbackTextField: UITextField!
    
    @IBOutlet weak var feedback_explainLabel: UILabel!
    @IBOutlet weak var en_thanks_label: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfGotoHomeView(_:)), name:NSNotification.Name(rawValue: "notificationId_gotoPartyPeopleTab"), object: nil)
        
    }
    func methodOfGotoHomeView(_ notification: Notification){
        //Take Action on Notification
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: false);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lang = NSLocalizedString("currentLanuguage",comment:"")
        en_thanks_label.text = NSLocalizedString("thanks_feedback",comment:"")
        if lang == "en" {
            en_thanks_label.isHidden = false
        }
        else {
            en_thanks_label.isHidden = true
        }
        sendButtonStyle()
        ratingPropertySettings()
        
        feedback_explainLabel.text = NSLocalizedString("feedback_text", comment: "")
        sendButton.setTitle(NSLocalizedString("send", comment: ""), for: UIControlState())
        // Do any additional setup after loading the view.
    }
    func sendButtonStyle(){
        sendButton.layer.cornerRadius = 5
        sendButton.layer.borderColor = UIColor.black.cgColor
        sendButton.layer.borderWidth = 1
        sendButton.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: FloatRatingViewDelegate
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float) {
        
        print(NSString(format: "%.2f", self.ratingView.rating) as String)
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        
        print(NSString(format: "%.2f", self.ratingView.rating) as String)
    }
    
    func ratingPropertySettings(){
        // Required float rating view params
        self.ratingView.emptyImage = UIImage(named: "ico_feedbackstar_normal")
        self.ratingView.fullImage = UIImage(named: "ico_feedbackstar_filled")
        // Optional params
        self.ratingView.delegate = self
        self.ratingView.contentMode = UIViewContentMode.scaleAspectFit
        self.ratingView.maxRating = 5
        self.ratingView.minRating = 1
        self.ratingView.rating = 0
        self.ratingView.editable = true
        self.ratingView.halfRatings = false
        self.ratingView.floatRatings = false
    }
    
    @IBAction func sendButton(_ sender: Any) {
        if self.ratingView.rating >= 4 {
            FeedbackSendAPICall().request(self, feedbackString: feedbackTextField.text!, stars: Int(self.ratingView.rating), completionHandler: {(post) -> Void in
                self.ratingParentView.isHidden = true
                let alertController = UIAlertController(title: NSLocalizedString("feedback_msg_title",comment:""), message: nil, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: NSLocalizedString("ok",comment:""), style: .cancel) {
                    (action:UIAlertAction!) in
                    //action of yest
                    self.visitFeedbackPage()
                }
                let cancelAction = UIAlertAction(title: NSLocalizedString("cancel",comment:""), style: .default)
                { (action:UIAlertAction!) in }
                
                alertController.addAction(OKAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion:nil)
                
            })
            
            
        }
        else {
            FeedbackSendAPICall().request(self, feedbackString: feedbackTextField.text!, stars: Int(self.ratingView.rating), completionHandler: {(post) -> Void in
                self.ratingParentView.isHidden = true
                
            })
        }
        
    }

    func visitFeedbackPage(){
        let url = URL(string: "http://www.partymode.cc/feedback")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
