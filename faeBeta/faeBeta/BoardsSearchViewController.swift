//
//  BoardsSearchViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-08-17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

@objc protocol BoardsSearchDelegate: class {
    //    func backToPlaceSearchView()
    //    func backToLocationSearchView()
    @objc optional func jumpToPlaceSearchResult(searchText: String, places: [PlacePin])
    @objc optional func jumpToLocationSearchResult(icon: UIImage, searchText: String, location: CLLocation)
    @objc optional func chooseLocationOnMap()
    @objc optional func sendLocationBack(address: RouteAddress)
}
enum EnterMode {
    case place
    case location
}

class BoardsSearchViewController: UIViewController, FaeSearchBarTestDelegate, UITableViewDelegate, UITableViewDataSource {
    var enterMode: EnterMode!
    weak var delegate: BoardsSearchDelegate?
    var arrLocList = ["Los Angeles CA, United States", "Long Beach CA, United States", "London ON, Canada", "Los Angeles CA, United States", "Los Angeles CA, United States", "Los Angeles CA, United Statesssss", "Los Angeles CA, United States", "Los Angeles CA, United States", "Los Angeles CA, United States", "Long Beach CA, United States", "San Francisco CA, United States"]
    //    var cityList = ["CA, United States", "CA, United States", "CA, United States", ""]
    var arrCurtLocList = ["Use my Current Location", "Choose Location on Map"]
    
    var searchedPlaces = [PlacePin]()
    var filteredPlaces = [PlacePin]()
    //    var searchedLocations = [String]()   有location数据后使用
    var filteredLocations = [String]()
    var searchedLoc: CLLocation!
    
    var btnBack: UIButton!
    var uiviewSearch: UIView!
    var uiviewPics: UIView!
    var schBar: FaeSearchBarTest!
    var schLocationBar: FaeSearchBarTest!
    var btnPlaces = [UIButton]()
    var lblPlaces = [UILabel]()
    var imgPlaces: [UIImage] = [#imageLiteral(resourceName: "place_result_5"), #imageLiteral(resourceName: "place_result_14"), #imageLiteral(resourceName: "place_result_4"), #imageLiteral(resourceName: "place_result_19"), #imageLiteral(resourceName: "place_result_30"), #imageLiteral(resourceName: "place_result_41")]
    var arrPlaceNames: [String] = ["Restaurants", "Bars", "Shopping", "Coffee Shop", "Parks", "Hotels"]
    var strSearchedPlace: String! = ""
    var strPlaceholder: String! = ""
    
    // uiviews with shadow under table views
    var uiviewSchResBg: UIView!
    var uiviewSchLocResBg: UIView!
    // table tblSearchRes used for search places & display table "use current location"
    var tblPlacesRes: UITableView!
    // table tblLocationRes used for search locations
    var tblLocationRes: UITableView!
    
    var uiviewNoResults: UIView!
    var lblNoResults: UILabel!
    
    // Joshua: Send label text back to start point or destination
    static var boolToDestination = false
    var boolCurtLocSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationController?.isNavigationBarHidden = true
        view.backgroundColor = UIColor._241241241()
        loadSearchBar()
        loadPlaceBtns()
        loadTable()
        loadNoResultsView()
        
        schBar.txtSchField.becomeFirstResponder()
        searchedLoc = LocManager.shared.curtLoc
        getPlaceInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var delay: Double = 0
        
        for i in 0..<6 {
            UIView.animate(withDuration: 0.8, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.btnPlaces[i].frame.size = CGSize(width: 58, height: 58)
                self.btnPlaces[i].alpha = 1
                self.lblPlaces[i].center.y += 43
                self.lblPlaces[i].alpha = 1
                if i >= 3 {
                    self.btnPlaces[i].frame.origin.y = 117
                } else {
                    self.btnPlaces[i].frame.origin.y = 20
                }
                if i == 1 || i == 4 {
                    self.btnPlaces[i].frame.origin.x = (screenWidth - 16 - 58) / 2
                } else if i == 2 || i == 5 {
                    self.btnPlaces[i].frame.origin.x = screenWidth - 126
                } else {
                    self.btnPlaces[i].frame.origin.x = 52
                }
            }, completion: nil)
            delay += 0.1
        }
    }
    
    // shows "no results"
    func loadNoResultsView() {
        uiviewNoResults = UIView(frame: CGRect(x: 8, y: 124 - 48, width: screenWidth - 16, height: 100))
        uiviewNoResults.backgroundColor = .white
        view.addSubview(uiviewNoResults)
        lblNoResults = UILabel(frame: CGRect(x: 0, y: 0, width: 211, height: 50))
        uiviewNoResults.addSubview(lblNoResults)
        lblNoResults.center = CGPoint(x: screenWidth / 2, y: 50)
        lblNoResults.numberOfLines = 0
        lblNoResults.text = "No Results Found...\nTry a Different Search!"
        lblNoResults.textAlignment = .center
        lblNoResults.textColor = UIColor._115115115()
        lblNoResults.font = UIFont(name: "AvenirNext-Medium", size: 15)
        uiviewNoResults.layer.cornerRadius = 2
        addShadow(uiviewNoResults)
    }
    
    func loadSearchBar() {
        uiviewSearch = UIView()
        view.addSubview(uiviewSearch)
        uiviewSearch.backgroundColor = .white
        view.addConstraintsWithFormat("H:|-8-[v0]-8-|", options: [], views: uiviewSearch)
        view.addConstraintsWithFormat("V:|-23-[v0(48)]", options: [], views: uiviewSearch)
        uiviewSearch.layer.cornerRadius = 2
        addShadow(uiviewSearch)
        
        btnBack = UIButton(frame: CGRect(x: 3, y: 0, width: 34.5, height: 48))
        btnBack.setImage(#imageLiteral(resourceName: "mainScreenSearchToFaeMap"), for: .normal)
        btnBack.addTarget(self, action: #selector(backToBoards(_:)), for: .touchUpInside)
        uiviewSearch.addSubview(btnBack)
        
        schBar = FaeSearchBarTest(frame: CGRect(x: 38, y: 0, width: screenWidth - 38, height: 48))
        schBar.delegate = self
        schBar.txtSchField.placeholder = strPlaceholder
        if enterMode == .place {
            //            schBar.txtSchField.placeholder = "All Places"
            //            if strSearchedPlace != "All Places" {
            //                schBar.txtSchField.text = strSearchedPlace
            //                schBar.btnClose.isHidden = false
            //            }
        } else if enterMode == .location {
            schBar.imgSearch.image = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        }
        uiviewSearch.addSubview(schBar)
    }
    
    // load six buttons
    func loadPlaceBtns() {
        uiviewPics = UIView(frame: CGRect(x: 8, y: 124 - 48, width: screenWidth - 16, height: 214))
        uiviewPics.backgroundColor = .white
        view.addSubview(uiviewPics)
        uiviewPics.layer.cornerRadius = 2
        addShadow(uiviewPics)
        
        for _ in 0..<6 {
            btnPlaces.append(UIButton(frame: CGRect(x: 52 + 29, y: 20 + 29, width: 0, height: 0)))
            lblPlaces.append(UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 18)))
        }
        
        for i in 0..<6 {
            btnPlaces[i].alpha = 0
            if i >= 3 {
                btnPlaces[i].frame.origin.y = 117 + 29
            }
            if i == 1 || i == 4 {
                btnPlaces[i].frame.origin.x = (screenWidth - 16 - 58) / 2 + 29
            } else if i == 2 || i == 5 {
                btnPlaces[i].frame.origin.x = screenWidth - 126 + 29
            }
            
            lblPlaces[i].center = CGPoint(x: btnPlaces[i].center.x, y: btnPlaces[i].center.y)
            lblPlaces[i].alpha = 0
            
            uiviewPics.addSubview(btnPlaces[i])
            uiviewPics.addSubview(lblPlaces[i])
            
            btnPlaces[i].layer.borderColor = UIColor._225225225().cgColor
            btnPlaces[i].layer.borderWidth = 2
            btnPlaces[i].layer.cornerRadius = 8.0
            btnPlaces[i].contentMode = .scaleAspectFit
            btnPlaces[i].layer.masksToBounds = true
            btnPlaces[i].setImage(imgPlaces[i], for: .normal)
            btnPlaces[i].tag = i
            btnPlaces[i].addTarget(self, action: #selector(searchByCategories(_:)), for: .touchUpInside)
            
            lblPlaces[i].text = arrPlaceNames[i]
            lblPlaces[i].textAlignment = .center
            lblPlaces[i].textColor = UIColor._138138138()
            lblPlaces[i].font = UIFont(name: "AvenirNext-Medium", size: 13)
        }
    }
    
    func loadTable() {
        // background view with shadow of table tblPlacesRes
        uiviewSchResBg = UIView(frame: CGRect(x: 8, y: 124 - 48, width: screenWidth - 16, height: screenHeight - 139)) // 124 + 15
        view.addSubview(uiviewSchResBg)
        addShadow(uiviewSchResBg)
        
        tblPlacesRes = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth - 16, height: screenHeight - 139))
        tblPlacesRes.dataSource = self
        tblPlacesRes.delegate = self
        uiviewSchResBg.addSubview(tblPlacesRes)
        tblPlacesRes.separatorStyle = .none
        tblPlacesRes.backgroundColor = .white
        tblPlacesRes.layer.masksToBounds = true
        tblPlacesRes.layer.cornerRadius = 2
        tblPlacesRes.register(PlacesListCell.self, forCellReuseIdentifier: "SearchPlaces")
        tblPlacesRes.register(LocationListCell.self, forCellReuseIdentifier: "MyFixedCell")
        
        // background view with shadow of table tblLocationRes
        uiviewSchLocResBg = UIView(frame: CGRect(x: 8, y: 124 - 48, width: screenWidth - 16, height: screenHeight - 240)) // 124 + 20 + 2 * 48
        uiviewSchLocResBg.backgroundColor = .clear
        view.addSubview(uiviewSchLocResBg)
        addShadow(uiviewSchLocResBg)
        
        tblLocationRes = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth - 16, height: screenHeight - 240))
        tblLocationRes.dataSource = self
        tblLocationRes.delegate = self
        uiviewSchLocResBg.addSubview(tblLocationRes)
        tblLocationRes.layer.cornerRadius = 2
        tblLocationRes.layer.masksToBounds = true
        tblLocationRes.separatorStyle = .none
        tblLocationRes.backgroundColor = .white
        tblLocationRes.register(LocationListCell.self, forCellReuseIdentifier: "SearchLocation")
    }
    
    // FaeSearchBarTestDelegate
    func searchBarTextDidBeginEditing(_ searchBar: FaeSearchBarTest) {
        switch enterMode {
        case .place:
            break
        case .location:
            //            if searchBar.txtSchField.text == "Current Location" {
            //                searchBar.txtSchField.placeholder = searchBar.txtSchField.text
            //                searchBar.txtSchField.text = ""
            //                searchBar.btnClose.isHidden = true
            //            }
            break
        default:
            break
        }
        showOrHideViews(searchText: searchBar.txtSchField.text!)
    }
    
    func searchBar(_ searchBar: FaeSearchBarTest, textDidChange searchText: String) {
        switch enterMode {
        case .place:
            filteredPlaces.removeAll()
            for searchedPlace in searchedPlaces {
                if searchedPlace.name.lowercased().range(of: searchText.lowercased()) != nil {
                    filteredPlaces.append(searchedPlace)
                }
            }
            break
        case .location:
            filteredLocations.removeAll()
            for location in arrLocList {
                if location.lowercased().range(of: searchText.lowercased()) != nil {
                    filteredLocations.append(location)
                }
            }
            break
        default:
            break
        }
        
        showOrHideViews(searchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: FaeSearchBarTest) {
        searchBar.txtSchField.resignFirstResponder()
        
        switch enterMode {
        case .place:
            delegate?.jumpToPlaceSearchResult?(searchText: searchBar.txtSchField.text!, places: filteredPlaces)
            navigationController?.popViewController(animated: false)
        case .location:
            break
        default:
            break
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: FaeSearchBarTest) {
        searchBar.txtSchField.becomeFirstResponder()
    }
    // End of FaeSearchBarTestDelegate
    
    // show or hide uiviews/tableViews, change uiviews/tableViews size & origin.y
    func showOrHideViews(searchText: String) {
        // search places
        if enterMode == .place {
            uiviewSchLocResBg.isHidden = true
            // for uiviewPics & uiviewSchResBg
            if searchText != "" && filteredPlaces.count != 0 {
                uiviewPics.isHidden = true
                uiviewSchResBg.isHidden = false
                uiviewSchResBg.frame.origin.y = 124 - 48
                uiviewSchResBg.frame.size.height = min(screenHeight - 139, CGFloat(68 * filteredPlaces.count))
                tblPlacesRes.frame.size.height = uiviewSchResBg.frame.size.height
            } else {
                uiviewPics.isHidden = false
                uiviewSchResBg.isHidden = true
                if searchText == "" {
                    uiviewPics.frame.origin.y = 124 - 48
                } else {
                    uiviewPics.frame.origin.y = 124 - 48 + uiviewNoResults.frame.height + 5
                }
            }
            
            // for uiviewNoResults
            if searchText != "" && filteredPlaces.count == 0 {
                uiviewNoResults.isHidden = false
            } else {
                uiviewNoResults.isHidden = true
            }
            tblPlacesRes.isScrollEnabled = true
        } else { // search location
            uiviewPics.isHidden = true
            uiviewNoResults.isHidden = true
            uiviewSchResBg.isHidden = false
            if boolCurtLocSelected {
                uiviewSchResBg.frame.size.height = 48
            } else {
                uiviewSchResBg.frame.size.height = CGFloat(arrCurtLocList.count * 48)
            }
            tblPlacesRes.frame.size.height = uiviewSchResBg.frame.size.height
            
            if searchText == "" || filteredLocations.count == 0 {
                uiviewSchResBg.frame.origin.y = 124 - 48
                uiviewSchLocResBg.isHidden = true
            } else {
                uiviewSchLocResBg.isHidden = false
                uiviewSchLocResBg.frame.size.height = min(screenHeight - 240, CGFloat(48 * filteredLocations.count))
                tblLocationRes.frame.size.height = uiviewSchLocResBg.frame.size.height
                uiviewSchResBg.frame.origin.y = 124 - 48 + uiviewSchLocResBg.frame.height + 5
            }
            tblPlacesRes.isScrollEnabled = false
            tblLocationRes.reloadData()
        }
        tblPlacesRes.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // search location
        if enterMode == .location {
            if tableView == tblLocationRes {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchLocation", for: indexPath as IndexPath) as! LocationListCell
                cell.lblLocationName.text = filteredLocations[indexPath.row]
                cell.bottomLine.isHidden = false
                if indexPath.row == tblLocationRes.numberOfRows(inSection: 0) - 1 {
                    cell.bottomLine.isHidden = true
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyFixedCell", for: indexPath as IndexPath) as! LocationListCell
                if boolCurtLocSelected {
                    cell.lblLocationName.text = arrCurtLocList[1]
                    cell.bottomLine.isHidden = true
                    return cell
                }
                cell.lblLocationName.text = arrCurtLocList[indexPath.row]
                cell.bottomLine.isHidden = false
                if indexPath.row == arrCurtLocList.count - 1 {
                    cell.bottomLine.isHidden = true
                }
                return cell
            }
        } else if enterMode == .place {
            // search places
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlaces", for: indexPath as IndexPath) as! PlacesListCell
            let place = filteredPlaces[indexPath.row]
            
            DispatchQueue.global(qos: .userInitiated).async {
                let img = UIImage(named: "place_result_\(place.class_2_icon_id)") ?? #imageLiteral(resourceName: "Awkward")
                DispatchQueue.main.async {
                    cell.imgIcon.image = img
                }
            }
            cell.lblPlaceName.text = place.name
            cell.lblAddress.text = place.address1 + ", " + place.address2
            cell.bottomLine.isHidden = false
            
            if indexPath.row == tblPlacesRes.numberOfRows(inSection: 0) - 1 {
                cell.bottomLine.isHidden = true
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Joshua: 0829 Modified
        if enterMode == .place {
            return filteredPlaces.count
        } else {
            if tableView == tblLocationRes {
                return filteredLocations.count
            } else {
                if boolCurtLocSelected {
                    return 1
                } else {
                    return arrCurtLocList.count
                }
            }
        }
        // End of Joshua: 0829 Modified
        //        return enterMode == .place ? filteredPlaces.count : (tableView == tblLocationRes ? filteredLocations.count : arrCurtLocList.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return enterMode == .place ? 68 : 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // search location
        if enterMode == .location {
            schBar.txtSchField.resignFirstResponder()
            if tableView == tblLocationRes {
                let address = RouteAddress(name: filteredLocations[indexPath.row])
                delegate?.sendLocationBack?(address: address)
                delegate?.jumpToLocationSearchResult?(icon: #imageLiteral(resourceName: "mapSearchCurrentLocation"), searchText: filteredLocations[indexPath.row], location: LocManager.shared.curtLoc)
                navigationController?.popViewController(animated: false)
            } else { // fixed cell - "Use my Current Location", "Choose Location on Map"
                if indexPath.row == 0 {
                    if boolCurtLocSelected {
                        navigationController?.popViewController(animated: false)
                        delegate?.chooseLocationOnMap?()
                        return
                    }
                    delegate?.jumpToLocationSearchResult?(icon: #imageLiteral(resourceName: "mb_iconBeforeCurtLoc"), searchText: "Current Location", location: LocManager.shared.curtLoc)
                    let address = RouteAddress(name: "Current Location")
                    delegate?.sendLocationBack?(address: address)
                    navigationController?.popViewController(animated: false)
                } else {
                    navigationController?.popViewController(animated: false)
                    delegate?.chooseLocationOnMap?()
                }
            }
        } else if enterMode == .place { // search places
            let selectedPlace = filteredPlaces[indexPath.row]
            let vc = PlaceDetailViewController()
            vc.place = selectedPlace
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func addShadow(_ uiview: UIView) {
        uiview.layer.shadowColor = UIColor._898989().cgColor
        uiview.layer.shadowRadius = 2.2
        uiview.layer.shadowOffset = CGSize(width: 0, height: 1)
        uiview.layer.shadowOpacity = 0.6
    }
    
    func backToBoards(_ sender: UIButton) {
        //        if enterMode == .place {
        //            delegate?.backToPlaceSearchView()
        //        } else {
        //            delegate?.backToLocationSearchView()
        //        }
        navigationController?.popViewController(animated: false)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        schBar.txtSchField.resignFirstResponder()
    }
    
    func getPlaceInfo() {
        let placesList = FaeMap()
        placesList.whereKey("geo_latitude", value: "\(searchedLoc.coordinate.latitude)")
        placesList.whereKey("geo_longitude", value: "\(searchedLoc.coordinate.longitude)")
        placesList.whereKey("radius", value: "50000")
        placesList.whereKey("type", value: "place")
        placesList.whereKey("max_count", value: "1000")
        placesList.getMapInformation { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                print("[loadMapSearchPlaceInfo] status/100 != 2")
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfoJsonArray = placeInfoJSON.array else {
                print("[loadMapSearchPlaceInfo] fail to parse map search place info")
                return
            }
            if placeInfoJsonArray.count <= 0 {
                print("[loadMapSearchPlaceInfo] array is nil")
                return
            }
            
            self.searchedPlaces.removeAll()
            
            for result in placeInfoJsonArray {
                let placeData = PlacePin(json: result)
                self.searchedPlaces.append(placeData)
            }
            print(self.searchedPlaces.count)
        }
    }
    
    func searchByCategories(_ sender: UIButton) {
        // tag = 0 - Restaurants - arrPlaceNames[0], 1 - Bars - arrPlaceNames[1],
        // 2 - Shopping - arrPlaceNames[2], 3 - Coffee Shop - arrPlaceNames[3],
        // 4 - Parks - arrPlaceNames[4], 5 - Hotels - arrPlaceNames[5]
        switch sender.tag {
        case 0:
            break
        case 1:
            break
        case 2:
            break
        case 3:
            break
        case 4:
            break
        case 5:
            break
        default:
            break
        }
    }
}