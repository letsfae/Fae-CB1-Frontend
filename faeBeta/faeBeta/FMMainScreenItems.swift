//
//  MainScreenButtons.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import MapKit
import CCHMapClusterController

extension FaeMapViewController {
    
    // MARK: -- Load Map
    func loadMapView() {
        faeMapView = MKMapView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        faeMapView.delegate = self
        view.addSubview(faeMapView)
        faeMapView.showsPointsOfInterest = false
        faeMapView.showsCompass = false
        faeMapView.delegate = self
        faeMapView.showsUserLocation = true
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(self.mapViewTapAt(_:)))
        faeMapView.addGestureRecognizer(tapGesture)
        
        mapClusterManager = CCHMapClusterController(mapView: faeMapView)
        mapClusterManager.cellSize = 50
        mapClusterManager.marginFactor = 0.25
        mapClusterManager.delegate = self
        mapClusterManager.clusterer = CCHNearCenterMapClusterer()

        let coordinateRegion = MKCoordinateRegionMakeWithDistance(LocManager.shared.curtLoc.coordinate, 3000, 3000)
        faeMapView.setRegion(coordinateRegion, animated: false)
        refreshMap(pins: false, users: true, places: true)
    }
    
    func firstUpdateLocation() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(LocManager.shared.curtLoc.coordinate, 3000, 3000)
        faeMapView.setRegion(coordinateRegion, animated: false)
        refreshMap(pins: false, users: true, places: true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "firstUpdateLocation"), object: nil)
    }
    
    // MARK: -- Load Map Main Screen Buttons
    func loadButton() {
        imgSchbarShadow = UIImageView()
        imgSchbarShadow.frame = CGRect(x: 2, y: 17, width: 410 * screenWidthFactor, height: 60)
        imgSchbarShadow.image = #imageLiteral(resourceName: "mapSearchBar")
        view.addSubview(imgSchbarShadow)
        imgSchbarShadow.layer.zPosition = 500
        imgSchbarShadow.isUserInteractionEnabled = true
        
        // Left window on main map to open account system
        btnLeftWindow = UIButton()
        btnLeftWindow.setImage(#imageLiteral(resourceName: "mapLeftMenu"), for: .normal)
        imgSchbarShadow.addSubview(btnLeftWindow)
        btnLeftWindow.addTarget(self, action: #selector(self.actionLeftWindowShow(_:)), for: .touchUpInside)
        imgSchbarShadow.addConstraintsWithFormat("H:|-6-[v0(48)]", options: [], views: btnLeftWindow)
        imgSchbarShadow.addConstraintsWithFormat("V:|-6-[v0(48)]", options: [], views: btnLeftWindow)
        btnLeftWindow.adjustsImageWhenDisabled = false
        
        let imgSearchIcon = UIImageView()
        imgSearchIcon.image = #imageLiteral(resourceName: "searchBarIcon")
        imgSchbarShadow.addSubview(imgSearchIcon)
        imgSchbarShadow.addConstraintsWithFormat("H:|-54-[v0(15)]", options: [], views: imgSearchIcon)
        imgSchbarShadow.addConstraintsWithFormat("V:|-23-[v0(15)]", options: [], views: imgSearchIcon)
        
        lblSearchContent = UILabel()
        lblSearchContent.text = "Search Fae Map"
        lblSearchContent.textAlignment = .left
        lblSearchContent.lineBreakMode = .byTruncatingTail
        lblSearchContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblSearchContent.textColor = UIColor._182182182()
        imgSchbarShadow.addSubview(lblSearchContent)
        imgSchbarShadow.addConstraintsWithFormat("H:|-78-[v0]-60-|", options: [], views: lblSearchContent)
        imgSchbarShadow.addConstraintsWithFormat("V:|-19-[v0(25)]", options: [], views: lblSearchContent)
        
        // Open main map search
        btnMainMapSearch = UIButton()
        // Vicky 07/28/17
//        btnMainMapSearch.backgroundColor = .blue
//        btnMainMapSearch.setTitle("Search Fae Map", for: .normal)
//        btnMainMapSearch.titleLabel?.lineBreakMode = .byTruncatingTail
//        btnMainMapSearch.setTitleColor(UIColor._182182182(), for: .normal)
//        btnMainMapSearch.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
//        btnMainMapSearch.contentHorizontalAlignment = .left
        // Vicky 07/28/17 End
        imgSchbarShadow.addSubview(btnMainMapSearch)
        imgSchbarShadow.addConstraintsWithFormat("H:|-78-[v0]-60-|", options: [], views: btnMainMapSearch)
        imgSchbarShadow.addConstraintsWithFormat("V:|-6-[v0]-6-|", options: [], views: btnMainMapSearch)
        btnMainMapSearch.addTarget(self, action: #selector(self.actionMainScreenSearch(_:)), for: .touchUpInside)
        
        // Click to clear search results
        btnClearSearchRes = UIButton()
        btnClearSearchRes.setImage(#imageLiteral(resourceName: "mainScreenSearchClearSearchBar"), for: .normal)
        btnClearSearchRes.isHidden = true
        btnClearSearchRes.addTarget(self, action: #selector(self.actionClearSearchResults(_:)), for: .touchUpInside)
        imgSchbarShadow.addSubview(btnClearSearchRes)
        imgSchbarShadow.addConstraintsWithFormat("H:[v0(36.45)]-10-|", options: [], views: btnClearSearchRes)
        imgSchbarShadow.addConstraintsWithFormat("V:|-6-[v0]-6-|", options: [], views: btnClearSearchRes)
        
        // Click to back to north
        btnCompass = FMCompass()
        btnCompass.mapView = faeMapView
        view.addSubview(btnCompass)
        btnCompass.nameCard = uiviewNameCard
        
        // Click to locate the current location
        btnLocateSelf = FMLocateSelf()
        btnLocateSelf.mapView = faeMapView
        view.addSubview(btnLocateSelf)
        btnLocateSelf.nameCard = uiviewNameCard
        
        // Open chat view
        btnOpenChat = UIButton(frame: CGRect(x: 12, y: 646*screenWidthFactor, width: 79, height: 79))
        btnOpenChat.setImage(#imageLiteral(resourceName: "mainScreenNoChat"), for: .normal)
        btnOpenChat.setImage(#imageLiteral(resourceName: "mainScreenHaveChat"), for: .selected)
        btnOpenChat.addTarget(self, action: #selector(self.actionChatWindowShow(_:)), for: .touchUpInside)
        view.addSubview(btnOpenChat)
        btnOpenChat.layer.zPosition = 500
        
        // Show the number of unread messages on main map
        lblUnreadCount = UILabel(frame: CGRect(x: 55, y: 1, width: 25, height: 22))
        lblUnreadCount.backgroundColor = UIColor.init(red: 102/255, green: 192/255, blue: 251/255, alpha: 1)
        lblUnreadCount.layer.cornerRadius = 11
        lblUnreadCount.layer.masksToBounds = true
        lblUnreadCount.layer.opacity = 0.9
        lblUnreadCount.text = "1"
        lblUnreadCount.textAlignment = .center
        lblUnreadCount.textColor = UIColor.white
        lblUnreadCount.font = UIFont(name: "AvenirNext-DemiBold", size: 13)
        btnOpenChat.addSubview(lblUnreadCount)
        
        // Create pin on main map
        btnDiscovery = UIButton(frame: CGRect(x: 323*screenWidthFactor, y: 646*screenWidthFactor, width: 79, height: 79))
        btnDiscovery.setImage(UIImage(named: "mainScreenDiscovery"), for: .normal)
        view.addSubview(btnDiscovery)
        btnDiscovery.addTarget(self, action: #selector(self.actionCreatePin(_:)), for: .touchUpInside)
        btnDiscovery.layer.zPosition = 500
    }
}
