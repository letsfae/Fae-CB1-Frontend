//
//  MPDLoadItems.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

extension MomentPinDetailViewController {
    // Load pin detail window
    func loadPinDetailWindow() {
        
        loadNavigationBar()
        
        // Table comments for moment
        tableCommentsForPin = UITableView(frame: CGRect(x: 0, y: 65, width: screenWidth, height: 227))
        tableCommentsForPin.delegate = self
        tableCommentsForPin.dataSource = self
        tableCommentsForPin.allowsSelection = false
        tableCommentsForPin.delaysContentTouches = true
        tableCommentsForPin.register(PinCommentsCell.self, forCellReuseIdentifier: "commentPinCommentsCell")
        tableCommentsForPin.isScrollEnabled = true
        tableCommentsForPin.tableFooterView = UIView()
        tableCommentsForPin.layer.zPosition = 109
        self.view.addSubview(tableCommentsForPin)
        tableCommentsForPin.center.y -= screenHeight
        
        // Dragging button
        draggingButtonSubview = UIView(frame: CGRect(x: 0, y: 292, width: screenWidth, height: 28))
        draggingButtonSubview.backgroundColor = UIColor.white
        self.view.addSubview(draggingButtonSubview)
        draggingButtonSubview.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).cgColor
        draggingButtonSubview.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        draggingButtonSubview.layer.shadowOpacity = 0.3
        draggingButtonSubview.layer.shadowRadius = 10.0
        draggingButtonSubview.layer.zPosition = 109
        draggingButtonSubview.center.y -= screenHeight
        
        uiviewPinUnderLine02 = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 1))
        uiviewPinUnderLine02.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
        self.draggingButtonSubview.addSubview(uiviewPinUnderLine02)
        //        uiviewPinUnderLine02.layer.zPosition = 109
        
        buttonPinDetailDragToLargeSize = UIButton(frame: CGRect(x: 0, y: 1, width: screenWidth, height: 27))
        buttonPinDetailDragToLargeSize.backgroundColor = UIColor.white
        buttonPinDetailDragToLargeSize.setImage(UIImage(named: "commentPinDetailDragToLarge"), for: UIControlState())
        buttonPinDetailDragToLargeSize.addTarget(self, action: #selector(self.actionDraggingThisPin(_:)), for: .touchUpInside)
        self.draggingButtonSubview.addSubview(buttonPinDetailDragToLargeSize)
        buttonPinDetailDragToLargeSize.center.x = screenWidth/2
        //        buttonPinDetailDragToLargeSize.layer.zPosition = 109
        buttonPinDetailDragToLargeSize.tag = 0
        //        let draggingGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panActionPinDetailDrag(_:)))
        //        buttonPinDetailDragToLargeSize.addGestureRecognizer(draggingGesture)
        
        // Header
        uiviewPinDetail = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 281))
        uiviewPinDetail.backgroundColor = UIColor.white
        uiviewPinDetail.layer.zPosition = 100
        self.view.addSubview(uiviewPinDetail)
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.tapOutsideToDismissKeyboard(_:)))
        uiviewPinDetail.addGestureRecognizer(tapToDismissKeyboard)
        
        tableCommentsForPin.tableHeaderView = uiviewPinDetail
        
        // ----
        // Textview width based on different resolutions
        var textViewWidth: CGFloat = 0
        if screenWidth == 414 { // 5.5
            textViewWidth = 360
        }
        else if screenWidth == 320 { // 4.0
            textViewWidth = 266
        }
        else if screenWidth == 375 { // 4.7
            textViewWidth = 321
        }
        
        // Textview of pin detail
        textviewPinDetail = UITextView(frame: CGRect(x: 27, y: 75, width: textViewWidth, height: 100))
        textviewPinDetail.text = ""
        textviewPinDetail.font = UIFont(name: "AvenirNext-Regular", size: 18)
        textviewPinDetail.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        textviewPinDetail.isUserInteractionEnabled = true
        textviewPinDetail.isEditable = false
        textviewPinDetail.textContainerInset = UIEdgeInsets.zero
        textviewPinDetail.indicatorStyle = UIScrollViewIndicatorStyle.white
        textviewPinDetail.isHidden = true
        uiviewPinDetail.addSubview(textviewPinDetail)
        
        layout.itemSize = CGSize(width: 95, height: 95)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        
        collectionViewMedia = UICollectionView(frame: CGRect(x: 15, y: 80, width: screenWidth-15, height: 95),
                                               collectionViewLayout: layout)
        collectionViewMedia.register(MPDCollectionViewCell.self, forCellWithReuseIdentifier: "mediaCell")
        collectionViewMedia.delegate = self
        collectionViewMedia.dataSource = self
        collectionViewMedia.backgroundColor = UIColor.clear
        collectionViewMedia.showsHorizontalScrollIndicator = false
        uiviewPinDetail.addSubview(collectionViewMedia)
        
        // ----
        // Main buttons' container of pin detail
        uiviewPinDetailMainButtons = UIView(frame: CGRect(x: 0, y: 190, width: screenWidth, height: 22))
        uiviewPinDetail.addSubview(uiviewPinDetailMainButtons)
        
        // Pin Like
        buttonPinLike = UIButton()
        buttonPinLike.setImage(UIImage(named: "commentPinLikeHollow"), for: UIControlState())
        buttonPinLike.addTarget(self, action: #selector(self.actionLikeThisPin(_:)), for: [.touchUpInside, .touchUpOutside])
        buttonPinLike.addTarget(self, action: #selector(self.actionHoldingLikeButton(_:)), for: .touchDown)
        uiviewPinDetailMainButtons.addSubview(buttonPinLike)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("H:[v0(56)]-90-|", options: [], views: buttonPinLike)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonPinLike)
        buttonPinLike.tag = 0
        buttonPinLike.layer.zPosition = 109
        
        // Add Comment
        buttonPinAddComment = UIButton()
        buttonPinAddComment.setImage(UIImage(named: "commentPinAddComment"), for: UIControlState())
        buttonPinAddComment.addTarget(self, action: #selector(self.actionReplyToThisPin(_:)), for: .touchUpInside)
        buttonPinAddComment.tag = 0
        uiviewPinDetailMainButtons.addSubview(buttonPinAddComment)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("H:[v0(56)]-0-|", options: [], views: buttonPinAddComment)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: buttonPinAddComment)
        
        // Label of Like Count
        labelPinLikeCount = UILabel()
        labelPinLikeCount.text = ""
        labelPinLikeCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        labelPinLikeCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        labelPinLikeCount.textAlignment = .right
        uiviewPinDetailMainButtons.addSubview(labelPinLikeCount)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("H:[v0(41)]-141-|", options: [], views: labelPinLikeCount)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: labelPinLikeCount)
        
        // Label of Comments of Coment Pin Count
        labelPinCommentsCount = UILabel()
        labelPinCommentsCount.text = ""
        labelPinCommentsCount.font = UIFont(name: "PingFang SC-Semibold", size: 15)
        labelPinCommentsCount.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        labelPinCommentsCount.textAlignment = .right
        uiviewPinDetailMainButtons.addSubview(labelPinCommentsCount)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("H:[v0(41)]-49-|", options: [], views: labelPinCommentsCount)
        uiviewPinDetailMainButtons.addConstraintsWithFormat("V:[v0(22)]-0-|", options: [], views: labelPinCommentsCount)
        
        
        // ----
        // Gray Block
        uiviewPinDetailGrayBlock = UIView(frame: CGRect(x: 0, y: 227, width: screenWidth, height: 12))
        uiviewPinDetailGrayBlock.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        uiviewPinDetail.addSubview(uiviewPinDetailGrayBlock)
        
        
        // ----
        // View to hold three buttons
        uiviewPinDetailThreeButtons = UIView(frame: CGRect(x: 0, y: 239, width: screenWidth, height: 42))
        uiviewPinDetail.addSubview(uiviewPinDetailThreeButtons)
        
        // Three buttons bottom gray line
        uiviewGrayBaseLine = UIView()
        uiviewGrayBaseLine.layer.borderWidth = 1.0
        uiviewGrayBaseLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        uiviewPinDetailThreeButtons.addSubview(uiviewGrayBaseLine)
        uiviewPinDetailThreeButtons.addConstraintsWithFormat("H:|-0-[v0(\(screenWidth))]", options: [], views: uiviewGrayBaseLine)
        uiviewPinDetailThreeButtons.addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: uiviewGrayBaseLine)
        
        let widthOfThreeButtons = screenWidth / 2
        
        // Three buttons bottom sliding red line
        uiviewRedSlidingLine = UIView(frame: CGRect(x: 0, y: 40, width: widthOfThreeButtons, height: 2))
        uiviewRedSlidingLine.layer.borderWidth = 1.0
        uiviewRedSlidingLine.layer.borderColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0).cgColor
        uiviewPinDetailThreeButtons.addSubview(uiviewRedSlidingLine)
        
        // "Comments" of this uiview
        buttonPinDetailViewComments = UIButton()
        buttonPinDetailViewComments.setImage(UIImage(named: "commentDetailThreeButtonComments"), for: UIControlState())
        buttonPinDetailViewComments.addTarget(self, action: #selector(self.animationRedSlidingLine(_:)), for: UIControlEvents.touchUpInside)
        uiviewPinDetailThreeButtons.addSubview(buttonPinDetailViewComments)
        buttonPinDetailViewComments.tag = 1
        uiviewPinDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonPinDetailViewComments)
        
        /*
         // "Active" of this uiview
         buttonCommentDetailViewActive = UIButton()
         buttonCommentDetailViewActive.setImage(UIImage(named: "commentDetailThreeButtonActive"), forState: .Normal)
         buttonCommentDetailViewActive.addTarget(self, action: #selector(self.animationRedSlidingLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
         uiviewPinDetailThreeButtons.addSubview(buttonCommentDetailViewActive)
         buttonCommentDetailViewActive.tag = 3
         uiviewPinDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonCommentDetailViewActive)
         */
        
        // "People" of this uiview
        buttonPinDetailViewPeople = UIButton()
        //        buttonPinDetailViewPeople.setImage(UIImage(named: "commentDetailThreeButtonPeople"), forState: .Normal)
        //        buttonPinDetailViewPeople.addTarget(self, action: #selector(self.animationRedSlidingLine(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        uiviewPinDetailThreeButtons.addSubview(buttonPinDetailViewPeople)
        buttonPinDetailViewPeople.tag = 3
        uiviewPinDetailThreeButtons.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: buttonPinDetailViewPeople)
        
        uiviewPinDetailThreeButtons.addConstraintsWithFormat("H:|-0-[v0(\(widthOfThreeButtons))]-0-[v1(\(widthOfThreeButtons))]", options: [], views: buttonPinDetailViewComments, buttonPinDetailViewPeople)
        
        // Comment Pin User Avatar
        imagePinUserAvatar = UIImageView()
        imagePinUserAvatar.image = UIImage(named: "defaultMan")
        imagePinUserAvatar.layer.cornerRadius = 25
        imagePinUserAvatar.clipsToBounds = true
        imagePinUserAvatar.contentMode = .scaleAspectFill
        uiviewPinDetail.addSubview(imagePinUserAvatar)
        uiviewPinDetail.addConstraintsWithFormat("H:|-15-[v0(50)]", options: [], views: imagePinUserAvatar)
        uiviewPinDetail.addConstraintsWithFormat("V:|-15-[v0(50)]", options: [], views: imagePinUserAvatar)
        
        // Comment Pin Username
        labelPinUserName = UILabel()
        labelPinUserName.text = ""
        labelPinUserName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        labelPinUserName.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelPinTitle.textAlignment = .left
        uiviewPinDetail.addSubview(labelPinUserName)
        uiviewPinDetail.addConstraintsWithFormat("H:|-80-[v0(250)]", options: [], views: labelPinUserName)
        uiviewPinDetail.addConstraintsWithFormat("V:|-19-[v0(25)]", options: [], views: labelPinUserName)
        
        // Timestamp of comment pin detail
        labelPinTimestamp = UILabel()
        labelPinTimestamp.text = ""
        labelPinTimestamp.font = UIFont(name: "AvenirNext-Medium", size: 13)
        labelPinTimestamp.textColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0)
        labelPinTimestamp.textAlignment = .left
        uiviewPinDetail.addSubview(labelPinTimestamp)
        uiviewPinDetail.addConstraintsWithFormat("H:|-80-[v0(200)]", options: [], views: labelPinTimestamp)
        uiviewPinDetail.addConstraintsWithFormat("V:|-40-[v0(27)]", options: [], views: labelPinTimestamp)
        
        // image view appears when saved pin button pressed
        imageViewSaved = UIImageView()
        imageViewSaved.image = UIImage(named: "imageSavedThisPin")
        view.addSubview(imageViewSaved)
        view.addConstraintsWithFormat("H:[v0(182)]", options: [], views: imageViewSaved)
        view.addConstraintsWithFormat("V:|-107-[v0(58)]", options: [], views: imageViewSaved)
        NSLayoutConstraint(item: imageViewSaved, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        imageViewSaved.layer.zPosition = 104
        imageViewSaved.alpha = 0.0
        
        loadAnotherToolbar()
        loadPeopleTable()
        loadPinCtrlButton()
    }
    
    private func loadNavigationBar() {
        subviewNavigation = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 65))
        subviewNavigation.backgroundColor = UIColor.white
        self.view.addSubview(subviewNavigation)
        subviewNavigation.layer.zPosition = 101
        subviewNavigation.center.y -= screenHeight
        
        // Line at y = 64
        uiviewPinUnderLine01 = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 1))
        uiviewPinUnderLine01.layer.borderWidth = screenWidth
        uiviewPinUnderLine01.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        subviewNavigation.addSubview(uiviewPinUnderLine01)
        
        // Back to Map
        buttonPinBackToMap = UIButton()
        buttonPinBackToMap.setImage(UIImage(named: "commentPinBackToMap"), for: UIControlState())
        buttonPinBackToMap.addTarget(self, action: #selector(self.actionBackToMap(_:)), for: UIControlEvents.touchUpInside)
        subviewNavigation.addSubview(buttonPinBackToMap)
        subviewNavigation.addConstraintsWithFormat("H:|-(-24)-[v0(101)]", options: [], views: buttonPinBackToMap)
        subviewNavigation.addConstraintsWithFormat("V:|-22-[v0(38)]", options: [], views: buttonPinBackToMap)
        buttonPinBackToMap.alpha = 0.0
        
        // Back to Comment Pin List
        buttonBackToPinLists = UIButton()
        buttonBackToPinLists.setImage(UIImage(named: "commentPinBackToList"), for: UIControlState())
        buttonBackToPinLists.addTarget(self, action: #selector(self.actionGoToList(_:)), for: UIControlEvents.touchUpInside)
        subviewNavigation.addSubview(buttonBackToPinLists)
        subviewNavigation.addConstraintsWithFormat("H:|-(-24)-[v0(101)]", options: [], views: buttonBackToPinLists)
        subviewNavigation.addConstraintsWithFormat("V:|-22-[v0(38)]", options: [], views: buttonBackToPinLists)
        
        // Comment Pin Option
        buttonOptionOfPin = UIButton()
        buttonOptionOfPin.setImage(UIImage(named: "commentPinOption"), for: UIControlState())
        buttonOptionOfPin.addTarget(self, action: #selector(self.showPinMoreButtonDetails(_:)), for: UIControlEvents.touchUpInside)
        subviewNavigation.addSubview(buttonOptionOfPin)
        subviewNavigation.addConstraintsWithFormat("H:[v0(101)]-(-22)-|", options: [], views: buttonOptionOfPin)
        subviewNavigation.addConstraintsWithFormat("V:|-23-[v0(37)]", options: [], views: buttonOptionOfPin)
        
        // Label of Title
        labelPinTitle = UILabel()
        labelPinTitle.text = "Moment"
        labelPinTitle.font = UIFont(name: "AvenirNext-Medium", size: 20)
        labelPinTitle.textColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        labelPinTitle.textAlignment = .center
        subviewNavigation.addSubview(labelPinTitle)
        subviewNavigation.addConstraintsWithFormat("H:[v0(92)]", options: [], views: labelPinTitle)
        subviewNavigation.addConstraintsWithFormat("V:|-28-[v0(27)]", options: [], views: labelPinTitle)
        NSLayoutConstraint(item: labelPinTitle, attribute: .centerX, relatedBy: .equal, toItem: subviewNavigation, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
    }
    
    func loadPeopleTable() {
        tableViewPeople = UITableView(frame: CGRect(x: 0, y: 281, width: screenWidth, height: 0))
        tableViewPeople.delegate = self
        tableViewPeople.dataSource = self
        tableViewPeople.allowsSelection = false
        tableViewPeople.delaysContentTouches = false
        tableViewPeople.register(OPLTableViewCell.self, forCellReuseIdentifier: "commentPinPeopleCell")
        tableViewPeople.isScrollEnabled = false
        //                tableCommentsForComment.layer.borderColor = UIColor.blackColor().CGColor
        //                tableCommentsForComment.layer.borderWidth = 1.0
        uiviewPinDetail.addSubview(tableViewPeople)
        tableViewPeople.isHidden = true
    }
    
    func loadAnotherToolbar() {
        // Gray Block
        controlBoard = UIView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: 54))
        controlBoard.backgroundColor = UIColor.white
        self.view.addSubview(controlBoard)
        self.controlBoard.isHidden = true
        controlBoard.layer.zPosition = 110
        
        let anotherGrayBlock = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 12))
        anotherGrayBlock.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        self.controlBoard.addSubview(anotherGrayBlock)
        
        // Three buttons bottom gray line
        let grayBaseLine = UIView()
        grayBaseLine.layer.borderWidth = 1.0
        grayBaseLine.layer.borderColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0).cgColor
        self.controlBoard.addSubview(grayBaseLine)
        self.controlBoard.addConstraintsWithFormat("H:|-0-[v0(\(screenWidth))]", options: [], views: grayBaseLine)
        self.controlBoard.addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: grayBaseLine)
        
        // View to hold three buttons
        let threeButtonsContainer = UIView(frame: CGRect(x: 0, y: 12, width: screenWidth, height: 42))
        self.controlBoard.addSubview(threeButtonsContainer)
        
        let widthOfThreeButtons = screenWidth / 2
        
        // Three buttons bottom sliding red line
        anotherRedSlidingLine = UIView(frame: CGRect(x: 0, y: 52, width: widthOfThreeButtons, height: 2))
        anotherRedSlidingLine.layer.borderWidth = 1.0
        anotherRedSlidingLine.layer.borderColor = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0).cgColor
        self.controlBoard.addSubview(anotherRedSlidingLine)
        
        // "Comments" of this uiview
        let comments = UIButton()
        comments.setImage(UIImage(named: "commentDetailThreeButtonComments"), for: UIControlState())
        comments.addTarget(self, action: #selector(self.animationRedSlidingLine(_:)), for: .touchUpInside)
        threeButtonsContainer.addSubview(comments)
        comments.tag = 1
        threeButtonsContainer.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: comments)
        
        
        // "People" of this uiview
        let people = UIButton()
        //        people.setImage(UIImage(named: "commentDetailThreeButtonPeople"), forState: .Normal)
        //        people.addTarget(self, action: #selector(self.animationRedSlidingLine(_:)), forControlEvents: .TouchUpInside)
        threeButtonsContainer.addSubview(people)
        people.tag = 3
        threeButtonsContainer.addConstraintsWithFormat("V:|-0-[v0(42)]", options: [], views: people)
        
        threeButtonsContainer.addConstraintsWithFormat("H:|-0-[v0(\(widthOfThreeButtons))]-0-[v1(\(widthOfThreeButtons))]", options: [], views: comments, people)
        
    }
    
    func loadPinCtrlButton() {
        pinIcon = UIImageView(frame: CGRect(x: 185, y: 477, width: 60, height: 80))
        pinIcon.image = #imageLiteral(resourceName: "markerMomentPinHeavyShadow")
        pinIcon.contentMode = .scaleAspectFit
        pinIcon.center.x = screenWidth/2
        pinIcon.center.y = 510
        pinIcon.layer.zPosition = 50
        pinIcon.alpha = 0
        self.view.addSubview(pinIcon)
        
        buttonPrevPin = UIButton(frame: CGRect(x: 15, y: 477, width: 52, height: 52))
        buttonPrevPin.setImage(UIImage(named: "prevPin"), for: UIControlState())
        buttonPrevPin.layer.zPosition = 60
        buttonPrevPin.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).cgColor
        buttonPrevPin.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        buttonPrevPin.layer.shadowOpacity = 0.6
        buttonPrevPin.layer.shadowRadius = 3.0
        buttonPrevPin.alpha = 0
        self.view.addSubview(buttonPrevPin)
        
        buttonNextPin = UIButton(frame: CGRect(x: 399, y: 477, width: 52, height: 52))
        buttonNextPin.setImage(UIImage(named: "nextPin"), for: UIControlState())
        buttonNextPin.layer.zPosition = 60
        buttonNextPin.layer.shadowColor = UIColor(red: 107/255, green: 105/255, blue: 105/255, alpha: 1.0).cgColor
        buttonNextPin.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        buttonNextPin.layer.shadowOpacity = 0.6
        buttonNextPin.layer.shadowRadius = 3.0
        buttonNextPin.alpha = 0
        self.view.addSubview(buttonNextPin)
        self.view.addConstraintsWithFormat("H:[v0(52)]-15-|", options: [], views: buttonNextPin)
        self.view.addConstraintsWithFormat("V:|-477-[v0(52)]", options: [], views: buttonNextPin)
    }
}