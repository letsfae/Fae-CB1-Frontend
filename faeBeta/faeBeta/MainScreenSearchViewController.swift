//
//  MainScreenSearchViewController.swift
//  faeBeta
//
//  Created by Yue on 10/29/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import GoogleMaps

protocol MainScreenSearchViewControllerDelegate {
    // Cancel marker's shadow when back to Fae Map
    func animateToCameraFromMainScreenSearch(coordinate: CLLocationCoordinate2D)
}

class MainScreenSearchViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, CustomSearchControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    var delegate: MainScreenSearchViewControllerDelegate?
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    let colorFae = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
    let fontColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
    
    var mapSelectLocation: GMSMapView!
    var imagePinOnMap: UIImageView!
    
    var currentLocation: CLLocation!
    let locManager = CLLocationManager()
    var currentLatitude: CLLocationDegrees = 34.0205378
    var currentLongitude: CLLocationDegrees = -118.2854081
    var latitudeForPin: CLLocationDegrees = 0
    var longitudeForPin: CLLocationDegrees = 0
    var willAppearFirstLoad = false
    
    var buttonClearSearchBar: UIButton!
    
    var blurViewMainScreenSearch: UIVisualEffectView!
    
    // MARK: -- Search Bar
    var uiviewTableSubview: UIView!
    var tblSearchResults = UITableView()
    var dataArray = [String]()
    var filteredArray = [String]()
    var shouldShowSearchResults = false
    var searchController: UISearchController!
    var customSearchController: CustomSearchController!
    var searchBarSubview: UIView!
    var placeholder = [GMSAutocompletePrediction]()
    
    var resultTableWidth: CGFloat {
        if UIScreen.mainScreen().bounds.width == 414 { // 5.5
            return 398
        }
        else if UIScreen.mainScreen().bounds.width == 320 { // 4.0
            return 308
        }
        else if UIScreen.mainScreen().bounds.width == 375 { // 4.7
            return 360.5
        }
        return 308
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBlurView()
        loadFunctionButtons()
        loadTableView()
        loadCustomSearchController()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateWithDuration(0.25, animations: ({
            self.searchBarSubview.center.y += self.searchBarSubview.frame.size.height
            self.blurViewMainScreenSearch.alpha = 1.0
        }), completion: { (done: Bool) in
            if done {
                self.customSearchController.customSearchBar.becomeFirstResponder()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadBlurView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        blurViewMainScreenSearch = UIVisualEffectView(effect: blurEffect)
        blurViewMainScreenSearch.frame = CGRectMake(0, 0, screenWidth, screenHeight)
        blurViewMainScreenSearch.alpha = 0.0
        self.view.addSubview(blurViewMainScreenSearch)
    }
    
    func loadFunctionButtons() {
        searchBarSubview = UIView(frame: CGRectMake(0, 0, screenWidth, 64))
        searchBarSubview.layer.zPosition = 1
        self.view.addSubview(searchBarSubview)
        self.searchBarSubview.center.y -= self.searchBarSubview.frame.size.height
        let backSubviewButton = UIButton(frame: CGRectMake(0, 0, screenWidth, screenHeight))
        self.searchBarSubview.addSubview(backSubviewButton)
        backSubviewButton.addTarget(self, action: #selector(MainScreenSearchViewController.actionDimissSearchBar(_:)), forControlEvents: .TouchUpInside)
        backSubviewButton.layer.zPosition = 0
        
        let viewToHideLeftSideSearchBar = UIView(frame: CGRectMake(0, 0, 50, 64))
        viewToHideLeftSideSearchBar.backgroundColor = UIColor.whiteColor()
        self.searchBarSubview.addSubview(viewToHideLeftSideSearchBar)
        viewToHideLeftSideSearchBar.layer.zPosition = 2
        
        let viewToHideRightSideSearchBar = UIView()
        viewToHideRightSideSearchBar.backgroundColor = UIColor.whiteColor()
        self.searchBarSubview.addSubview(viewToHideRightSideSearchBar)
        viewToHideRightSideSearchBar.layer.zPosition = 2
        self.searchBarSubview.addConstraintsWithFormat("H:[v0(50)]-0-|", options: [], views: viewToHideRightSideSearchBar)
        self.searchBarSubview.addConstraintsWithFormat("V:|-0-[v0(64)]", options: [], views: viewToHideRightSideSearchBar)
    }
    
    func loadCustomSearchController() {
        customSearchController = CustomSearchController(searchResultsController: self,
                                                        searchBarFrame: CGRectMake(18, 24, resultTableWidth, 36),
                                                        searchBarFont: UIFont(name: "AvenirNext-Medium", size: 20)!,
                                                        searchBarTextColor: fontColor,
                                                        searchBarTintColor: UIColor.whiteColor())
        customSearchController.customSearchBar.placeholder = "Search Fae Map                                         "
        customSearchController.customDelegate = self
        customSearchController.customSearchBar.layer.borderWidth = 2.0
        customSearchController.customSearchBar.layer.borderColor = UIColor.whiteColor().CGColor
        customSearchController.customSearchBar.tintColor = colorFae
        
        searchBarSubview.addSubview(customSearchController.customSearchBar)
        searchBarSubview.backgroundColor = UIColor.whiteColor()
        
        searchBarSubview.layer.borderColor = UIColor.whiteColor().CGColor
        searchBarSubview.layer.borderWidth = 1.0
        
        let buttonBackToFaeMap = UIButton(frame: CGRectMake(0, 32, 40.5, 18))
        buttonBackToFaeMap.setImage(UIImage(named: "mainScreenSearchToFaeMap"), forState: .Normal)
        self.searchBarSubview.addSubview(buttonBackToFaeMap)
        buttonBackToFaeMap.addTarget(self, action: #selector(MainScreenSearchViewController.actionDimissSearchBar(_:)), forControlEvents: .TouchUpInside)
        buttonBackToFaeMap.layer.zPosition = 3
        
        buttonClearSearchBar = UIButton()
        buttonClearSearchBar.setImage(UIImage(named: "mainScreenSearchClearSearchBar"), forState: .Normal)
        self.searchBarSubview.addSubview(buttonClearSearchBar)
        buttonClearSearchBar.addTarget(self,
                                       action: #selector(MainScreenSearchViewController.actionClearSearchBar(_:)),
                                       forControlEvents: .TouchUpInside)
        buttonClearSearchBar.layer.zPosition = 3
        self.searchBarSubview.addConstraintsWithFormat("H:[v0(17)]-15-|", options: [], views: buttonClearSearchBar)
        self.searchBarSubview.addConstraintsWithFormat("V:|-33-[v0(17)]", options: [], views: buttonClearSearchBar)
        buttonClearSearchBar.hidden = true
        
        let uiviewCommentPinUnderLine = UIView(frame: CGRectMake(0, 63, screenWidth, 1))
        uiviewCommentPinUnderLine.layer.borderWidth = 1
        uiviewCommentPinUnderLine.layer.borderColor = UIColor(red: 196/255, green: 195/255, blue: 200/255, alpha: 1.0).CGColor
        uiviewCommentPinUnderLine.layer.zPosition = 4
        self.searchBarSubview.addSubview(uiviewCommentPinUnderLine)
    }
    
    func actionDimissSearchBar(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func actionClearSearchBar(sender: UIButton) {
        customSearchController.customSearchBar.text = ""
    }
    
    // MARK: UISearchResultsUpdating delegate function
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        tblSearchResults.reloadData()
    }
    
    // MARK: CustomSearchControllerDelegate functions
    func didStartSearching() {
        shouldShowSearchResults = true
        tblSearchResults.reloadData()
        customSearchController.customSearchBar.becomeFirstResponder()
    }
    
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tblSearchResults.reloadData()
        }
        
        if placeholder.count > 0 {
            let placesClient = GMSPlacesClient()
            placesClient.lookUpPlaceID(placeholder[0].placeID!, callback: {
                (place, error) -> Void in
                GMSGeocoder().reverseGeocodeCoordinate(place!.coordinate, completionHandler: {
                    (response, error) -> Void in
                    if let selectedAddress = place?.coordinate {
                        self.delegate?.animateToCameraFromMainScreenSearch(selectedAddress)
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }
                })
            })
            self.customSearchController.customSearchBar.text = self.placeholder[0].attributedFullText.string
            self.customSearchController.customSearchBar.resignFirstResponder()
            self.searchBarTableHideAnimation()
        }
        
    }
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        tblSearchResults.reloadData()
    }
    
    func didChangeSearchText(searchText: String) {
        if(searchText != "") {
            buttonClearSearchBar.hidden = false
            let placeClient = GMSPlacesClient()
            placeClient.autocompleteQuery(searchText, bounds: nil, filter: nil) {
                (results, error : NSError?) -> Void in
                if(error != nil) {
                    print(error)
                }
                self.placeholder.removeAll()
                if results == nil {
                    return
                } else {
                    for result in results! {
                        print(result)
                        self.placeholder.append(result)
                    }
                    self.tblSearchResults.reloadData()
                }
                if self.placeholder.count > 0 {
                    self.searchBarTableShowAnimation()
                }
            }
        }
        else {
            buttonClearSearchBar.hidden = true
            self.placeholder.removeAll()
            searchBarTableHideAnimation()
            self.tblSearchResults.reloadData()
        }
    }
    
    func searchBarTableHideAnimation() {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: ({
            self.tblSearchResults.frame = CGRectMake(0, 0, self.resultTableWidth, 0)
            self.uiviewTableSubview.frame = CGRectMake(8, 76, self.resultTableWidth, 0)
        }), completion: nil)
    }
    
    func searchBarTableShowAnimation() {
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: ({
            self.tblSearchResults.frame = CGRectMake(0, 0, self.resultTableWidth, 300*screenWidthFactor)
            self.uiviewTableSubview.frame = CGRectMake(8, 76, self.resultTableWidth, 300*screenWidthFactor)
        }), completion: nil)
    }
    
    // MARK: TableView Initialize
    
    func loadTableView() {
        uiviewTableSubview = UIView(frame: CGRectMake(8, 76, resultTableWidth, 0))
        tblSearchResults = UITableView(frame: self.uiviewTableSubview.bounds)
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self
        tblSearchResults.registerClass(CustomCellForMainScreenSearch.self, forCellReuseIdentifier: "customCellForMainScreenSearch")
        tblSearchResults.scrollEnabled = false
        tblSearchResults.layer.masksToBounds = true
        tblSearchResults.separatorInset = UIEdgeInsetsZero
        tblSearchResults.layoutMargins = UIEdgeInsetsZero
        uiviewTableSubview.layer.borderColor = UIColor.whiteColor().CGColor
        uiviewTableSubview.layer.borderWidth = 1.0
        uiviewTableSubview.layer.cornerRadius = 2.0
        uiviewTableSubview.layer.shadowOpacity = 0.5
        uiviewTableSubview.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        uiviewTableSubview.layer.shadowRadius = 2.5
        uiviewTableSubview.layer.shadowColor = UIColor.blackColor().CGColor
        uiviewTableSubview.addSubview(tblSearchResults)
        self.view.addSubview(uiviewTableSubview)
    }
    
    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.tblSearchResults) {
            return placeholder.count
        }
        else {
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tblSearchResults {
            let cell = tableView.dequeueReusableCellWithIdentifier("customCellForMainScreenSearch", forIndexPath: indexPath) as! CustomCellForMainScreenSearch
            cell.labelTitle.text = placeholder[indexPath.row].attributedPrimaryText.string
            if let secondaryText = placeholder[indexPath.row].attributedSecondaryText {
                cell.labelSubTitle.text = secondaryText.string
            }
            cell.separatorInset = UIEdgeInsetsZero
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(tableView == self.tblSearchResults) {
            let placesClient = GMSPlacesClient()
            placesClient.lookUpPlaceID(placeholder[indexPath.row].placeID!, callback: {
                (place, error) -> Void in
                // Get place.coordinate
                GMSGeocoder().reverseGeocodeCoordinate(place!.coordinate, completionHandler: {
                    (response, error) -> Void in
                    if let selectedAddress = place?.coordinate {
                        self.delegate?.animateToCameraFromMainScreenSearch(selectedAddress)
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }
                })
            })
            self.customSearchController.customSearchBar.text = self.placeholder[indexPath.row].attributedFullText.string
            self.customSearchController.customSearchBar.resignFirstResponder()
            self.searchBarTableHideAnimation()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(tableView == self.tblSearchResults) {
            return 60 * screenWidthFactor
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}