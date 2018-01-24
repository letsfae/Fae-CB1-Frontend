//
//  MBPlaces.swift
//  faeBeta
//
//  Created by Vicky on 2017-08-17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

// for new Place page
extension MapBoardViewController: SeeAllPlacesDelegate, MapBoardPlaceTabDelegate {
    func loadPlaceSearchHeader() {
        btnSearchAllPlaces = UIButton(frame: CGRect(x: 50, y: 20 + device_offset_top, width: screenWidth - 50, height: 43))
        btnSearchAllPlaces.setImage(#imageLiteral(resourceName: "Search"), for: .normal)
        btnSearchAllPlaces.addTarget(self, action: #selector(searchAllPlaces(_:)), for: .touchUpInside)
        btnSearchAllPlaces.contentHorizontalAlignment = .left
        uiviewNavBar.addSubview(btnSearchAllPlaces)
        
        lblSearchContent = UILabel(frame: CGRect(x: 24, y: 10, width: 200, height: 25))
        lblSearchContent.textColor = UIColor._898989()
        lblSearchContent.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblSearchContent.text = "All Places"
        btnSearchAllPlaces.addSubview(lblSearchContent)
        
        btnSearchAllPlaces.isHidden = true
        
        // Click to clear search results
        btnClearSearchRes = UIButton()
        btnClearSearchRes.setImage(#imageLiteral(resourceName: "mainScreenSearchClearSearchBar"), for: .normal)
        btnClearSearchRes.isHidden = true
        btnClearSearchRes.addTarget(self, action: #selector(self.actionClearSearchResults(_:)), for: .touchUpInside)
        uiviewNavBar.addSubview(btnClearSearchRes)
        uiviewNavBar.addConstraintsWithFormat("H:[v0(36.45)]-5-|", options: [], views: btnClearSearchRes)
        uiviewNavBar.addConstraintsWithFormat("V:[v0(36.45)]-5.55-|", options: [], views: btnClearSearchRes)
    }
    
    func loadPlaceHeader() {
        uiviewPlaceHeader = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 246))
        uiviewPlaceHeader.backgroundColor = .white
        
        // draw two uiview of Map Options
        uiviewPlaceHedaderView1 = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 241))
        uiviewPlaceHedaderView2 = UIView(frame: CGRect(x: screenWidth, y: 0, width: screenWidth, height: 241))
        
        scrollViewPlaceHeader = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 241))
        scrollViewPlaceHeader.delegate = self
        scrollViewPlaceHeader.isPagingEnabled = true
        scrollViewPlaceHeader.showsHorizontalScrollIndicator = false
        scrollViewPlaceHeader.addSubview(uiviewPlaceHedaderView1)
        scrollViewPlaceHeader.addSubview(uiviewPlaceHedaderView2)
        scrollViewPlaceHeader.contentSize = CGSize(width: screenWidth * 2, height: 241)
        uiviewPlaceHeader.addSubview(scrollViewPlaceHeader)
        
        // draw two dots - page control
        pageCtrlPlace = UIPageControl(frame: CGRect(x: 0, y: 212, width: screenWidth, height: 8))
        pageCtrlPlace.numberOfPages = 2
        pageCtrlPlace.currentPage = 0
        pageCtrlPlace.pageIndicatorTintColor = UIColor._182182182()
        pageCtrlPlace.currentPageIndicatorTintColor = UIColor._2499090()
        pageCtrlPlace.addTarget(self, action: #selector(changePage(_:)), for: .valueChanged)
        uiviewPlaceHeader.addSubview(pageCtrlPlace)
        
        let uiviewBottomSeparator = UIView(frame: CGRect(x: 0, y: 241, width: screenWidth, height: 5))
        uiviewBottomSeparator.backgroundColor = UIColor(r: 241, g: 241, b: 241, alpha: 100)
        uiviewPlaceHeader.addSubview(uiviewBottomSeparator)
        
        loadPlaceHeaderView(uiview: uiviewPlaceHedaderView1, imgPlace: imgPlaces1, arrPlaceName: arrPlaceNames1, tag: 0)
        loadPlaceHeaderView(uiview: uiviewPlaceHedaderView2, imgPlace: imgPlaces2, arrPlaceName: arrPlaceNames2, tag: 6)
    }
    
    fileprivate func loadPlaceHeaderView(uiview: UIView, imgPlace: [UIImage], arrPlaceName: [String], tag: Int) {
        var btnPlaces = [UIButton]()
        var lblPlaces = [UILabel]()
        
        for _ in 0..<6 {
            btnPlaces.append(UIButton(frame: CGRect(x: 60, y: 20, width: 58, height: 58)))
            lblPlaces.append(UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 18)))
        }
        
        for i in 0..<6 {
            if i >= 3 {
                btnPlaces[i].frame.origin.y = 117
            }
            if i == 1 || i == 4 {
                btnPlaces[i].frame.origin.x = (screenWidth - 58) / 2
            } else if i == 2 || i == 5 {
                btnPlaces[i].frame.origin.x = screenWidth - 118
            }
            
            lblPlaces[i].center = CGPoint(x: btnPlaces[i].center.x, y: btnPlaces[i].center.y + 43)
            
            uiview.addSubview(btnPlaces[i])
            uiview.addSubview(lblPlaces[i])
            
            btnPlaces[i].layer.borderColor = UIColor._225225225().cgColor
            btnPlaces[i].layer.borderWidth = 2
            btnPlaces[i].layer.cornerRadius = 8.0
            btnPlaces[i].contentMode = .scaleAspectFit
            btnPlaces[i].layer.masksToBounds = true
            btnPlaces[i].setImage(imgPlace[i], for: .normal)
            btnPlaces[i].tag = i + tag
            btnPlaces[i].addTarget(self, action: #selector(searchByCategories(_:)), for: .touchUpInside)
            
            lblPlaces[i].text = arrPlaceName[i]
            lblPlaces[i].textAlignment = .center
            lblPlaces[i].textColor = UIColor._138138138()
            lblPlaces[i].font = UIFont(name: "AvenirNext-Medium", size: 13)
        }
    }
    
    func loadPlaceTabView() {
        uiviewPlaceTab = PlaceTabView()
        uiviewPlaceTab.delegate = self
        uiviewPlaceTab.addGestureRecognizer(setGestureRecognizer())
        view.addSubview(uiviewPlaceTab)
    }
    
    @objc func changePage(_ sender: Any?) {
        scrollViewPlaceHeader.contentOffset.x = screenWidth * CGFloat(pageCtrlPlace.currentPage)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageCtrlPlace.currentPage = scrollViewPlaceHeader.contentOffset.x == 0 ? 0 : 1
    }
    
    func getPlaceInfo(content: String = "", source: String = "categories") {
        FaeSearch.shared.whereKey("content", value: content)
        FaeSearch.shared.whereKey("source", value: source)
        FaeSearch.shared.whereKey("type", value: "place")
        FaeSearch.shared.whereKey("size", value: "200")
        FaeSearch.shared.whereKey("radius", value: "99999999")
        FaeSearch.shared.whereKey("offset", value: "0")
        FaeSearch.shared.search { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfoJsonArray = placeInfoJSON.array else {
                return
            }
            self.mbPlaces = placeInfoJsonArray.map({ PlacePin(json: $0) })
            
            self.lblSearchContent.text = content
            self.uiviewPlaceTab.btnPlaceTabLeft.isSelected = false
            self.uiviewPlaceTab.btnPlaceTabRight.isSelected = true
            self.jumpToSearchPlaces()
        }
    }
    
    @objc func searchByCategories(_ sender: UIButton) {
        var content = ""
        switch sender.tag {
        case 0:
            content = "Restaurants"
            break
        case 1:
            content = "Bars"
            break
        case 2:
            content = "Shopping"
            break
        case 3:
            content = "Coffee"
            break
        case 4:
            content = "Parks"
            break
        case 5:
            content = "Hotels"
            break
        case 6:
            content = "Fast Food"
            break
        case 7:
            content = "Beer Bar"
            break
        case 8:
            content = "Cosmetics"
            break
        case 9:
            content = "Fitness"
            break
        case 10:
            content = "Groceries"
            break
        case 11:
            content = "Pharmacy"
            break
        default:
            break
        }
        getPlaceInfo(content: content)
    }
    
    @objc func searchAllPlaces(_ sender: UIButton) {
        let searchVC = BoardsSearchViewController()
        searchVC.enterMode = .place
        searchVC.delegate = self
        searchVC.strSearchedPlace = lblSearchContent.text
        searchVC.strPlaceholder = lblSearchContent.text
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc func actionClearSearchResults(_ sender: UIButton) {
        lblSearchContent.text = "All Places"
        btnClearSearchRes.isHidden = true
        mbPlaces = arrAllPlaces
        tblMapBoard.reloadData()
    }
    
    // SeeAllPlacesDelegate
    func jumpToAllPlaces(places: [PlacePin], title: String) {
        let vc = AllPlacesViewController()
        vc.recommendedPlaces = places
        vc.strTitle = title
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func jumpToPlaceDetail(place: PlacePin) {
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = place
        vcPlaceDetail.allPlaces = mbPlaces
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
    
    // SeeAllPlacesDelegate End
    
    // MapBoardPlaceTabDelegate
    func jumpToRecommendedPlaces() {
        placeTableMode = .recommend
        btnNavBarMenu.isHidden = false
        btnClearSearchRes.isHidden = true
        btnSearchAllPlaces.isHidden = true
        tblMapBoard.tableHeaderView = uiviewPlaceHeader
        reloadTableMapBoard()
    }
    
    func jumpToSearchPlaces() {
        placeTableMode = .search
        btnNavBarMenu.isHidden = true
        if lblSearchContent.text != "All Places" {
            btnClearSearchRes.isHidden = false
        }
        btnSearchAllPlaces.isHidden = false
        tblMapBoard.tableHeaderView = nil
        reloadTableMapBoard()
    }
    // MapBoardPlaceTabDelegate End

    // BoardsSearchDelegate
    func jumpToPlaceSearchResult(searchText: String, places: [PlacePin]) {
        btnClearSearchRes.isHidden = false
        lblSearchContent.text = searchText
        
        mbPlaces.removeAll()
        mbPlaces = places
        tblMapBoard.reloadData()
    }
    
    func jumpToLocationSearchResult(icon: UIImage, searchText: String, location: CLLocation) {
        lblAllCom.text = searchText
        imgIconBeforeAllCom.image = icon
//        getMBPlaceInfo(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        tblMapBoard.reloadData()
    }
}

