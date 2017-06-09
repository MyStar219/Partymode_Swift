//
//  Constants.swift
//  partymode
//
//  Created by Nikita on 1/13/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
class Constants {
    
    
    
    static let tab_color_partymode = UIColor(red: 245.0 / 255, green: 245.0 / 255, blue: 245.0 / 255, alpha: 1)
    static let tab_color_partypeople = UIColor(red: 214.0 / 255, green: 204.0 / 255, blue: 12.0 / 255, alpha: 1)
    static let tab_color_partycrowds = UIColor(red: 26.0 / 255, green: 189.0 / 255, blue: 147.0 / 255, alpha: 1)
    static let tab_color_partyprofile = UIColor(red: 12.0 / 255, green: 211.0 / 255, blue: 214.0 / 255, alpha: 1)
    
    static let switch_color_off = UIColor(red: 214.0 / 255, green: 12.0 / 255, blue: 83.0 / 255, alpha: 1)
    static let switch_color_on = UIColor(red: 5.0 / 255, green: 138.0 / 255, blue: 56.0 / 255, alpha: 1)
    static let switch_color_pending = UIColor(red: 68.0 / 255, green: 68.0 / 255, blue: 68.0 / 255, alpha: 1)
    
    static let avartar_color_green = UIColor(red: 5.0 / 255, green: 138.0 / 255, blue: 56.0 / 255, alpha: 1)
    static let avartar_color_red = UIColor(red: 214.0 / 255, green: 12.0 / 255, blue: 83.0 / 255, alpha: 1)
    static let avartar_color_black = UIColor(red: 68.0 / 255, green: 68.0 / 255, blue: 68.0 / 255, alpha: 1)
    
    static let color_gender_check_background = UIColor(red: 66.0 / 255, green: 66.0 / 255, blue: 66.0 / 255, alpha: 1)
    
    static let color_partify_disabled = UIColor(red: 68.0 / 255, green: 68.0 / 255, blue: 68.0 / 255, alpha: 1)
    
    static let color_switch_off = UIColor(red: 68.0 / 255, green: 68.0 / 255, blue: 68.0 / 255, alpha: 1)
    static let color_switch_on = UIColor(red: 5.0 / 255, green: 138.0 / 255, blue: 56.0 / 255, alpha: 1)
    
    static let cellId_partypeopleTableView = "partypeople_cellId"
    static let cellId_contactTableView = "contact_cellId"
    static let cellId_partypeopleeditTableView = "partypeopleedit_cellId"
    static let cellId_partycrowdTableView = "partycrowd_cellId"
    static let cellId_creatPartyCrowTableView = "creatpartycrowd_cellId"
    static let cellId_ChatTableView = "chatTable_cellId"
    static let cellId_ChatTableSentView = "chatTable_sent_cellId"
    static let cellId_AcceptedPeopleTableView = "acceptedPeople_cellId"
    static let cellId_AcceptedPeopleCollectionView = "acceptedPeopleCollection_cellId"
    
    //static let API_LINK = "http://213.136.88.3"; //
    static let API_LINK = "https://app.partymode.cc:8060"//"http://213.136.88.3:8070"; //
    static let API_IMAGES = "/images/";
    static let PREF = "PartyPrefs";
    static let TV_LINK = "http://tvheute.at";
    static let SupportFAQ_LINK = "https://www.partymode.cc/support/"
    
    static let MINUTE = 60;
    static let HOUR = MINUTE*60;
    static let DAY = HOUR*24;
    
    static let PARTYMODE_ON = 2;
    static let PARTYMODE_OFF = 1;
    static let PARTYMODE_NA = 0;
    
    static let DEFAULT_CROWD_TIME = HOUR*20*1000;
    
    static let PARTYMODEON_DURATION = HOUR*6;
    static let PARTYMODEOFF_DURATION = HOUR*12;
    static let FREQUENCY_SEND_CONTACTS = 30*MINUTE;
    static let FREQUENCY_REFRESH_PMODE = 1*MINUTE;
    static let FREQUENCY_SEND_GCM = DAY*1;
    static let FREQUENCY_REFRESH_NAMES = HOUR*2;
    static let FREQUENCY_PARTIFY = MINUTE*15;
    static let PARTIFY_TIMEOUT = HOUR*3;
    static let PASTCROWD_OFFSET_DURATION = HOUR*36
    
    static let CROWD_TO_HISTORY = DAY;
    static let CROWD_STILL_CURRENT = HOUR*6;
    
    static let IMAGE_PATH = "/partymode";
    static let INTERNAL_PROFILE_PIC_DIR = "profilepics";
    static let PROFILE_IMAGE_LARGE = 100;
    static let PROFILE_IMAGE_SMALL = 60;
    static let IMAGE_LARGE = 200;
    
//    static let SP_UID = "uid";
//    static let SP_SID = "sid";
    static let SP_GCM_TOKEN_LAST_SENT = "gcm_token_sent";
    static let SP_CONTACTS_LAST_SENT = "contacts_sent";
    static let SP_NAMES_LAST_REFRESHED = "names_refreshed";
    static let SP_PMODE_ON_CONTACTS = "pm_contacts";
    static let SP_PARTYMODE = "partymode";
    static let SP_OWN_PHONE_NR = "phone_nr";
    static let SP_PARTYMODE_TIME = "pm_time";
    static let SP_PROFILE_PARTYNAME = "partyname";
    static let SP_PROFILE_FIRSTNAME = "firstname";
    static let SP_PROFILE_LASTNAME = "lastname";
    static let SP_PROFILE_ADDRESS = "address";
    static let SP_PROFILE_EMAIL = "email";
    static let SP_PROFILE_BIRTHDAY = "birthday";
    static let SP_PROFILE_GENDER = "gender";
    static let SP_PROFILE_GENDER_MALE = 0;
    static let SP_PROFILE_GENDER_FEMALE = 1;
    static let SP_IMG_ON = "img_on";
    static let SP_IMG_OFF = "img_off";
    static let SP_IMG_PENDING = "img_pending";
    static let SP_MSG_DRAFT_PREFIX_ = "msg_draft_";
    static let SP_VIBRATE = "vibrate";
    static let SP_NOTIFICATION_UNREAD_MSG_COUNT = "crowd_msg";
    static let SP_NOTIFICATION_CROWD_MSG = "notif_crowd_msg";
    static let SP_NOTIFICATION_CROWD_DECIDE = "notif_crowd_acc";
    static let SP_CAMPAIGN_TVMEDIA = "tvmedia";
    static let SP_FEEDBACK_GIVEN = "feedback";
    
    static let STATE_PM_USER = 0;
    static let STATE_CONTACT = 1;
    static let STATE_BLOCKED = 2;
    
    static let NOTIFICATION_TRUE = 1;
    static let NOTIFICATION_FALSE = 0;
    
    static let CROWD_TITLE = "crowd_title";
    static let CROWD_LOCATION = "crowd_location";
    static let CROWD_DATE = "crowd_date";
    static let CROWD_TIME = "crowd_time";
    static let CROWD_INVITE_FRIENDS = "crowd_invfriends";
    
    static let CROWD_MSG_DELIVERED_NOT = 0;
    static let CROWD_MSG_DELIVERED_SUCCESS = 1;
    static let CROWD_MSG_DELIVERED_FAILED = 2;
    static let CROWD_MSG_DELIVERED_SYSTEM = 3;
    static let CROWD_MSG_IMG_NOT_DOWNLOADED = 4;
    static let CROWD_MSG_TIMEOUT = 20;
    
    static let CROWD_MSG_IMG_PREVIEW_HEIGHT = 250;
    static let CROWD_MSG_IMG_PREVIEW_WIDTH = 250;
    static let CROWD_MSG_INPUT_HEIGHT = 70;
    
    
    static let CROWD_STATUS_PENDING = 0;
    static let CROWD_STATUS_ACCEPTED = 1;
    static let CROWD_STATUS_DECLINED = 2;
    static let CROWD_STATUS_DO_NO_CHANGE_STATUS = 3;
    
    static let demoPhoneNumber = "+433246542246";
    static let demo_uid = "123456789012345678901234";
    static let demo_sid = "zDDMT2nopo2k65pVtyj74Rwl";
}
