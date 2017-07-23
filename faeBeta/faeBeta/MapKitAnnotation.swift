//
//  MapKitAnnotation.swift
//  faeBeta
//
//  Created by Yue on 7/12/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CCHMapClusterController
import MapKit

class FaePinAnnotation: MKPointAnnotation {
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? FaePinAnnotation else { return false }
        return self.id == rhs.id && self.type == rhs.type
    }
    
    static func ==(lhs: FaePinAnnotation, rhs: FaePinAnnotation) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    // general
    var type: String!
    var id: Int = -1
    var mapViewCluster: CCHMapClusterController?
    
    // place pin & social pin
    var icon: UIImage!
    var pinInfo: AnyObject!
    
    init(type: String) {
        super.init()
        self.type = type
    }
    
    // user pin only
    var avatar: UIImage!
    var miniAvatar: Int!
    var positions = [CLLocationCoordinate2D]()
    var count = 0
    var isValid = false {
        didSet {
            if isValid {
                self.timer?.invalidate()
                self.timer = nil
                self.timer = Timer.scheduledTimer(timeInterval: self.getRandomTime(), target: self, selector: #selector(self.changePosition), userInfo: nil, repeats: false)
            } else {
                self.count = 0
                self.timer = nil
            }
        }
    }
    
    var timer: Timer?
    
    init(type: String, cluster: CCHMapClusterController, json: JSON) {
        super.init()
        self.mapViewCluster = cluster
        self.type = type
        guard type == "user" else { return }
        self.id = json["user_id"].intValue
        self.miniAvatar = json["mini_avatar"].intValue
        guard let posArr = json["geolocation"].array else { return }
        for pos in posArr {
            let pos_i = CLLocationCoordinate2DMake(pos["latitude"].doubleValue, pos["longitude"].doubleValue)
            self.positions.append(pos_i)
        }
        self.coordinate = self.positions[self.count]
        self.count += 1
        guard Mood.avatars[miniAvatar] != nil else {
            print("[init] map avatar image is nil")
            return
        }
        self.avatar = Mood.avatars[miniAvatar]
        self.changePosition()
        self.timer = Timer.scheduledTimer(timeInterval: getRandomTime(), target: self, selector: #selector(self.changePosition), userInfo: nil, repeats: false)
    }
    
    
    
    func getRandomTime() -> Double {
        return Double.random(min: 5, max: 20)
    }
    
    // change the position of user pin given the five fake coordinates from Fae-API
    func changePosition() {
        guard self.isValid else { return }
        if self.count >= 5 {
            self.count = 0
        }
        self.mapViewCluster?.removeAnnotations([self], withCompletionHandler: {
            guard self.isValid else { return }
            if self.positions.indices.contains(self.count) {
                self.coordinate = self.positions[self.count]
            } else {
                self.count = 0
                self.timer?.invalidate()
                self.timer = nil
                self.timer = Timer.scheduledTimer(timeInterval: self.getRandomTime(), target: self, selector: #selector(self.changePosition), userInfo: nil, repeats: false)
                return
            }
            self.mapViewCluster?.addAnnotations([self], withCompletionHandler: nil)
            self.count += 1
            self.timer?.invalidate()
            self.timer = nil
            self.timer = Timer.scheduledTimer(timeInterval: self.getRandomTime(), target: self, selector: #selector(self.changePosition), userInfo: nil, repeats: false)
        })
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + getRandomTime()) { [index = self.count] in
            guard self.isValid else { return }
            self.mapViewCluster?.removeAnnotations([self], withCompletionHandler: {
                guard self.isValid else { return }
                if self.positions.indices.contains(index) {
                    self.coordinate = self.positions[index]
                } else {
                    self.changePosition()
                    return
                }
                self.mapViewCluster?.addAnnotations([self], withCompletionHandler: nil)
                self.count += 1
                self.changePosition()
            })
        }
        */
    }
    
    // social pin only
    
}

class SelfAnnotationView: MKAnnotationView {
    
    var selfMarkerIcon = UIButton()
    var myPositionCircle_1: UIImageView!
    var myPositionCircle_2: UIImageView!
    var myPositionCircle_3: UIImageView!
    let anchorPoint = CGPoint(x: 22, y: 22)
    var mapAvatar: Int = 1 {
        didSet {
            self.selfMarkerIcon.setImage(UIImage(named: "miniAvatar_\(mapAvatar)"), for: .normal)
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        clipsToBounds = false
        layer.zPosition = 2
        loadSelfMarkerSubview()
        getSelfAccountInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadSelfMarker), name: NSNotification.Name(rawValue: "WillEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeAllAnimation), name: NSNotification.Name(rawValue: "WillResignActive"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "WillEnterForeground"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "WillResignActive"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeAllAnimation() {
        self.layer.removeAllAnimations()
    }
    
    func getSelfAccountInfo() {
        let getSelfInfo = FaeUser()
        getSelfInfo.getAccountBasicInfo({(status: Int, message: Any?) in
            guard status / 100 == 2 else {
                self.mapAvatar = 1
                self.reloadSelfMarker()
                return
            }
            let selfUserInfoJSON = JSON(message!)
            userFirstname = selfUserInfoJSON["first_name"].stringValue
            userLastname = selfUserInfoJSON["last_name"].stringValue
            userBirthday = selfUserInfoJSON["birthday"].stringValue
            userUserGender = selfUserInfoJSON["gender"].stringValue
            userUserName = selfUserInfoJSON["user_name"].stringValue
            if userStatus == 5 {
                return
            }
            userMiniAvatar = selfUserInfoJSON["mini_avatar"].intValue
            self.mapAvatar = selfUserInfoJSON["mini_avatar"].intValue
            self.reloadSelfMarker()
        })
    }
    
    func loadSelfMarkerSubview() {
        selfMarkerIcon = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        selfMarkerIcon.adjustsImageWhenHighlighted = false
        selfMarkerIcon.layer.zPosition = 5
        selfMarkerIcon.center = anchorPoint
        addSubview(selfMarkerIcon)
    }
    
    func reloadSelfMarker() {
        if myPositionCircle_1 != nil {
            myPositionCircle_1.removeFromSuperview()
            myPositionCircle_2.removeFromSuperview()
            myPositionCircle_3.removeFromSuperview()
        }
        myPositionCircle_1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        myPositionCircle_2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        myPositionCircle_3 = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        myPositionCircle_1.layer.zPosition = 0
        myPositionCircle_2.layer.zPosition = 1
        myPositionCircle_3.layer.zPosition = 2
        myPositionCircle_1.center = anchorPoint
        myPositionCircle_2.center = anchorPoint
        myPositionCircle_3.center = anchorPoint
        myPositionCircle_1.isUserInteractionEnabled = false
        myPositionCircle_2.isUserInteractionEnabled = false
        myPositionCircle_3.isUserInteractionEnabled = false
        myPositionCircle_1.image = UIImage(named: "myPosition_outside")
        myPositionCircle_2.image = UIImage(named: "myPosition_outside")
        myPositionCircle_3.image = UIImage(named: "myPosition_outside")
        
        addSubview(myPositionCircle_3)
        addSubview(myPositionCircle_2)
        addSubview(myPositionCircle_1)
        
        selfMarkerAnimation()
    }
    
    func selfMarkerAnimation() {
        UIView.animate(withDuration: 2.4, delay: 0, options: [.repeat, .curveEaseIn, .beginFromCurrentState], animations: ({
            if self.myPositionCircle_1 != nil {
                self.myPositionCircle_1.alpha = 0.0
                self.myPositionCircle_1.frame = CGRect(x: -38, y: -38, width: 120, height: 120)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 0.8, options: [.repeat, .curveEaseIn, .beginFromCurrentState], animations: ({
            if self.myPositionCircle_2 != nil {
                self.myPositionCircle_2.alpha = 0.0
                self.myPositionCircle_2.frame = CGRect(x: -38, y: -38, width: 120, height: 120)
            }
        }), completion: nil)
        
        UIView.animate(withDuration: 2.4, delay: 1.6, options: [.repeat, .curveEaseIn, .beginFromCurrentState], animations: ({
            if self.myPositionCircle_3 != nil {
                self.myPositionCircle_3.alpha = 0.0
                self.myPositionCircle_3.frame = CGRect(x: -38, y: -38, width: 120, height: 120)
            }
        }), completion: nil)
    }
}

class UserPinAnnotationView: MKAnnotationView {
    
    var imageView: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        layer.zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assignImage(_ image: UIImage) {
        imageView.image = image
    }
}

class PlacePinAnnotationView: MKAnnotationView {
    
    var imageView: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 60, height: 64)
        imageView = UIImageView(frame: CGRect(x: 30, y: 64, width: 0, height: 0))
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        layer.zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assignImage(_ image: UIImage) {
        // when an image is set for the annotation view,
        // it actually adds the image to the image view
        imageView.image = image
    }
}

class SocialPinAnnotationView: MKAnnotationView {
    
    var imageView: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 60, height: 61)
        imageView = UIImageView(frame: CGRect(x: 30, y: 61, width: 0, height: 0))
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        layer.zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assignImage(_ image: UIImage) {
        // when an image is set for the annotation view,
        // it actually adds the image to the image view
        imageView.image = image
    }
}
