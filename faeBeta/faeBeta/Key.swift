//
//  Key.swift
//  faeBeta
//
//  Created by blesssecret on 11/8/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class Key: NSObject {//  singleton class
    var baseURL = "https://api.letsfae.com"
    var version = "x.faeapp.v1"
    var headerAccept = "application/x.faeapp.v1+json"
    var headerContentType = "application/x-www-form-urlencoded"
    let headerClientVersion : String = "fae-ios-1.0.0"
    var headerDeviceID : String = ""
    var headerUserAgent : String = "iPhone"

    var userToken : String!
    var userTokenEncode : String!
    var session_id : NSNumber!
    var user_id : NSNumber!
    var is_Login : Int = 0
    var userEmail : String!
    var userPassword : String!
    let GoogleMapKey = "AIzaSyC7Wxy8L4VFaTdzC7vbD43ozVO_yUw4DTk"

    var username : String?
    //new add global var
    var nickname : String?
    var shortIntro : String?
    var showGender = true
    var showAge = true
    var userAge : Int?

    var userStatus : Int?
    var userStatusMessage : String?

    var userFirstname : String?
    var userLastname : String?
    var userBirthday : String? // yyyy-MM-dd
    var userGender : Int? // 0 means male 1 means female
    var userUserGender : String?
    var userUserName : String?
    var userMiniAvatar : Int?

    var userPhoneNumber : String?

    var userEmailVerified : Bool = false
    var userPhoneVerified : Bool = false
    
    var userAvatarMap = "avatar_1" // new var by Yue Shen
    
    var arrayNameCard = [Int:UIImage]()
    
    let imageDefaultCover = UIImage(named: "defaultCover")
    let imageDefaultMale = UIImage(named: "defaultMan")
    let imageDefaultFemale = UIImage(named: "defaultWomen")
    
    class var sharedInstance: Key {
        struct Static {
            static let instance = Key()
        }
        return Static.instance
    }
/*
    static let sharedInstance = Key()
    private init(){

    }*/
}