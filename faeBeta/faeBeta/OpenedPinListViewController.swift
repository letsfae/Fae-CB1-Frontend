//
//  OpenedPinListViewController.swift
//  faeBeta
//
//  Created by Yue on 11/1/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
import SDWebImage

protocol OpenedPinListViewControllerDelegate {
    // Cancel marker's shadow when back to Fae Map
    func backFromOpenedPinList(_ back: Bool)
    // Pass location to fae map view via CommentPinDetailViewController
    func animateToCameraFromOpenedPinListView(_ coordinate: CLLocationCoordinate2D, pinID: Int)
}

class OpenedPinListViewController: UIViewController {
    
    var delegate: OpenedPinListViewControllerDelegate?

    var buttonBackToCommentPinDetail: UIButton!
    var buttonSubviewBackToMap: UIButton!
    var buttonCommentPinListClear: UIButton!
    var buttonCommentPinListDragToLargeSize: UIButton!
    var commentListExpand = false
    var commentListShowed = false
    var labelCommentPinListTitle: UILabel!
    var openedPinListArray = [Int]()
    var subviewTable: UIView!
    var subviewWhite: UIView!
    var tableOpenedPin: UITableView!
    var uiviewCommentPinListUnderLine01: UIView!
    var uiviewCommentPinListUnderLine02: UIView!
    var draggingButtonSubview: UIView!
    
    // For Dragging
    var commentPinSizeFrom: CGFloat = 0
    var commentPinSizeTo: CGFloat = 0
    
    // Control the back to comment pin detail button, prevent the more than once action
    var backJustOnce = true
    
    // Local Storage for storing opened pin id, for opened pin list use
    let storageForOpenedPinList = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let listArray = readByKey("openedPinList") {
            self.openedPinListArray = listArray as! [Int]
        }
        buttonSubviewBackToMap = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.view.addSubview(buttonSubviewBackToMap)
        self.view.sendSubview(toBack: buttonSubviewBackToMap)
        buttonSubviewBackToMap.addTarget(self, action: #selector(OpenedPinListViewController.actionBackToMap(_:)), for: UIControlEvents.touchUpInside)
        loadCommentPinList()
        backJustOnce = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // To get opened pin list, but it is a general func
    func readByKey(_ key: String) -> AnyObject? {
        if let obj = self.storageForOpenedPinList.object(forKey: key) {
            return obj as AnyObject?
        }
        return nil
    }
    
    // Load comment pin list
    func loadCommentPinList() {
        var tableHeight: CGFloat = CGFloat(openedPinListArray.count * 76)
        var subviewTableHeight = tableHeight + 28
        if openedPinListArray.count <= 3 {
            subviewTableHeight = CGFloat(256)
        }
        else {
            tableHeight = CGFloat(228)
        }
        subviewTableHeight = CGFloat(256)
        
        subviewWhite = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65))
        subviewWhite.backgroundColor = UIColor.white
        self.view.addSubview(subviewWhite)
        subviewWhite.layer.zPosition = 2
        
        subviewTable = UIView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: subviewTableHeight))
        subviewTable.backgroundColor = UIColor.white
        self.view.addSubview(subviewTable)
        subviewTable.layer.zPosition = 1
        subviewTable.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).cgColor
        subviewTable.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        subviewTable.layer.shadowOpacity = 0.3
        subviewTable.layer.shadowRadius = 10.0
        
        tableOpenedPin = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: tableHeight))
        tableOpenedPin.register(OPLTableViewCell.self, forCellReuseIdentifier: "openedPinCell")
        tableOpenedPin.delegate = self
        tableOpenedPin.dataSource = self
        subviewTable.addSubview(tableOpenedPin)
        tableOpenedPin.isScrollEnabled = false
        
        print("DEBUG: opened pin list height")
        print(tableHeight)
        print(subviewTableHeight)
        
        if tableHeight >= subviewTableHeight {
            
        }
        
        // Line at y = 64
        uiviewCommentPinListUnderLine01 = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        uiviewCommentPinListUnderLine01.layer.borderWidth = screenWidth
        uiviewCommentPinListUnderLine01.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        subviewWhite.addSubview(uiviewCommentPinListUnderLine01)
        
        // Button: Back to Comment Detail
        buttonBackToCommentPinDetail = UIButton()
        buttonBackToCommentPinDetail.setImage(UIImage(named: "commentPinBackToCommentDetail"), for: UIControlState())
        buttonBackToCommentPinDetail.addTarget(self, action: #selector(OpenedPinListViewController.actionBackToMap(_:)), for: .touchUpInside)
        subviewWhite.addSubview(buttonBackToCommentPinDetail)
        subviewWhite.addConstraintsWithFormat("H:|-(-21)-[v0(101)]", options: [], views: buttonBackToCommentPinDetail)
        subviewWhite.addConstraintsWithFormat("V:|-26-[v0(29)]", options: [], views: buttonBackToCommentPinDetail)
        
        // Button: Clear Comment Pin List
        buttonCommentPinListClear = UIButton()
        buttonCommentPinListClear.setImage(UIImage(named: "commentPinListClear"), for: UIControlState())
        buttonCommentPinListClear.addTarget(self, action: #selector(OpenedPinListViewController.actionClearCommentPinList(_:)), for: .touchUpInside)
        subviewWhite.addSubview(buttonCommentPinListClear)
        subviewWhite.addConstraintsWithFormat("H:[v0(42)]-15-|", options: [], views: buttonCommentPinListClear)
        subviewWhite.addConstraintsWithFormat("V:|-30-[v0(25)]", options: [], views: buttonCommentPinListClear)
        
        draggingButtonSubview = UIView(frame: CGRect(x: 0, y: 228, width: screenWidth, height: 28))
        draggingButtonSubview.backgroundColor = UIColor.white
        self.subviewTable.addSubview(draggingButtonSubview)
        draggingButtonSubview.layer.zPosition = 109
        
        // Line at y = 227
        uiviewCommentPinListUnderLine02 = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        uiviewCommentPinListUnderLine02.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
        draggingButtonSubview.addSubview(uiviewCommentPinListUnderLine02)
        
        // Button: Drag to larger
        buttonCommentPinListDragToLargeSize = UIButton(frame: CGRect(x: 0, y: 1, width: screenWidth, height: 27))
        buttonCommentPinListDragToLargeSize.setImage(UIImage(named: "commentPinDetailDragToLarge"), for: UIControlState())
        buttonCommentPinListDragToLargeSize.addTarget(self, action: #selector(OpenedPinListViewController.actionDraggingThisList(_:)), for: .touchUpInside)
        draggingButtonSubview.addSubview(buttonCommentPinListDragToLargeSize)
//        let panCommentPinListDrag = UIPanGestureRecognizer(target: self, action: #selector(OpenedPinListViewController.panActionCommentPinListDrag(_:)))
//        buttonCommentPinListDragToLargeSize.addGestureRecognizer(panCommentPinListDrag)
        
        // Label of Title
        labelCommentPinListTitle = UILabel()
        labelCommentPinListTitle.text = "Opened Pins"
        labelCommentPinListTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelCommentPinListTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelCommentPinListTitle.textAlignment = .center
        subviewWhite.addSubview(labelCommentPinListTitle)
        subviewWhite.addConstraintsWithFormat("H:[v0(120)]", options: [], views: labelCommentPinListTitle)
        subviewWhite.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelCommentPinListTitle)
        NSLayoutConstraint(item: labelCommentPinListTitle, attribute: .centerX, relatedBy: .equal, toItem: self.subviewWhite, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
    }
    
    func cropToBounds(_ image: UIImage) -> UIImage {
        
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(contextSize.width)
        var cgheight: CGFloat = CGFloat(contextSize.height)
        
        print("DEBUG: cgwidth cgheight")
        print(cgwidth)
        print(cgheight)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
}
