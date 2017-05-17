//
//  PinsTableViewCell.swift
//  faeBeta
//
//  Created by Shiqi Wei on 4/17/17.
//  Edited by Sophie Wang
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
// A protocol that the TableViewCell uses to inform its delegate of state change
protocol PinTableViewCellDelegate {
    // indicates that the given item has been deleted
    func itemSwiped(indexCell: Int)
    func toDoItemShared(indexCell: Int, pinId: Int, pinType: String)
    func toDoItemLocated(indexCell: Int, pinId: Int, pinType: String)
    func toDoItemUnsaved(indexCell: Int, pinId: Int, pinType: String)
    func toDoItemRemoved(indexCell: Int, pinId: Int, pinType: String)
    func toDoItemEdit(indexCell: Int, pinId: Int, pinType: String)
    func toDoItemVisible(indexCell: Int, pinId: Int, pinType: String) 
}

class PinsTableViewCell: UITableViewCell {
    var lblDate : UILabel!
    var lblDescription : UILabel!
    var lblLike : UILabel!
    var lblComment : UILabel!
    var arrImgPinPic = [UIImageView]()
    var lblPics3Plus : UILabel!
    var imgLike : UIImageView!
    var imgComment : UIImageView!
    var imgPinTab : UIImageView!
    var imgHot : UIImageView!
    var boolIsHot : Bool! = false
    var pointOriginalCenter = CGPoint()
    var boolShowOnDragRelease = false
    var uiviewPinView : UIView! // this view is for pin
    var uiviewSwipedBtnsView : UIView! // this view is for buttons when swiped
    var uiviewCellView : UIView! // this view contains view for pin and view for buttons when swiped
    // The object that acts as delegate for this cell.
    var delegate : PinTableViewCellDelegate?
    var boolIsCellSWiped = false
    var indexForCurrentCell = 0
    var intPinId = 0
    var strPinType = ""
    var finishedPositionX : CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
        // add a pan recognizer
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        recognizer.delegate = self
        uiviewPinView.addGestureRecognizer(recognizer)
    }
    // Interface - Initialize the position of swiped buttons
    func verticalCenterButtons() {
    }
    // handle function of pan gesture
    func handlePan(recognizer: UIPanGestureRecognizer) {
        // when the gesture begins, record the current center location
        if recognizer.state == .began {
            pointOriginalCenter = uiviewCellView.center
            verticalCenterButtons()
            // if the cell is already swiped or not
            if(uiviewCellView.center.x > 150) {
                boolIsCellSWiped = true
            }
            else {
                boolIsCellSWiped = false
            }
        }
        
        // has the user dragged the item far enough?
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            boolShowOnDragRelease = uiviewCellView.center.x > 70 && !boolIsCellSWiped
            if(uiviewCellView.center.x <= -9) {
                // don't remove when the left side of the cell reaches -8
                uiviewCellView.center = CGPoint(x: -10, y: uiviewCellView.center.y)
            }
            else {
                uiviewCellView.center = CGPoint(x: pointOriginalCenter.x + translation.x, y:pointOriginalCenter.y)
            }
        }
        
        // the gesture ends
        if recognizer.state == .ended || recognizer.state == .failed || recognizer.state == .cancelled {
            let frameCellView = uiviewCellView.frame
            // the frame this cell had before user dragged it
            let frameOriginal = CGRect(x: -screenWidth, y: frameCellView.origin.y,
                                       width: frameCellView.width, height: frameCellView.height)
            // the frame this cell will be after user dragged it
            let frameFinish = CGRect(x: -screenWidth + finishedPositionX, y: frameCellView.origin.y,
                                     width: frameCellView.width, height: frameCellView.height)
            // the frame this cell will bounce to after user dragged it from right to left
            let frameBounce = CGRect(x: -screenWidth + 35, y: frameCellView.origin.y,
                                     width: frameCellView.width, height: frameCellView.height)
            if !boolShowOnDragRelease {
                if uiviewCellView.center.x < 0 {
                    // if the item is being swiped from right to left, bonuce back to the original location
                    UIView.animate(withDuration: 0.3, animations: {
                       self.uiviewCellView.frame = frameBounce
                    }, completion: { (finished) -> Void in
                        UIView.animate(withDuration: 0.3, animations: {self.uiviewCellView.frame = frameOriginal})
                    })
                }
                else {
                    // if the item is not being swiped enough, snap back to the original location
                    UIView.animate(withDuration: 0.3, animations: {self.uiviewCellView.frame = frameOriginal})
                }
            }
            else {
                UIView.animate(withDuration: 0.3, animations: {self.uiviewCellView.frame = frameFinish}, completion: { (finished) -> Void in
                    self.delegate?.itemSwiped(indexCell: self.indexForCurrentCell)
                })
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
    
    // Setup the cell when creat it
    func setUpUI() {
        // The cell is an uiviewCellView which consists of uiviewPinView and uiviewSwipedBtnsView
        uiviewCellView = UIView()
        uiviewCellView.backgroundColor = .clear
        self.addSubview(uiviewCellView)
        
        // The uiview is for pin contents
        uiviewPinView = UIView()
        uiviewPinView.backgroundColor = .white
        uiviewPinView.layer.cornerRadius = 10.0
        uiviewCellView.addSubview(uiviewPinView)
        
        // The uiview is for buttons when swiped
        uiviewSwipedBtnsView = UIView()
        uiviewSwipedBtnsView.backgroundColor = .clear
        uiviewCellView.addSubview(uiviewSwipedBtnsView)
        
        //set the date
        lblDate = UILabel()
        lblDate.font = UIFont(name: "AvenirNext-Medium", size: 13)
        uiviewPinView.addSubview(lblDate)
        
        // set description
        lblDescription = UILabel()
        lblDescription.lineBreakMode = NSLineBreakMode.byTruncatingTail
        lblDescription.numberOfLines = 3
        lblDescription.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lblDescription.textAlignment = .left
        lblDescription.textColor = UIColor.faeAppInputTextGrayColor()
        uiviewPinView.addSubview(lblDescription)
        
        // set like number
        lblLike = UILabel()
        lblLike.font = UIFont(name: "AvenirNext-Medium", size: 10)
        lblLike.textAlignment = .right
        lblLike.textColor = UIColor.faeAppTimeTextBlackColor()
        uiviewPinView.addSubview(lblLike)
        
        // set like
        imgLike = UIImageView()
        imgLike.image = #imageLiteral(resourceName: "like")
        uiviewPinView.addSubview(imgLike)
        
        // set comment number
        lblComment = UILabel()
        lblComment.font = UIFont(name: "AvenirNext-Medium", size: 10)
        lblComment.textAlignment = .right
        lblComment.textColor = UIColor.faeAppTimeTextBlackColor()
        uiviewPinView.addSubview(lblComment)
        
        // set comment button
        imgComment = UIImageView()
        imgComment.image = #imageLiteral(resourceName: "comment")
        uiviewPinView.addSubview(imgComment)
        
        // set tab
        imgPinTab = UIImageView()
        uiviewPinView.addSubview(imgPinTab!)
        
        // set hot
        imgHot = UIImageView()
        imgHot.image = #imageLiteral(resourceName: "hot")
        uiviewPinView.addSubview(imgHot!)
        imgHot.isHidden = true
        
        // set the "3+" label
        lblPics3Plus = UILabel()
        lblPics3Plus.text = "3+"
        lblPics3Plus.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblPics3Plus.textColor = UIColor.faeAppInputPlaceholderGrayColor()
        uiviewPinView.addSubview(lblPics3Plus)
        
        //Add the constraints of uiviewPinView & uiviewSwipedBtnsView in the uiviewCellView
        uiviewCellView.addConstraintsWithFormat("H:|-0-[v0(\(screenWidth))]-9-[v1]-9-|", options: [], views: uiviewSwipedBtnsView, uiviewPinView)
        uiviewCellView.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewPinView)
        uiviewCellView.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewSwipedBtnsView)
        
        //Add the constraints of uiviewCellView in the cell self
        self.addConstraintsWithFormat("H:|-(-\(screenWidth))-[v0]-0-|", options: [], views: uiviewCellView)
        self.addConstraintsWithFormat("V:|-0-[v0]-0-|", options: [], views: uiviewCellView)
    }
    
    // call this fuction when reuse cell, set value to the cell and rebuild the layout
    func setValueForCell(_ pin: [String: AnyObject]) {
        //The cell is reuseable, so clear the constrains in uiviewPinView when reuse the cell
        uiviewPinView.removeConstraints(uiviewPinView.constraints)
        // remove previous pin pics when reuse the cell
        for imgView in arrImgPinPic {
            imgView.removeFromSuperview()
        }
        lblPics3Plus.isHidden = true
        arrImgPinPic.removeAll()
        boolIsHot = false
        
        // set the value to those data
        if let type = pin["type"] {
            strPinType = type as! String
        }
        if let id = pin["pin_id"] {
            intPinId = id as! Int
        }
        
        if let createat = pin["created_at"] {
            lblDate.text = (createat as! String).formatNSDate()
        }
        
        if let likeCount = pin["liked_count"] as! Int? {
            lblLike.text = String(likeCount)
            if likeCount >= 15 {
                boolIsHot = true
            }
        }
        if let commentCount = pin["comment_count"]as! Int? {
            lblComment.text = String(commentCount)
            if commentCount >= 10 {
                boolIsHot = true
            }
        }
        
        //Add the constraints in uiviewPinView
        uiviewPinView.addConstraintsWithFormat("V:|-12-[v0(18)]", options: [], views: lblDate)
        
        uiviewPinView.addConstraintsWithFormat("H:|-20-[v0]-20-|", options: [], views: lblDescription)
        
        uiviewPinView.addConstraintsWithFormat("H:[v0(27)]-95-|", options: [], views: lblLike)
        uiviewPinView.addConstraintsWithFormat("V:[v0(14)]-11-|", options: [], views: lblLike)
        
        uiviewPinView.addConstraintsWithFormat("H:[v0(18)]-73-|", options: [], views: imgLike)
        uiviewPinView.addConstraintsWithFormat("V:[v0(15)]-12-|", options: [], views: imgLike)
        
        uiviewPinView.addConstraintsWithFormat("H:[v0(27)]-34-|", options: [], views: lblComment)
        uiviewPinView.addConstraintsWithFormat("V:[v0(14)]-11-|", options: [], views: lblComment)
        
        uiviewPinView.addConstraintsWithFormat("H:[v0(18)]-13-|", options: [], views: imgComment)
        uiviewPinView.addConstraintsWithFormat("V:[v0(15)]-12-|", options: [], views: imgComment)
        
        uiviewPinView.addConstraintsWithFormat("H:|-0-[v0(20)]|", options: [], views: imgPinTab)
        uiviewPinView.addConstraintsWithFormat("V:[v0(11)]-14-|", options: [], views: imgPinTab)
        
        uiviewPinView.addConstraintsWithFormat("H:[v0(18)]-134-|", options: [], views: imgHot)
        uiviewPinView.addConstraintsWithFormat("V:[v0(20)]-10-|", options: [], views: imgHot)
        
        // hot or not
        if boolIsHot == true {
            imgHot.isHidden = false
        }
        else {
            imgHot.isHidden = true
        }
        
        // for media pin
        if strPinType == "media" {
            if let descContent = pin["description"] as? String {
                lblDescription.attributedText = descContent.convertStringWithEmoji()
            }
            imgPinTab.image = UIImage(named: "tab_comment")
            if let imgArr = pin["file_ids"] as? NSArray {
                for imgID in imgArr {
                    let imgId = String(describing: imgID)
                    let realm = try! Realm()
                    if let mediaRealm = realm.objects(FileObject.self).filter("fileId == \(imgId) AND picture != nil").first {
                        arrImgPinPic.append(UIImageView(image: UIImage.sd_image(with: mediaRealm.picture as Data!)))
                    }
                    else {
                        let fileURL = "\(baseURL)/files/\(imgId)/data"
                        let imgPinPic = UIImageView()
                        arrImgPinPic.append(imgPinPic)
                        imgPinPic.sd_setImage(with: URL(string: fileURL), placeholderImage: nil, options: [.retryFailed, .refreshCached], completed: { (image, error, SDImageCacheType, imageURL) in
                            if image != nil {
                                let mediaImage = FileObject()
                                mediaImage.fileId = Int(imgId) ?? 0
                                mediaImage.picture = UIImageJPEGRepresentation(image!, 0.5) as NSData?
                                try! realm.write {
                                    realm.add(mediaImage)
                                }
                            }
                        })
                    }
                }
                let count = imgArr.count
                // no pic
                if count == 0 {
                    uiviewPinView.addConstraintsWithFormat("V:|-39-[v0]-42-|", options: [], views: lblDescription)
                }
                // the first image
                if count>0 {
                    arrImgPinPic[0].contentMode = .scaleAspectFill
                    arrImgPinPic[0].layer.cornerRadius = 13.5
                    arrImgPinPic[0].clipsToBounds = true
                    arrImgPinPic[0].isUserInteractionEnabled = true
                    uiviewPinView.addSubview(arrImgPinPic[0])
                    uiviewPinView.addConstraintsWithFormat("V:|-39-[v0]-12-[v1(95)]-42-|", options: [], views: lblDescription,arrImgPinPic[0])
                    uiviewPinView.addConstraintsWithFormat("H:|-20-[v0(95)]", options: [], views: arrImgPinPic[0])
                }
                // the second image
                if count>1 {
                    arrImgPinPic[1].contentMode = .scaleAspectFill
                    arrImgPinPic[1].layer.cornerRadius = 13.5
                    arrImgPinPic[1].clipsToBounds = true
                    arrImgPinPic[1].isUserInteractionEnabled = true
                    uiviewPinView.addSubview(arrImgPinPic[1])
                    uiviewPinView.addConstraintsWithFormat("H:[v0]-10-[v1(95)]", options: [], views: arrImgPinPic[0],arrImgPinPic[1])
                    uiviewPinView.addConstraintsWithFormat("V:[v0]-12-[v1(95)]-42-|", options: [], views: lblDescription,arrImgPinPic[1])
                }
                
                //the third image
                if count>2 {
                    arrImgPinPic[2].contentMode = .scaleAspectFill
                    arrImgPinPic[2].layer.cornerRadius = 13.5
                    arrImgPinPic[2].clipsToBounds = true
                    arrImgPinPic[2].isUserInteractionEnabled = true
                    uiviewPinView.addSubview(arrImgPinPic[2])

                    uiviewPinView.addConstraintsWithFormat("H:[v0]-10-[v1(95)]", options: [], views: arrImgPinPic[1],arrImgPinPic[2])
                    uiviewPinView.addConstraintsWithFormat("V:[v0]-12-[v1(95)]-42-|", options: [], views: lblDescription,arrImgPinPic[2])
                }
                // more than 3 pics
                if count>3 {
                    lblPics3Plus.isHidden = false
                    uiviewPinView.addConstraintsWithFormat("V:[v0]-47-[v1(25)]", options: [], views: lblDescription,lblPics3Plus)
                    uiviewPinView.addConstraintsWithFormat("H:[v0]-18-[v1(23)]", options: [], views: arrImgPinPic[2],lblPics3Plus)
                }
            }
        }
        //For comment pin
        if strPinType == "comment" {
            if let descContent = pin["content"] as? String {
                lblDescription.attributedText = descContent.convertStringWithEmoji()
            }
            imgPinTab.image = UIImage(named: "tab_story")
            uiviewPinView.addConstraintsWithFormat("V:|-39-[v0]-42-|", options: [], views: lblDescription)
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
