//
//  SectionsData.swift
//  sections
//
//  Created by Dan Beaulieu on 9/11/15.
//  Copyright © 2015 Dan Beaulieu. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SectionsData {
    
    var myArray: [AnyObject] = []
    
  
    func getSectionsFromData() -> [Sections] {
        
        // you could replace the contents of this function with an HTTP GET, a database fetch request,
        // or anything you like, as long as you return an array of Sections this program will
        // function the same way.
    
        var sectionsArray = [Sections]()
        
        var partypeopleArray = [PartyPeopleCellData]()
        partypeopleArray.append(PartyPeopleCellData(image: UIImage(named: "face1")!, name_string: "Anna Huber", phonenumber: "", pmode: 0, pmode_time: 111111, user_state: 0))
        partypeopleArray.append(PartyPeopleCellData(image: UIImage(named: "face2")!, name_string: "Anna Huber", phonenumber: "", pmode: 1, pmode_time: 111111, user_state: 1))
        partypeopleArray.append(PartyPeopleCellData(image: UIImage(named: "face3")!, name_string: "Anna Huber", phonenumber: "", pmode: 2, pmode_time: 111111, user_state: 1))
        partypeopleArray.append(PartyPeopleCellData(image: UIImage(named: "face4")!, name_string: "Anna Huber", phonenumber: "", pmode: 0, pmode_time: 111111, user_state: 0))
        
        var contactsArray = [PartyPeopleCellData]()
        contactsArray.append(PartyPeopleCellData(image: UIImage(named: "face1")!, name_string: "Anna Huber", phonenumber: "", pmode: 0, pmode_time: 111111, user_state: 0))
        contactsArray.append(PartyPeopleCellData(image: UIImage(named: "face1")!, name_string: "Anna Huber", phonenumber: "", pmode: 0, pmode_time: 111111, user_state: 0))
        contactsArray.append(PartyPeopleCellData(image: UIImage(named: "face1")!, name_string: "Anna Huber", phonenumber: "", pmode: 0, pmode_time: 111111, user_state: 0))
        contactsArray.append(PartyPeopleCellData(image: UIImage(named: "face1")!, name_string: "Anna Huber", phonenumber: "", pmode: 0, pmode_time: 111111, user_state: 0))
        contactsArray.append(PartyPeopleCellData(image: UIImage(named: "face1")!, name_string: "Anna Huber", phonenumber: "", pmode: 0, pmode_time: 111111, user_state: 0))
        contactsArray.append(PartyPeopleCellData(image: UIImage(named: "face1")!, name_string: "Anna Huber", phonenumber: "", pmode: 0, pmode_time: 111111, user_state: 0))
        contactsArray.append(PartyPeopleCellData(image: UIImage(named: "face1")!, name_string: "Anna Huber", phonenumber: "", pmode: 0, pmode_time: 111111, user_state: 0))
        contactsArray.append(PartyPeopleCellData(image: UIImage(named: "face1")!, name_string: "Anna Huber", phonenumber: "", pmode: 0, pmode_time: 111111, user_state: 0))
        contactsArray.append(PartyPeopleCellData(image: UIImage(named: "face1")!, name_string: "Anna Huber", phonenumber: "", pmode: 0, pmode_time: 111111, user_state: 0))
        contactsArray.append(PartyPeopleCellData(image: UIImage(named: "face1")!, name_string: "Anna Huber", phonenumber: "", pmode: 0, pmode_time: 111111, user_state: 0))
        contactsArray.append(PartyPeopleCellData(image: UIImage(named: "face1")!, name_string: "Anna Huber", phonenumber: "", pmode: 0, pmode_time: 111111, user_state: 0))
        contactsArray.append(PartyPeopleCellData(image: UIImage(named: "face1")!, name_string: "Anna Huber", phonenumber: "", pmode: 0, pmode_time: 111111, user_state: 0))
        
        
        
        let partypeoples = Sections(title: "partypeople", objects: partypeopleArray)
        let contacts = Sections(title: "contact", objects: contactsArray)
   
        sectionsArray.append(partypeoples)
        sectionsArray.append(contacts)
       
//        Alamofire.request(url).validate().responseJSON(completionHandler: response )
//        Alamofire.request(.GET, url).validate().responseJSON { response in
//            switch response.result {
//            case .Success:
//                if let value = response.result.value {
//                    let json = JSON(value)
//                    
//                    for (_, subJson) in json["posts"] {
//                        for (year, content) in subJson {
//                            print(year)
//                            for (_, title) in content {
//                                print(title)
//                            }
//                        }
//                    }
//                }
//            case .Failure(let error):
//                print(error)
//            }
//        }
        return sectionsArray
    }
}
