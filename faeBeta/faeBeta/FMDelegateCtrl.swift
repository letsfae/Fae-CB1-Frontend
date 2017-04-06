//
//  FMDelegateCtrl.swift
//  faeBeta
//
//  Created by Yue on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift

extension FaeMapViewController: MainScreenSearchDelegate, PinDetailDelegate, PinMenuDelegate, LeftSlidingMenuDelegate {
    
    // MainScreenSearchDelegate
    func animateToCameraFromMainScreenSearch(_ coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        self.faeMapView.animate(to: camera)
        updateTimerForUserPin()
        timerSetup()
        filterCircleAnimation()
        reloadSelfPosAnimation()
    }
    
    // PinDetailDelegate
    func dismissMarkerShadow(_ dismiss: Bool) {
        print("back from comment pin detail")
        updateTimerForUserPin()
        timerSetup()
        renewSelfLocation()
        animateMapFilterArrow()
        filterCircleAnimation()
        reloadSelfPosAnimation()
    }
    // PinDetailDelegate
    func animateToCamera(_ coordinate: CLLocationCoordinate2D, pinID: String) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        self.faeMapView.animate(to: camera)
    }
    // PinDetailDelegate
    func changeIconImage(marker: GMSMarker, type: String, status: String) {
        guard let userData = marker.userData as? [Int: AnyObject] else {
            return
        }
        guard let mapPin = userData.values.first as? MapPin else {
            return
        }
        var mapPin_new = mapPin
        mapPin_new.status = status
        marker.userData = [0: mapPin_new]
        marker.icon = pinIconSelector(type: type, status: status)
    }
    // PinDetailDelegate
    func disableSelfMarker(yes: Bool) {
        if yes {
//            self.selfMarker.map = nil
            self.subviewSelfMarker.isHidden = true
        } else {
            reloadSelfPosAnimation()
        }
    }

    // PinMenuDelegate
    func sendPinGeoInfo(pinID: String, type: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, zoom: Float) {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoom)
        faeMapView.camera = camera
        animatePinWhenItIsCreated(pinID: pinID, type: type)
        timerSetup()
        renewSelfLocation()
        animateMapFilterArrow()
        filterCircleAnimation()
        reloadSelfPosAnimation()
    }
    // PinMenuDelegate
    func whenDismissPinMenu() {
        timerSetup()
        renewSelfLocation()
        animateMapFilterArrow()
        filterCircleAnimation()
        reloadSelfPosAnimation()
    }
    
    // LeftSlidingMenuDelegate
    func userInvisible(isOn: Bool) {
        if !isOn {
            self.faeMapView.isMyLocationEnabled = false
            self.renewSelfLocation()
            reloadSelfPosAnimation()
            self.subviewSelfMarker.isHidden = false
            return
        }
        if userStatus == 5 {
            self.invisibleMode()
            self.faeMapView.isMyLocationEnabled = true
            self.subviewSelfMarker.isHidden = true
        }
    }
    // LeftSlidingMenuDelegate
    func jumpToMoodAvatar() {
        let moodAvatarVC = MoodAvatarViewController()
        self.present(moodAvatarVC, animated: true, completion: nil)
    }
    
    
    // LeftSlidingMenuDelegate
    func jumpToCollections() {
        
        let CollectionsBoardVC = CollectionsBoardViewController()
 
        CollectionsBoardVC.modalPresentationStyle = .overCurrentContext
        self.present(CollectionsBoardVC, animated: false, completion: nil)
        

    
    }
    
    // LeftSlidingMenuDelegate
    func logOutInLeftMenu() {
        self.jumpToWelcomeView(animated: true)
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    // LeftSlidingMenuDelegate
    func jumpToFaeUserMainPage() {
        self.jumpToMyFaeMainPage()
    }
    // LeftSlidingMenuDelegate
    func reloadSelfPosition() {
        reloadSelfPosAnimation()
    }
}
