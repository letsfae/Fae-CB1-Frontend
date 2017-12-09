//
//  ExploreViewController.swift
//  faeBeta
//
//  Created by Yue Shen on 9/12/17.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

protocol ExploreDelegate: class {
    func jumpToExpPlacesCollection(places: [PlacePin], category: String)
}

class ExploreViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AddPinToCollectionDelegate, AfterAddedToListDelegate, BoardsSearchDelegate, ExploreCategorySearch, EXPCellDelegate {
    
    weak var delegate: ExploreDelegate?
    
    var uiviewNavBar: FaeNavBar!
    var clctViewTypes: UICollectionView!
    var clctViewPics: UICollectionView!
    var lblBottomLocation: UILabel!
    var btnGoLeft: UIButton!
    var btnGoRight: UIButton!
    var btnSave: UIButton!
    var btnRefresh: UIButton!
    var btnMap: UIButton!
    var imgSaved: UIImageView!
    
    var intCurtPage = 0
    
    var testTypes: [String] = ["Random", "Airport", "Antique Shop", "Arcade", "Art Gallery", "Arts & Crafts Store", "Athletics & Sports", "BBQ Joint", "Bagel Shop", "Bakery", "Bars", "Baseball Stadium", "Beach", "Beer Store", "Brewery", "Buffet", "Building", "Burger Joint", "Burrito Place", "Business Service", "Canal", "Candy Store", "Coffee Shop", "College Bookstore", "College Classroom", "Concert Hall", "Construction & Landscaping", "Convenience Store", "Cosmetics Shop", "Deli / Bodega", "Dessert Shop", "Diner", "Donut Shop", "Farmers Market", "Food Court", "Food Truck", "Fried Chicken Joint", "Frozen Yogurt Shop", "Furniture / Home Store", "Garden", "Gift Shop", "Gourmet Shop", "Grocery Store", "Health & Beauty Service", "Hot Dog Joint", "Ice Cream Shop", "Juice Bar", "Lake", "Library", "Light Rail Station", "Liquor Store", "Market", "Massage Studio", "Metro Station", "Moving Target", "Museum", "Music Store", "Music Venue", "Noodle House", "Organic Grocery", "Outdoor Sculpture", "Paper / Office Supplies Store", "Performing Arts Venue", "Pet Store", "Pharmacy", "Photography Studio", "Pizza Place", "Playground", "Plaza", "Rental Car Location", "Restaurant", "Salad Place", "Sandwich Place", "Scenic Lookout", "Shopping", "Skate Park", "Smoke Shop", "Snack Place", "Spa", "Sporting Goods Shop", "Steakhouse", "Street Food Gathering", "Supermarket", "Taco Place", "Theme Park", "Trail", "Wine Shop"]
    
    var uiviewAvatarWaveSub: UIView!
    var imgAvatar: FaeAvatarView!
    var filterCircle_1: UIImageView!
    var filterCircle_2: UIImageView!
    var filterCircle_3: UIImageView!
    var filterCircle_4: UIImageView!
    
    // Collecting Pin Control
    var uiviewSavedList: AddPinToCollectionView!
    var uiviewAfterAdded: AfterAddedToListView!
    var arrListSavedThisPin = [Int]()
    
    var arrPlaceData = [PlacePin]()
    
    var fullyLoaded = false
    
    var coordinate: CLLocationCoordinate2D!
    
    var selectedTypeIdx: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
        loadAvatarWave()
        DispatchQueue.main.async {
            self.loadContent()
            self.coordinate = LocManager.shared.curtLoc.coordinate
            self.loadPlaces(center: LocManager.shared.curtLoc.coordinate)
            self.fullyLoaded = true
            General.shared.getAddress(location: LocManager.shared.curtLoc, original: false, full: false, detach: true) { (address) in
                if let addr = address as? String {
                    let new = addr.split(separator: "@")
                    self.reloadBottomText(String(new[0]), String(new[1]))
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(showSavedNoti), name: NSNotification.Name(rawValue: "showSavedNoti_explore"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideSavedNoti), name: NSNotification.Name(rawValue: "hideSavedNoti_explore"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWaves()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "showSavedNoti_explore"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSavedNoti), name: NSNotification.Name(rawValue: "hideSavedNoti_explore"), object: nil)
    }
    
    func loadContent() {
        loadTopTypesCollection()
        loadPicCollections()
        loadButtons()
        loadBottomLocation()
        loadPlaceListView()
    }
    
    func buttonEnable(on: Bool) {
        btnGoLeft.isEnabled = on
        btnSave.isEnabled = on
        btnRefresh.isEnabled = on
        btnMap.isEnabled = on
        btnGoRight.isEnabled = on
        lblBottomLocation.isUserInteractionEnabled = on
        clctViewTypes.isUserInteractionEnabled = on
    }
    
    func loadPlaces(center: CLLocationCoordinate2D) {
        
        func getRandomIndex(_ arrRaw: [PlacePin]) -> [PlacePin] {
            var tempRaw = arrRaw
            var arrResult = [PlacePin]()
            let count = arrRaw.count < 20 ? arrRaw.count : 20
            for _ in 0..<count {
                let random: Int = Int(arc4random_uniform(UInt32(tempRaw.count)))
                arrResult.append(tempRaw[random])
                tempRaw.remove(at: random)
            }
            return arrResult
        }
        buttonEnable(on: false)
        // use uiview.tag as a Bool like value to indicate whether we should
        // animate the alpha value between clctView and Wave sub view
        if uiviewAvatarWaveSub.tag != 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.clctViewPics.alpha = 0
                self.uiviewAvatarWaveSub.alpha = 1
            })
        }
        uiviewAvatarWaveSub.tag = 1
        clctViewPics.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            General.shared.getPlacePins(coordinate: center, radius: 0, count: 200, completion: { (status, placesJSON) in
                guard status / 100 == 2 else { return }
                guard let mapPlaceJsonArray = placesJSON.array else { return }
                guard mapPlaceJsonArray.count > 0 else { return }
                let arrRaw = mapPlaceJsonArray.map { PlacePin(json: $0) }
                self.arrPlaceData = getRandomIndex(arrRaw)
                self.clctViewPics.reloadData()
                self.buttonEnable(on: true)
                UIView.animate(withDuration: 0.3, animations: {
                    self.clctViewPics.alpha = 1
                    self.uiviewAvatarWaveSub.alpha = 0
                })
                self.checkSavedStatus(id: 0)
            })
        }
    }
    
    // AfterAddedToListDelegate
    func seeList() {
        // TODO VICKY
        uiviewAfterAdded.hide()
        let vcList = CollectionsListDetailViewController()
        vcList.enterMode = uiviewSavedList.tableMode
        vcList.colId = uiviewAfterAdded.selectedCollection.collection_id
//        vcList.colInfo = uiviewAfterAdded.selectedCollection
//        vcList.arrColDetails = uiviewAfterAdded.selectedCollection
        navigationController?.pushViewController(vcList, animated: true)
    }
    // AfterAddedToListDelegate
    func undoCollect(colId: Int, mode: UndoMode) {
        uiviewAfterAdded.hide()
        uiviewSavedList.show()
        switch mode {
        case .save:
            uiviewSavedList.arrListSavedThisPin.append(colId)
            break
        case .unsave:
            if uiviewSavedList.arrListSavedThisPin.contains(colId) {
                let arrListIds = uiviewSavedList.arrListSavedThisPin
                uiviewSavedList.arrListSavedThisPin = arrListIds.filter { $0 != colId }
            }
            break
        }
        if uiviewSavedList.arrListSavedThisPin.count <= 0 {
            hideSavedNoti()
        } else if uiviewSavedList.arrListSavedThisPin.count == 1 {
            showSavedNoti()
        }
    }
    // AddPlacetoCollectionDelegate
    func createColList() {
        let vc = CreateColListViewController()
        vc.enterMode = .place
        present(vc, animated: true)
    }
    
    func loadPlaceListView() {
        uiviewSavedList = AddPinToCollectionView()
        uiviewSavedList.delegate = self
//        uiviewSavedList.loadCollectionData()
        view.addSubview(uiviewSavedList)
        
        uiviewAfterAdded = AfterAddedToListView()
        uiviewAfterAdded.delegate = self
        view.addSubview(uiviewAfterAdded)
        
        uiviewSavedList.uiviewAfterAdded = uiviewAfterAdded
    }
    
    func loadAvatarWave() {
        let xAxis: CGFloat = screenWidth / 2
        var yAxis: CGFloat = 324.5 * screenHeightFactor
        yAxis += screenHeight == 812 ? 80 : 0
        
        uiviewAvatarWaveSub = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth))
        uiviewAvatarWaveSub.center = CGPoint(x: xAxis, y: yAxis)
        view.addSubview(uiviewAvatarWaveSub)
        
        let imgAvatarSub = UIImageView(frame: CGRect(x: 0, y: 0, width: 98, height: 98))
        imgAvatarSub.contentMode = .scaleAspectFill
        imgAvatarSub.image = #imageLiteral(resourceName: "exp_avatar_border")
        imgAvatarSub.center = CGPoint(x: xAxis, y: xAxis)
        uiviewAvatarWaveSub.addSubview(imgAvatarSub)
        
        imgAvatar = FaeAvatarView(frame: CGRect(x: 0, y: 0, width: 86, height: 86))
        imgAvatar.layer.cornerRadius = 43
        imgAvatar.contentMode = .scaleAspectFill
        imgAvatar.center = CGPoint(x: xAxis, y: xAxis)
        imgAvatar.isUserInteractionEnabled = false
        imgAvatar.clipsToBounds = true
        uiviewAvatarWaveSub.addSubview(imgAvatar)
        imgAvatar.userID = Key.shared.user_id
        imgAvatar.loadAvatar(id: Key.shared.user_id)
    }
    
    func loadWaves() {
        func createFilterCircle() -> UIImageView {
            let xAxis: CGFloat = screenWidth / 2
            let imgView = UIImageView(frame: CGRect.zero)
            imgView.frame.size = CGSize(width: 98, height: 98)
            imgView.center = CGPoint(x: xAxis, y: xAxis)
            imgView.image = #imageLiteral(resourceName: "exp_wave")
            imgView.tag = 0
            return imgView
        }
        if filterCircle_1 != nil {
            filterCircle_1.removeFromSuperview()
            filterCircle_2.removeFromSuperview()
            filterCircle_3.removeFromSuperview()
            filterCircle_4.removeFromSuperview()
        }
        filterCircle_1 = createFilterCircle()
        filterCircle_2 = createFilterCircle()
        filterCircle_3 = createFilterCircle()
        filterCircle_4 = createFilterCircle()
        uiviewAvatarWaveSub.addSubview(filterCircle_1)
        uiviewAvatarWaveSub.addSubview(filterCircle_2)
        uiviewAvatarWaveSub.addSubview(filterCircle_3)
        uiviewAvatarWaveSub.addSubview(filterCircle_4)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_1)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_2)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_3)
        uiviewAvatarWaveSub.sendSubview(toBack: filterCircle_4)
        
        animation(circle: filterCircle_1, delay: 0)
        animation(circle: filterCircle_2, delay: 0.5)
        animation(circle: filterCircle_3, delay: 2)
        animation(circle: filterCircle_4, delay: 2.5)
    }
    
    func animation(circle: UIImageView, delay: Double) {
        let animateTime: Double = 3
        let radius: CGFloat = screenWidth
        let newFrame = CGRect(x: 0, y: 0, width: radius, height: radius)
        
        let xAxis: CGFloat = screenWidth / 2
        circle.frame.size = CGSize(width: 98, height: 98)
        circle.center = CGPoint(x: xAxis, y: xAxis)
        circle.alpha = 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIView.animate(withDuration: animateTime, delay: 0, options: [.curveEaseOut], animations: ({
                circle.alpha = 0.0
                circle.frame = newFrame
            }), completion: { _ in
                self.animation(circle: circle, delay: 0.75)
            })
        }
    }
    
    @objc func actionExpMap() {
        delegate?.jumpToExpPlacesCollection(places: arrPlaceData, category: "Random")
        var arrCtrlers = navigationController?.viewControllers
        if let ctrler = Key.shared.FMVCtrler {
            ctrler.arrCtrlers = arrCtrlers!
        }
        while !(arrCtrlers?.last is InitialPageController) {
            arrCtrlers?.removeLast()
        }
        Key.shared.initialCtrler?.goToFaeMap(animated: false)
        navigationController?.setViewControllers(arrCtrlers!, animated: false)
    }
    
    @objc func actionSave(_ sender: UIButton) {
        uiviewSavedList.show()
//        uiviewSavedList.loadCollectionData()
    }
    
    @objc func showSavedNoti() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgSaved.frame = CGRect(x: 41, y: 7, width: 18, height: 18)
            self.imgSaved.alpha = 1
        }, completion: nil)
    }
    
    @objc func hideSavedNoti() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.imgSaved.frame = CGRect(x: 50, y: 16, width: 0, height: 0)
            self.imgSaved.alpha = 0
        }, completion: nil)
    }
    
    @objc func actionSwitchPage(_ sender: UIButton) {
        var numPage = intCurtPage
        if sender == btnGoLeft {
            numPage -= 1
        } else {
            numPage += 1
        }
        if numPage < 0 {
            numPage = 19
        } else if numPage >= 20 {
            numPage = 0
        }
        clctViewPics.setContentOffset(CGPoint(x: screenWidth * CGFloat(numPage), y: 0), animated: true)
        intCurtPage = numPage
        checkSavedStatus(id: intCurtPage)
    }
    
    @objc func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = clctViewPics.frame.size.width
        intCurtPage = Int(clctViewPics.contentOffset.x / pageWidth)
        checkSavedStatus(id: intCurtPage)
    }
    
    func checkSavedStatus(id: Int) {
        guard id < arrPlaceData.count else {
            // 判断:
            return
        }
        let placePin = arrPlaceData[id]
        uiviewSavedList.pinToSave = FaePinAnnotation(type: "place", cluster: nil, data: placePin as AnyObject)
        getPinSavedInfo(id: placePin.id, type: "place") { (ids) in
            self.arrListSavedThisPin = ids
            self.uiviewSavedList.arrListSavedThisPin = ids
            if ids.count > 0 {
                self.showSavedNoti()
            } else {
                self.hideSavedNoti()
            }
        }
    }
    
    func getPinSavedInfo(id: Int, type: String, _ completion: @escaping ([Int]) -> Void) {
        FaeMap.shared.getPin(type: type, pinId: String(id)) { (status, message) in
            guard status / 100 == 2 else { return }
            guard message != nil else { return }
            let resultJson = JSON(message!)
            var ids = [Int]()
            guard let is_saved = resultJson["user_pin_operations"]["is_saved"].string else {
                completion(ids)
                return
            }
            guard is_saved != "false" else { return }
            for colIdRaw in is_saved.split(separator: ",") {
                let strColId = String(colIdRaw)
                guard let colId = Int(strColId) else { continue }
                ids.append(colId)
            }
            completion(ids)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == clctViewTypes {
            let label = UILabel()
            label.font = FaeFont(fontType: .medium, size: 15)
            label.text = testTypes[indexPath.row]
            let width = label.intrinsicContentSize.width
            return CGSize(width: width + 3.0, height: 36)
        }
        return CGSize(width: screenWidth, height: screenHeight - 116 - 156 - device_offset_top - device_offset_bot)
    }
    
    func loadTopTypesCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 20
        layout.estimatedItemSize = CGSize(width: 80, height: 36)
        
        clctViewTypes = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        clctViewTypes.register(EXPClctTypeCell.self, forCellWithReuseIdentifier: "exp_types")
        clctViewTypes.delegate = self
        clctViewTypes.dataSource = self
        clctViewTypes.isPagingEnabled = false
        clctViewTypes.backgroundColor = UIColor.clear
        clctViewTypes.showsHorizontalScrollIndicator = false
        clctViewTypes.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.addSubview(clctViewTypes)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: clctViewTypes)
        view.addConstraintsWithFormat("V:|-\(73+device_offset_top)-[v0(36)]", options: [], views: clctViewTypes)
    }
    
    func loadPicCollections() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth, height: screenHeight - 116 - 156)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        clctViewPics = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        clctViewPics.register(EXPClctPicCell.self, forCellWithReuseIdentifier: "exp_pics")
        clctViewPics.delegate = self
        clctViewPics.dataSource = self
        clctViewPics.isPagingEnabled = true
        clctViewPics.backgroundColor = UIColor.clear
        clctViewPics.showsHorizontalScrollIndicator = false
        clctViewPics.alpha = 0
        view.addSubview(clctViewPics)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: clctViewPics)
        view.addConstraintsWithFormat("V:|-\(116+device_offset_top)-[v0]-\(156+device_offset_bot)-|", options: [], views: clctViewPics)
    }
    
    func loadButtons() {
        let uiviewBtnSub = UIView(frame: CGRect(x: (screenWidth - 370) / 2, y: screenHeight - 138 - device_offset_bot, width: 370, height: 78))
        view.addSubview(uiviewBtnSub)
        
        btnGoLeft = UIButton()
        btnGoLeft.setImage(#imageLiteral(resourceName: "exp_go_left"), for: .normal)
        btnGoLeft.addTarget(self, action: #selector(actionSwitchPage(_:)), for: .touchUpInside)
        uiviewBtnSub.addSubview(btnGoLeft)
        uiviewBtnSub.addConstraintsWithFormat("H:|-0-[v0(78)]", options: [], views: btnGoLeft)
        uiviewBtnSub.addConstraintsWithFormat("V:|-0-[v0(78)]", options: [], views: btnGoLeft)
        
        btnSave = UIButton()
        btnSave.setImage(#imageLiteral(resourceName: "exp_save"), for: .normal)
        btnSave.addTarget(self, action: #selector(actionSave(_:)), for: .touchUpInside)
        uiviewBtnSub.addSubview(btnSave)
        uiviewBtnSub.addConstraintsWithFormat("H:|-82-[v0(66)]", options: [], views: btnSave)
        uiviewBtnSub.addConstraintsWithFormat("V:|-6-[v0(66)]", options: [], views: btnSave)
        imgSaved = UIImageView(frame: CGRect(x: 50, y: 16, width: 0, height: 0))
        imgSaved.image = #imageLiteral(resourceName: "place_new_collected")
        imgSaved.alpha = 0
        btnSave.addSubview(imgSaved)
        
        btnRefresh = UIButton()
        btnRefresh.setImage(#imageLiteral(resourceName: "exp_refresh"), for: .normal)
        btnRefresh.addTarget(self, action: #selector(actionRefresh), for: .touchUpInside)
        uiviewBtnSub.addSubview(btnRefresh)
        uiviewBtnSub.addConstraintsWithFormat("H:|-152-[v0(66)]", options: [], views: btnRefresh)
        uiviewBtnSub.addConstraintsWithFormat("V:|-6-[v0(66)]", options: [], views: btnRefresh)
        
        btnMap = UIButton()
        btnMap.setImage(#imageLiteral(resourceName: "exp_map"), for: .normal)
        btnMap.addTarget(self, action: #selector(actionExpMap), for: .touchUpInside)
        uiviewBtnSub.addSubview(btnMap)
        uiviewBtnSub.addConstraintsWithFormat("H:[v0(66)]-82-|", options: [], views: btnMap)
        uiviewBtnSub.addConstraintsWithFormat("V:|-6-[v0(66)]", options: [], views: btnMap)
        
        btnGoRight = UIButton()
        btnGoRight.setImage(#imageLiteral(resourceName: "exp_go_right"), for: .normal)
        btnGoRight.addTarget(self, action: #selector(actionSwitchPage(_:)), for: .touchUpInside)
        uiviewBtnSub.addSubview(btnGoRight)
        uiviewBtnSub.addConstraintsWithFormat("H:[v0(78)]-0-|", options: [], views: btnGoRight)
        uiviewBtnSub.addConstraintsWithFormat("V:|-0-[v0(78)]", options: [], views: btnGoRight)
    }
    
    @objc func actionRefresh() {
        guard coordinate != nil else { return }
        loadPlaces(center: coordinate!)
    }
    
    func loadBottomLocation() {
        lblBottomLocation = UILabel()
        lblBottomLocation.numberOfLines = 1
        lblBottomLocation.textAlignment = .center
        lblBottomLocation.isUserInteractionEnabled = true
        view.addSubview(lblBottomLocation)
        view.addConstraintsWithFormat("H:|-0-[v0]-0-|", options: [], views: lblBottomLocation)
        view.addConstraintsWithFormat("V:[v0(25)]-\(19+device_offset_bot)-|", options: [], views: lblBottomLocation)
        lblBottomLocation.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        lblBottomLocation.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ tap: UITapGestureRecognizer) {
        let vc = SelectLocationViewController()
        vc.delegate = self
        vc.mode = .part
        navigationController?.pushViewController(vc, animated: false)
    }
    
    // BoardsSearchDelegate
    func sendLocationBack(address: RouteAddress) {
        var arrNames = address.name.split(separator: ",")
        var array = [String]()
        guard arrNames.count >= 1 else { return }
        for i in 0..<arrNames.count {
            let name = String(arrNames[i]).trimmingCharacters(in: CharacterSet.whitespaces)
            array.append(name)
        }
        if array.count >= 3 {
            reloadBottomText(array[0], array[1] + ", " + array[2])
        } else if array.count == 1 {
            reloadBottomText(array[0], "")
        } else if array.count == 2 {
            reloadBottomText(array[0], array[1])
        }
        self.coordinate = address.coordinate
        if selectedTypeIdx != nil {
            search(category: lastCategory, indexPath: selectedTypeIdx)
        }
    }
    
    func reloadBottomText(_ city: String, _ state: String) {
        let fullAttrStr = NSMutableAttributedString()
        let firstImg = #imageLiteral(resourceName: "mapSearchCurrentLocation")
        let first_attch = InlineTextAttachment()
        first_attch.fontDescender = -2
        first_attch.image = UIImage(cgImage: (firstImg.cgImage)!, scale: 3, orientation: .up)
        let firstImg_attach = NSAttributedString(attachment: first_attch)
        
        let secondImg = #imageLiteral(resourceName: "exp_bottom_loc_arrow")
        let second_attch = InlineTextAttachment()
        second_attch.fontDescender = -1
        second_attch.image = UIImage(cgImage: (secondImg.cgImage)!, scale: 3, orientation: .up)
        let secondImg_attach = NSAttributedString(attachment: second_attch)
        let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!]
//        let attrs_0 = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 16)!, NSAttributedStringKey.foregroundColor: UIColor._898989()]
        let title_0_attr = NSMutableAttributedString(string: "  " + city + " ", attributes: attrs_0)
        
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._138138138(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!]
//        let attrs_1 = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 13)!, NSAttributedStringKey.foregroundColor: UIColor._138138138()]
        let title_1_attr = NSMutableAttributedString(string: state + "  ", attributes: attrs_1)
        
        fullAttrStr.append(firstImg_attach)
        fullAttrStr.append(title_0_attr)
        fullAttrStr.append(title_1_attr)
        fullAttrStr.append(secondImg_attach)
        DispatchQueue.main.async {
            self.lblBottomLocation.attributedText = fullAttrStr
            self.lblBottomLocation.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clctViewPics {
            return arrPlaceData.count
        } else if collectionView == clctViewTypes {
            return testTypes.count
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == clctViewPics {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exp_pics", for: indexPath) as! EXPClctPicCell
            cell.delegate = self
            cell.updateCell(placeData: arrPlaceData[indexPath.row])
            return cell
        } else if collectionView == clctViewTypes {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exp_types", for: indexPath) as! EXPClctTypeCell
            cell.updateTitle(type: testTypes[indexPath.row])
            cell.delegate = self
            cell.indexPath = indexPath
            if selectedTypeIdx != nil {
                cell.setButtonColor(selected: indexPath == selectedTypeIdx)
            }
            return cell
        } else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = arrPlaceData[indexPath.row]
        vcPlaceDetail.featureDelegate = Key.shared.FMVCtrler
        vcPlaceDetail.delegate = Key.shared.FMVCtrler
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
    
    // EXPCellDelegate
    func jumpToPlaceDetail(_ placeInfo: PlacePin) {
        let vcPlaceDetail = PlaceDetailViewController()
        vcPlaceDetail.place = placeInfo
        vcPlaceDetail.featureDelegate = Key.shared.FMVCtrler
        vcPlaceDetail.delegate = Key.shared.FMVCtrler
        navigationController?.pushViewController(vcPlaceDetail, animated: true)
    }
    
    var lastCategory = ""
    
    // MARK: - ExploreCategorySearch
    func search(category: String, indexPath: IndexPath) {
        
        if selectedTypeIdx != nil {
            if let cell = clctViewTypes.cellForItem(at: selectedTypeIdx) as? EXPClctTypeCell {
                cell.setButtonColor(selected: false)
            }
        }
        if let cell = clctViewTypes.cellForItem(at: indexPath) as? EXPClctTypeCell {
            cell.setButtonColor(selected: true)
        }
        selectedTypeIdx = indexPath
        lastCategory = category
        
        if lastCategory == "Random" {
            loadPlaces(center: coordinate)
            return
        }
        
        func getRandomIndex(_ arrRaw: [PlacePin]) -> [PlacePin] {
            var tempRaw = arrRaw
            var arrResult = [PlacePin]()
            let count = arrRaw.count < 20 ? arrRaw.count : 20
            for _ in 0..<count {
                let random: Int = Int(arc4random_uniform(UInt32(tempRaw.count)))
                arrResult.append(tempRaw[random])
                tempRaw.remove(at: random)
            }
            return arrResult
        }
        buttonEnable(on: false)
        // use uiview.tag as a Bool like value to indicate whether we should
        // animate the alpha value between clctView and Wave sub view
        if uiviewAvatarWaveSub.tag != 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.clctViewPics.alpha = 0
                self.uiviewAvatarWaveSub.alpha = 1
            })
        }
        uiviewAvatarWaveSub.tag = 1
        clctViewPics.reloadData()
        
        FaeSearch.shared.whereKey("content", value: category)
        FaeSearch.shared.whereKey("source", value: "categories")
        FaeSearch.shared.whereKey("type", value: "place")
        FaeSearch.shared.whereKey("size", value: "200")
        FaeSearch.shared.whereKey("radius", value: "99999999")
        FaeSearch.shared.whereKey("offset", value: "0")
//        FaeSearch.shared.whereKey("location", value: "{latitude:\(self.coordinate.latitude), longitude:\(self.coordinate.longitude)}")
        FaeSearch.shared.search { (status: Int, message: Any?) in
            if status / 100 != 2 || message == nil {
                print("[loadMapSearchPlaceInfo] status/100 != 2")
                return
            }
            let placeInfoJSON = JSON(message!)
            guard let placeInfoJsonArray = placeInfoJSON.array else {
                print("[loadMapSearchPlaceInfo] fail to parse map search place info")
                return
            }
            let arrRaw = placeInfoJsonArray.map { PlacePin(json: $0) }
            self.arrPlaceData = getRandomIndex(arrRaw)
            self.clctViewPics.reloadData()
            self.buttonEnable(on: true)
            UIView.animate(withDuration: 0.3, animations: {
                self.clctViewPics.alpha = 1
                self.uiviewAvatarWaveSub.alpha = 0
            })
            self.checkSavedStatus(id: 0)
        }
    }
    
    func loadNavBar() {
        uiviewNavBar = FaeNavBar()
        view.addSubview(uiviewNavBar)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.loadBtnConstraints()
        
        let title_0 = "Explore "
        let title_1 = "Around Me"
        let attrs_0 = [NSAttributedStringKey.foregroundColor: UIColor._898989(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 20)!]
        let attrs_1 = [NSAttributedStringKey.foregroundColor: UIColor._2499090(), NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 20)!]
        let title_0_attr = NSMutableAttributedString(string: title_0, attributes: attrs_0)
        let title_1_attr = NSMutableAttributedString(string: title_1, attributes: attrs_1)
        title_0_attr.append(title_1_attr)
        
        uiviewNavBar.lblTitle.attributedText = title_0_attr

        uiviewNavBar.leftBtn.addTarget(self, action: #selector(actionBack(_:)), for: .touchUpInside)
    }
}
