//
//  HomeViewController.swift
//  partymode
//
//  Created by Nikita on 1/12/17.
//  Copyright © 2017 com. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, CarbonTabSwipeNavigationDelegate, UISearchBarDelegate {
    var currentTabIndex : Int!
    var items = NSArray()
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation = CarbonTabSwipeNavigation()
    var myScrollView : UIScrollView!
    var searchButton : UIBarButtonItem!
    var searchBar:UISearchBar!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.automaticallyAdjustsScrollViewInsets = true
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.methodOfReceivedNotification(_:)), name:NSNotification.Name(rawValue: "notificationId_gotoPartyPeopleTab"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.methodOfShowTab3(_:)), name:NSNotification.Name(rawValue: "notificationId_showTab3"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.methodOfGoToLogin(_:)), name:NSNotification.Name(rawValue: "notification_goToLogin"), object: nil)
        UserDefaults.standard.set("true", forKey: "shouldgotoPartypeopleTab")
        switch currentTabIndex {
        case 0:
            navigationController?.navigationBar.barTintColor = Constants.tab_color_partymode
            self.navigationController?.navigationBar.isHidden = false
            return
        case 1:
            navigationController?.navigationBar.barTintColor = Constants.tab_color_partypeople
            self.navigationController?.navigationBar.isHidden = false
            return
        case 2:
            navigationController?.navigationBar.barTintColor = Constants.tab_color_partycrowds
            self.navigationController?.navigationBar.isHidden = false
            return
        case 3:
            self.navigationController?.navigationBar.isHidden = true
            return
        default:
            return
        }
        
    }
    func methodOfGoToLogin(_ notification: Notification){
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    func methodOfReceivedNotification(_ notification: Notification){
        //Take Action on Notification
        let when = DispatchTime.now() + 0.8
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.gotoPartyPeopleTap()
        }
        
    }
    func methodOfShowTab3(_ notification: Notification){
        //Take Action on Notification
        self.gotoPartyCrowdTap()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async(execute: {
            GlobalData.sharedInstance.startLoadingData(sender:self)
        })
        hideBackButton()
        setupRightItemButton()
        searchBar = UISearchBar(frame: CGRect(x:0, y:0, width:self.view.frame.width - 60, height:20))
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        
        items = [UIImage(named: "nav_mode_inactive")!, UIImage(named: "nav_partypeople")!, UIImage(named: "nav_crowd")!, UIImage(named: "nav_profile")!]
        carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items as [AnyObject], delegate: self)
        
        carbonTabSwipeNavigation.insert(intoRootViewController: self)
        
        for subView: UIView in carbonTabSwipeNavigation.pageViewController.view.subviews {
            if (subView is UIScrollView) {
                self.myScrollView = subView as! UIScrollView
                
                // get scrollview reference here i.e: self.myScrollView = subView;
                //self.myScrollView.addSubview(subView)
            }
        }
        self.style()
        
        let when = DispatchTime.now() + 30
        DispatchQueue.main.asyncAfter(deadline: when) {
            SetGCMTokenAPICall().request()
        }
//        let defaults = UserDefaults.standard
//        let sid = defaults.string(forKey: "sid")
        //self.showAlert(sid!)
        
    }
    func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "Your current sid", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func style() {
        let color: UIColor = UIColor.black//UIColor(red: 235.0 / 255, green: 145.0 / 255, blue: 40.0 / 255, alpha: 1)
        
        carbonTabSwipeNavigation.toolbar.isTranslucent = false
        carbonTabSwipeNavigation.setTabExtraWidth(0)
        carbonTabSwipeNavigation.setIndicatorColor(color)

        
        let screenWidth = UIScreen.main.bounds.width
        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(screenWidth/4, forSegmentAt: 0)
        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(screenWidth/4, forSegmentAt: 1)
        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(screenWidth/4, forSegmentAt: 2)
        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(screenWidth/4, forSegmentAt: 3)
        
        carbonTabSwipeNavigation.setNormalColor(UIColor.black.withAlphaComponent(0.6), font: UIFont.boldSystemFont(ofSize: 11))
        carbonTabSwipeNavigation.setSelectedColor(color, font: UIFont.boldSystemFont(ofSize: 11))
        carbonTabSwipeNavigation.setTabBackgroundColor(Constants.tab_color_partymode)
        
        enableScrolling()
    }
    func disableScrolling(){
        self.myScrollView.isScrollEnabled = false
    }
    func enableScrolling(){
        self.myScrollView.isScrollEnabled = true
    }
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        let stb = UIStoryboard(name: "Main", bundle: nil)
        
        switch index {
        case 0:
            
            return stb.instantiateViewController(withIdentifier: "Tab1PartymodeViewController") as! Tab1PartymodeViewController
        case 1:
            return stb.instantiateViewController(withIdentifier: "Tab2PartypeopleViewController") as! Tab2PartypeopleViewController
        case 2:
            return stb.instantiateViewController(withIdentifier: "Tab3PartycrowdsViewController") as! Tab3PartycrowdsViewController
        case 3:
            return stb.instantiateViewController(withIdentifier: "Tab4PartyInfoViewController") as! Tab4PartyInfoViewController
        default:
            return stb.instantiateViewController(withIdentifier: "Tab1PartymodeViewController") as! Tab1PartymodeViewController
        }
        
    }
    
    func barPosition(for carbonTabSwipeNavigation: CarbonTabSwipeNavigation) -> UIBarPosition {
        return .bottom
    }
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, willMoveAt index: UInt) {
        //print("Moved to \(index)")
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.searchBar.resignFirstResponder()
        switch index {
        case 0:
            setupRightItemButton()
            let color: UIColor = Constants.tab_color_partymode
            carbonTabSwipeNavigation.setTabBackgroundColor(color)
            //setupBackIcon()
            self.navigationController?.navigationBar.isHidden = false
            navigationController?.navigationBar.barTintColor = color
            self.title = "partymode"//NSLocalizedString("", comment: "")//"partymode"
            
            let button1 = UIBarButtonItem(image: UIImage(named: "ico-more"), style: .plain, target: self, action:#selector(self.moreButtonTapped))
            self.navigationItem.rightBarButtonItem  = button1
            
            return
        case 1:
            
            //NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_refreshContacts"), object: nil)
            //NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_refreshNow"), object: nil)
            
            setupRightItemButtonWithSearch()
            let color: UIColor = Constants.tab_color_partypeople
            carbonTabSwipeNavigation.setTabBackgroundColor(color)
            //setupBackIcon()
            self.navigationController?.navigationBar.isHidden = false
            navigationController?.navigationBar.barTintColor = color
            self.title = NSLocalizedString("partypeople", comment: "")//"partypeople"
            
            return
        case 2:
            setupRightItemButton()
            let color: UIColor = Constants.tab_color_partycrowds
            carbonTabSwipeNavigation.setTabBackgroundColor(color)
            //setupBackIcon()
            self.navigationController?.navigationBar.isHidden = false
            navigationController?.navigationBar.barTintColor = color
            self.title = "partycrowds"
            
            return
        case 3:
            self.navigationController?.navigationBar.isTranslucent = true
            let color: UIColor = Constants.tab_color_partyprofile
            carbonTabSwipeNavigation.setTabBackgroundColor(color)
            navigationController?.navigationBar.barTintColor = Constants.tab_color_partymode
            self.navigationController?.navigationBar.isHidden = true
            
            return
        default:
            return
        }
    }
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, didMoveAt index: UInt) {
        print("current screen : \(index)")
        currentTabIndex = Int(index)
        /*
        switch index {
        case 0:
            setupRightItemButton()
            return
        case 1:
            setupRightItemButtonWithSearch()
            return
        case 2:
            setupRightItemButton()
            return
        case 3:
            return
        default:
            return
        }
 */
    }
    
//    func setupBackIcon(){
//        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "ico_back")
//        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "ico_back")
//    }
    func hideBackButton(){
        self.navigationItem.setHidesBackButton(true, animated:true)
    }
    func gotoPartyPeopleTap(){
        
        carbonTabSwipeNavigation.currentTabIndex = 1
        //carbonTabSwipeNavigation.carbonSegmentedControl!.selectedSegmentIndex = 1
        //carbonTabSwipeNavigation.carbonSegmentedControl!.sendActions(for: .valueChanged)

    }
    func gotoPartyCrowdTap(){
        carbonTabSwipeNavigation.currentTabIndex = 2
    }
    func setupRightItemButton(){
        self.navigationItem.rightBarButtonItem  = nil
        let button1 = UIBarButtonItem(image: UIImage(named: "ico-more"), style: .plain, target: self, action:#selector(self.moreButtonTapped))
        self.navigationItem.rightBarButtonItem  = button1
    }
    func setupRightItemButtonWithSearch(){
        
        self.navigationItem.rightBarButtonItem  = nil
        let moreButton = UIBarButtonItem(image: UIImage(named: "ico-more"), style: .plain, target: self, action:#selector(self.moreButtonTapped))
        self.searchButton = UIBarButtonItem(image: UIImage(named: "ico-search"), style: .plain, target: self, action:#selector(self.searchButtonTapped))
        //self.navigationItem.rightBarButtonItem  = [searchButton,moreButton]
        self.navigationItem.setRightBarButtonItems([moreButton, searchButton], animated: false)
    }
    func moreButtonTapped(){
        let viewController =  self.storyboard?.instantiateViewController(withIdentifier: "MoreItemsViewController") as! MoreItemsViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationId_updateSearchKey"), object: searchText.lowercased())
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cancelButtonTapped()
    }
    func cancelButtonTapped(){
        self.title = NSLocalizedString("partypeople", comment: "")
        self.navigationItem.leftBarButtonItem = nil
        self.setupRightItemButtonWithSearch()
        self.searchBar.resignFirstResponder()
    }
    func searchButtonTapped(){
        
        let leftNavBarButton = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        self.title = ""
        searchBar.setShowsCancelButton(true, animated: true)
        
        self.navigationItem.rightBarButtonItem  = nil
        let moreButton = UIBarButtonItem(image: UIImage(named: "ico-more"), style: .plain, target: self, action:#selector(self.moreButtonTapped))
        
        self.navigationItem.setRightBarButtonItems([moreButton], animated: false)
        self.searchBar.becomeFirstResponder()
        
    }
}
