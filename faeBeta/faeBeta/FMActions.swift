//
//  FMActions.swift
//  faeBeta
//
//  Created by Yue on 11/16/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension FaeMapViewController {
    
    func renewSelfLocation() {
        DispatchQueue.global(qos: .default).async {
            let selfLocation = FaeMap()
            selfLocation.whereKey("geo_latitude", value: "\(LocManager.shared.curtLat)")
            selfLocation.whereKey("geo_longitude", value: "\(LocManager.shared.curtLong)")
            selfLocation.renewCoordinate {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    // print("Successfully renew self position")
                } else {
                    print("[renewSelfLocation] fail")
                }
            }
        }
    }
    
    func actionMainScreenSearch(_ sender: UIButton) {
        uiviewNameCard.hide() {
            self.mapGesture(isOn: true)
        }
        uiviewFilterMenu.btnHideMFMenu.sendActions(for: .touchUpInside)
        let searchVC = MapSearchViewController()
        searchVC.faeMapView = self.faeMapView
        searchVC.delegate = self
        searchVC.strSearchedPlace = lblSearchContent.text
        navigationController?.pushViewController(searchVC, animated: false)
    }
    
    func actionClearSearchResults(_ sender: UIButton) {
        lblSearchContent.text = "Search Fae Map"
        lblSearchContent.textColor = UIColor._182182182()
        btnClearSearchRes.isHidden = true
        PLACE_ENABLE = true
        uiviewPlaceBar.alpha = 0
        uiviewPlaceBar.state = .map
        placeResultTbl.alpha = 0
        btnTapToShowResultTbl.alpha = 0
        mapGesture(isOn: true)
        deselectAllAnnotations()
        mapClusterManager.removeAnnotations(faePlacePins) {
            self.faePlacePins.removeAll()
            self.updatePlacePins()
            self.updateUserPins()
        }
        mapClusterManager.maxZoomLevelForClustering = Double.greatestFiniteMagnitude
    }
    
    func actionPlacePinAction(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            break
        case 2:
            break
        case 3:
            break
        case 4:
            break
        default:
            break
        }
    }
    
    func actionLeftWindowShow(_ sender: UIButton) {
        uiviewNameCard.hide() {
            self.mapGesture(isOn: true)
        }
        let leftMenuVC = LeftSlidingMenuViewController()
        leftMenuVC.displayName = Key.shared.nickname ?? "someone"
        leftMenuVC.delegate = self
        leftMenuVC.modalPresentationStyle = .overCurrentContext
        self.present(leftMenuVC, animated: false, completion: nil)
    }
    
    func actionShowResultTbl(_ sender: UIButton) {
        placeResultTbl.show()
    }
    
    func actionChatWindowShow(_ sender: UIButton) {
        uiviewNameCard.hide() {
            self.mapGesture(isOn: true)
        }
        UINavigationBar.appearance().shadowImage = imgNavBarDefaultShadow
        // check if the user's logged in the backendless
        //let chatVC = UIStoryboard(name: "Chat", bundle: nil).instantiateInitialViewController()! as! RecentViewController
        let chatVC = RecentViewController()
        chatVC.backClosure = {
            (backNum: Int) -> Void in
            //self.count = backNum
        }
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func actionCreatePin(_ sender: UIButton) {
        uiviewNameCard.hide() {
            self.mapGesture(isOn: true)
        }
        if faeUserPins.isEmpty {
            updateTimerForUserPin()
        } else {
            timerUserPin?.invalidate()
            timerUserPin = nil
            for faeUser in faeUserPins {
                faeUser.isValid = false
            }
            mapClusterManager.removeAnnotations(faeUserPins) {
                self.faeUserPins.removeAll()
            }
        }
        
        /*
         uiviewNameCard.hide()
         let mapCenter_point = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
         let mapCenter_coor = faeMapView.convert(mapCenter_point, toCoordinateFrom: nil)
         invalidateAllTimer()
         let pinMenuVC = PinMenuViewController()
         pinMenuVC.modalPresentationStyle = .overCurrentContext
         Key.shared.dblAltitude = faeMapView.camera.altitude
         Key.shared.selectedLoc = mapCenter_coor
         pinMenuVC.delegate = self
         self.present(pinMenuVC, animated: false, completion: nil)
         */
    }
    
    func actionCancelSelecting() {
        mapMode = .routing
    }
}
