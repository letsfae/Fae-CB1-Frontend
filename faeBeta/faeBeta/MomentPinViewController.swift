//
//  MomentPinDetailViewController.swift
//  faeBeta
//
//  Created by Yue on 12/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation
import RealmSwift

class MomentPinDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FAEChatToolBarContentViewDelegate, UITextViewDelegate, UIScrollViewDelegate {
    
    let colorFae = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
    
    // Delegate of this class
    weak var delegate: PinDetailDelegate?
    
    // Pin ID To Use In This Controller
    var pinIdSentBySegue: Int = -999
    
    // Pin options
    var buttonShareOnPinDetail: UIButton!
    var buttonEditOnPinDetail: UIButton!
    var buttonSaveOnPinDetail: UIButton!
    var buttonDeleteOnPinDetail: UIButton!
    var buttonReportOnPinDetail: UIButton!
    
    // New Moment Pin Popup Window
    var numberOfCommentTableCells: Int = 0
    var dictCommentsOnPinDetail = [[String: AnyObject]]()
    var animatingHeart: UIImageView!
    var boolPinLiked = false
    var buttonBackToPinLists: UIButton!
    var buttonPinDetailViewActive: UIButton!
    var buttonPinDetailViewComments: UIButton!
    var buttonPinDetailViewPeople: UIButton!
    var buttonPinAddComment: UIButton!
    var buttonPinBackToMap: UIButton!
    var buttonPinDetailDragToLargeSize: UIButton!
    var buttonPinDownVote: UIButton!
    var buttonPinLike: UIButton!
    var buttonPinUpVote: UIButton!
    var buttonMoreOnPinCellExpanded = false
    var buttonOptionOfPin: UIButton!
    var pinIDPinDetailView: String = "-999"
    var pinDetailLiked = false
    var pinDetailShowed = false
    var imagePinUserAvatar: UIImageView!
    var imageViewSaved: UIImageView!
    var labelPinCommentsCount: UILabel!
    var labelPinLikeCount: UILabel!
    var labelPinTimestamp: UILabel!
    var labelPinTitle: UILabel!
    var labelPinUserName: UILabel!
    var labelPinVoteCount: UILabel!
    var moreButtonDetailSubview: UIImageView!
    var tableCommentsForPin: UITableView!
    var textviewPinDetail: UITextView!
    var uiviewPinDetailThreeButtons: UIView!
    var uiviewPinDetail: UIView!
    var uiviewPinDetailGrayBlock: UIView!
    var uiviewPinDetailMainButtons: UIView!
    var uiviewPinUnderLine01: UIView!
    var uiviewPinUnderLine02: UIView!
    var uiviewGrayBaseLine: UIView!
    var uiviewRedSlidingLine: UIView!
    var anotherRedSlidingLine: UIView!
    var subviewNavigation: UIView!
    var lableTextViewPlaceholder: UILabel!
    
    // For Dragging
    var pinSizeFrom: CGFloat = 0
    var pinSizeTo: CGFloat = 0
    
    // Like Function
    var pinLikeCount: Int = 0
    var isUpVoting = false
    var isDownVoting = false
    
    // Fake Transparent View For Closing
    var buttonFakeTransparentClosingView: UIButton!
    
    // Check if this pin belongs to current user
    var thisIsMyPin = false
    
    // Control the back to pin detail button, prevent the more than once action
    var backJustOnce = true
    
    // A duplicate ControlBoard to hold
    var controlBoard: UIView!
    
    // People table
    var tableViewPeople: UITableView!
    var dictPeopleOfPinDetail = [Int: String]()
    
    // Toolbar
    var inputToolbar: JSQMessagesInputToolbarCustom!
    var isObservingInputTextView = false
    var inputTextViewContext = 0
    var inputTextViewMaximumHeight:CGFloat = 250 * screenHeightFactor * screenHeightFactor// the distance from the top of toolbar to top of screen
    var toolbarDistanceToBottom: NSLayoutConstraint!
    var toolbarHeightConstraint: NSLayoutConstraint!
    
    //custom toolBar the bottom toolbar button
    var buttonSet = [UIButton]()
    var buttonSend : UIButton!
    var buttonKeyBoard : UIButton!
    var buttonSticker : UIButton!
    var buttonImagePicker : UIButton!
    var toolbarContentView: FAEChatToolBarContentView!
    
    var switchedToFullboard = true // FullboardScrollView and TableViewCommentsOnPin control
    var draggingButtonSubview: UIView! // Another dragging button for UI effect
    var animatingHeartTimer: Timer! // Timer for animating heart
    var touchToReplyTimer: Timer! // Timer for touching pin comment cell
    var subviewInputToolBar: UIView! // subview to hold input toolbar
    var firstLoadInputToolBar = true
    var replyToUser = "" // Reply to specific user, set string as "" if no user is specified
    var grayBackButton: UIButton! // Background gray button, alpha = 0.3
    var pinIcon: UIImageView! // Icon to indicate pin type
    var selectedMarkerPosition: CLLocationCoordinate2D!
    var buttonPrevPin: UIButton!
    var buttonNextPin: UIButton!
    var collectionViewMedia: UICollectionView! // container to display pin's media
    var fileIdArray = [Int]()
    var layout = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.modalPresentationStyle = .overCurrentContext
        loadTransparentButtonBackToMap()
        loadPinDetailWindow()
        pinIDPinDetailView = "\(pinIdSentBySegue)"
        if pinIDPinDetailView != "-999" {
            getSeveralInfo()
        }
    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        self.delegate?.animateToSelectedMarker(coordinate: selectedMarkerPosition)
        UIView.animate(withDuration: 0.633, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.subviewNavigation.frame.origin.y = 0
            self.tableCommentsForPin.frame.origin.y = 65
            self.draggingButtonSubview.frame.origin.y = 292
            self.grayBackButton.alpha = 1
            self.pinIcon.alpha = 1
            self.buttonPrevPin.alpha = 1
            self.buttonNextPin.alpha = 1
            }, completion: { (done: Bool) in
                self.loadInputToolBar()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if inputToolbar != nil {
            closeToolbarContentView()
            removeObservers()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getSeveralInfo() {
        getPinAttributeNum("media", pinID: pinIDPinDetailView)
        getPinInfo()
        getPinComments("media", pinID: pinIDPinDetailView, sendMessageFlag: false)
    }
    
    func loadTransparentButtonBackToMap() {
        grayBackButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        grayBackButton.backgroundColor = UIColor(red: 115/255, green: 115/255, blue: 115/255, alpha: 0.3)
        grayBackButton.alpha = 0
        self.view.addSubview(grayBackButton)
        self.view.sendSubview(toBack: grayBackButton)
        grayBackButton.addTarget(self, action: #selector(self.actionBackToMap(_:)), for: .touchUpInside)
    }
    
    func loadInputToolBar() {
        if !firstLoadInputToolBar {
            return
        }
        firstLoadInputToolBar = false
        setupInputToolbar()
        setupToolbarContentView()
        addObservers()
        for constraint in self.inputToolbar.constraints{
            if constraint.constant == 90 {
                toolbarHeightConstraint = constraint
            }
        }
        if toolbarHeightConstraint == nil{
            toolbarHeightConstraint = NSLayoutConstraint(item:inputToolbar, attribute:.height,relatedBy:.equal,toItem:nil,attribute:.notAnAttribute ,multiplier:1,constant:90)
            self.inputToolbar.addConstraint(toolbarHeightConstraint)
            
            toolbarDistanceToBottom = NSLayoutConstraint(item:inputToolbar, attribute:.width,relatedBy:.equal,toItem:self.view,attribute:.width ,multiplier:1,constant:0)
            self.view.addConstraint(toolbarDistanceToBottom)
            
            toolbarDistanceToBottom = NSLayoutConstraint(item:inputToolbar, attribute:.bottom,relatedBy:.equal,toItem:self.view,attribute:.bottom ,multiplier:1,constant:0)
            self.view.addConstraint(toolbarDistanceToBottom)
            self.view.setNeedsUpdateConstraints()
        }
        adjustInputToolbarHeightConstraint(byDelta: -90) // A tricky way to set the toolbarHeight to default
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name:NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name:NSNotification.Name(rawValue: "appWillEnterForeground"), object: nil)
        
        if (self.isObservingInputTextView) {
            return;
        }
        let scrollView = self.inputToolbar.contentView.textView as UIScrollView
        scrollView.addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
        
        self.isObservingInputTextView = true
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        if (!self.isObservingInputTextView) {
            return;
        }
        
        self.inputToolbar.contentView.textView.removeObserver(self, forKeyPath: "contentSize", context: nil)
        self.isObservingInputTextView = false
    }
    
    func setupInputToolbar()
    {
        func loadInputBarComponent() {
            
            //        let camera = Camera(delegate_: self)
            let contentView = self.inputToolbar.contentView
            let contentOffset = (screenWidth - 42 - 29 * 5) / 4 + 29
            buttonKeyBoard = UIButton(frame: CGRect(x: 21, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
            buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: .highlighted)
            buttonKeyBoard.addTarget(self, action: #selector(showKeyboard), for: .touchUpInside)
            contentView?.addSubview(buttonKeyBoard)
            
            /*
             buttonSticker = UIButton(frame: CGRect(x: 21 + contentOffset * 1, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
             buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
             buttonSticker.setImage(UIImage(named: "sticker"), forState: .Highlighted)
             buttonSticker.addTarget(self, action: #selector(self.showStikcer), forControlEvents: .TouchUpInside)
             contentView.addSubview(buttonSticker)
             
             buttonImagePicker = UIButton(frame: CGRect(x: 21 + contentOffset * 2, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
             buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
             buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Highlighted)
             contentView.addSubview(buttonImagePicker)
             
             buttonImagePicker.addTarget(self, action: #selector(self.showLibrary), forControlEvents: .TouchUpInside)
             
             let buttonCamera = UIButton(frame: CGRect(x: 21 + contentOffset * 3, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
             buttonCamera.setImage(UIImage(named: "camera"), forState: .Normal)
             buttonCamera.setImage(UIImage(named: "camera"), forState: .Highlighted)
             contentView.addSubview(buttonCamera)
             
             buttonCamera.addTarget(self, action: #selector(self.showCamera), forControlEvents: .TouchUpInside)
             */
            
            buttonSend = UIButton(frame: CGRect(x: 21 + contentOffset * 4, y: self.inputToolbar.frame.height - 36, width: 29, height: 29))
            buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
            buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: .highlighted)
            contentView?.addSubview(buttonSend)
            buttonSend.isEnabled = false
            buttonSend.addTarget(self, action: #selector(self.sendMessageButtonTapped), for: .touchUpInside)
            
            buttonSet.append(buttonKeyBoard)
            //            buttonSet.append(buttonSticker)
            //            buttonSet.append(buttonImagePicker)
            //            buttonSet.append(buttonCamera)
            buttonSet.append(buttonSend)
            
            for button in buttonSet{
                button.autoresizingMask = [.flexibleTopMargin]
            }
        }
        inputToolbar = JSQMessagesInputToolbarCustom(frame: CGRect(x: 0, y: screenHeight-90, width: screenWidth, height: 90))
        inputToolbar.contentView.textView.delegate = self
        inputToolbar.contentView.textView.tintColor = colorFae
        inputToolbar.contentView.textView.font = UIFont(name: "AvenirNext-Regular", size: 18)
        inputToolbar.contentView.textView.delaysContentTouches = false
        lableTextViewPlaceholder = UILabel(frame: CGRect(x: 7, y: 3, width: 200, height: 27))
        lableTextViewPlaceholder.font = UIFont(name: "AvenirNext-Regular", size: 18)
        lableTextViewPlaceholder.textColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0)
        lableTextViewPlaceholder.text = "Write a Comment..."
        inputToolbar.contentView.textView.addSubview(lableTextViewPlaceholder)
        
        inputToolbar.maximumHeight = 128
        subviewInputToolBar = UIView(frame: CGRect(x: 0, y: screenHeight-90, width: screenWidth, height: 90))
        subviewInputToolBar.backgroundColor = UIColor.white
        self.view.addSubview(subviewInputToolBar)
        subviewInputToolBar.layer.zPosition = 120
        self.view.addSubview(inputToolbar)
        inputToolbar.layer.zPosition = 121
        loadInputBarComponent()
        inputToolbar.isHidden = true
        subviewInputToolBar.isHidden = true
    }
    
    func setupToolbarContentView() {
        toolbarContentView = FAEChatToolBarContentView(frame: CGRect(x: 0,y: screenHeight,width: screenWidth, height: 271))
        toolbarContentView.delegate = self
        toolbarContentView.cleanUpSelectedPhotos()
        UIApplication.shared.keyWindow?.addSubview(toolbarContentView)
    }
    
    // Animation of the red sliding line
    func animationRedSlidingLine(_ sender: UIButton) {
        endEdit()
        if sender.tag == 1 {
            tableViewPeople.isHidden = true
            tableCommentsForPin.isHidden = false
        }
        else if sender.tag == 3 {
            tableViewPeople.isHidden = false
            tableCommentsForPin.isHidden = true
        }
        let tag = CGFloat(sender.tag)
        let centerAtOneThird = screenWidth / 4
        let targetCenter = CGFloat(tag * centerAtOneThird)
        UIView.animate(withDuration: 0.25, animations:({
            self.uiviewRedSlidingLine.center.x = targetCenter
            self.anotherRedSlidingLine.center.x = targetCenter
        }), completion: { (done: Bool) in
            if done {
                
            }
        })
    }
    
    // Hide pin more options' button
    func hidePinMoreButtonDetails() {
        buttonMoreOnPinCellExpanded = false
        let subviewXBefore: CGFloat = 400 / 414 * screenWidth
        let subviewYBefore: CGFloat = 57 / 414 * screenWidth
        UIView.animate(withDuration: 0.25, animations: ({
            self.moreButtonDetailSubview.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            //            self.buttonShareOnPinDetail.frame = CGRectMake(subviewXBefore, subviewYBefore, 0, 0)
            //            self.buttonSaveOnPinDetail.frame = CGRectMake(subviewXBefore, subviewYBefore, 0, 0)
            self.buttonEditOnPinDetail.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.buttonDeleteOnPinDetail.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            self.buttonReportOnPinDetail.frame = CGRect(x: subviewXBefore, y: subviewYBefore, width: 0, height: 0)
            //            self.buttonShareOnPinDetail.alpha = 0.0
            //            self.buttonSaveOnCommentDetail.alpha = 0.0
            self.buttonEditOnPinDetail.alpha = 0.0
            self.buttonDeleteOnPinDetail.alpha = 0.0
            self.buttonReportOnPinDetail.alpha = 0.0
        }))
        buttonFakeTransparentClosingView.removeFromSuperview()
    }
    
    // Disable a button, make it unclickable
    func disableTheButton(_ button: UIButton) {
        let origImage = button.imageView?.image
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        button.setImage(tintedImage, for: UIControlState())
        button.tintColor = UIColor.lightGray
        button.isUserInteractionEnabled = false
    }
    
    // Hide pin detail window
    func hidePinDetail() {
        if uiviewPinDetail != nil {
            if pinDetailShowed {
                actionBackToMap(self.buttonPinBackToMap)
                UIView.animate(withDuration: 0.583, animations: ({
                    
                }), completion: { (done: Bool) in
                    if done {
                        
                    }
                })
            }
        }
    }
    
    func animateHeart() {
        buttonPinLike.tag = 0
        animatingHeart = UIImageView(frame: CGRect(x: 0, y: 0, width: 26, height: 22))
        animatingHeart.image = UIImage(named: "commentPinLikeFull")
        animatingHeart.layer.zPosition = 108
        uiviewPinDetailMainButtons.addSubview(animatingHeart)
        
        //
        let randomX = CGFloat(arc4random_uniform(150))
        let randomY = CGFloat(arc4random_uniform(50) + 100)
        let randomSize: CGFloat = (CGFloat(arc4random_uniform(40)) - 20) / 100 + 1
        
        let transform: CGAffineTransform = CGAffineTransform(translationX: buttonPinLike.center.x, y: buttonPinLike.center.y)
        let path =  CGMutablePath()
        path.move(to: CGPoint(x:0,y:0), transform: transform )
        path.addLine(to: CGPoint(x:randomX-75, y:-randomY), transform: transform)
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform")
        scaleAnimation.values = [NSValue(caTransform3D: CATransform3DMakeScale(1, 1, 1)), NSValue(caTransform3D: CATransform3DMakeScale(randomSize, randomSize, 1))]
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        scaleAnimation.duration = 1
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 1
        
        let orbit = CAKeyframeAnimation(keyPath: "position")
        orbit.duration = 1
        orbit.path = path
        orbit.calculationMode = kCAAnimationPaced
        animatingHeart.layer.add(orbit, forKey:"Move")
        animatingHeart.layer.add(fadeAnimation, forKey: "Opacity")
        animatingHeart.layer.add(scaleAnimation, forKey: "Scale")
        animatingHeart.layer.position = CGPoint(x: buttonPinLike.center.x, y: buttonPinLike.center.y)
    }
    
    func appWillEnterForeground(){
        
    }
    
    func keyboardWillShow(_ notification: Notification){
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
            Void in
            self.toolbarDistanceToBottom.constant = -keyboardHeight
            self.view.setNeedsUpdateConstraints()
            }, completion: nil)
    }
    
    func keyboardDidShow(_ notification: Notification){
        toolbarContentView.keyboardShow = true
    }
    
    func keyboardWillHide(_ notification: Notification){
        UIView.animate(withDuration: 0.3,delay: 0, options: .curveLinear, animations:{
            Void in
            self.toolbarDistanceToBottom.constant = 0
            self.view.setNeedsUpdateConstraints()
            }, completion: nil)
    }
    
    func keyboardDidHide(_ notification: Notification){
        toolbarContentView.keyboardShow = false
    }
    
    
    //MARK: - keyboard input bar tapped event
    func showKeyboard() {
        
        resetToolbarButtonIcon()
        self.buttonKeyBoard.setImage(UIImage(named: "keyboard"), for: UIControlState())
        self.toolbarContentView.showKeyboard()
        self.inputToolbar.contentView.textView.becomeFirstResponder()
    }
    
    func showCamera() {
        view.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: {
            self.closeToolbarContentView()
            }, completion:{ (Bool) -> Void in
        })
        let camera = Camera(delegate_: self)
        camera.presentPhotoCamera(self, canEdit: false)
    }
    
    func showStikcer() {
        resetToolbarButtonIcon()
        buttonSticker.setImage(UIImage(named: "stickerChosen"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        self.toolbarContentView.showStikcer()
        moveUpInputBarContentView(animated)
    }
    
    func showLibrary() {
        resetToolbarButtonIcon()
        buttonImagePicker.setImage(UIImage(named: "imagePickerChosen"), for: UIControlState())
        let animated = !toolbarContentView.mediaContentShow && !toolbarContentView.keyboardShow
        self.toolbarContentView.showLibrary()
        moveUpInputBarContentView(animated)
    }
    
    func sendMessageButtonTapped() {
        sendMessage(self.inputToolbar.contentView.textView.text, date: Date(), picture: nil, sticker : nil, location: nil, snapImage : nil, audio: nil)
        buttonSend.isEnabled = false
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
    }
    
    func resetToolbarButtonIcon()
    {
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: .highlighted)
        //        buttonSticker.setImage(UIImage(named: "sticker"), forState: .Normal)
        //        buttonSticker.setImage(UIImage(named: "sticker"), forState: .Highlighted)
        //        buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Highlighted)
        //        buttonImagePicker.setImage(UIImage(named: "imagePicker"), forState: .Normal)
        buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
    }
    
    func closeToolbarContentView() {
        resetToolbarButtonIcon()
        moveDownInputBar()
        toolbarContentView.closeAll()
        toolbarContentView.frame.origin.y = screenHeight
    }
    
    func moveUpInputBar() {
        toolbarDistanceToBottom.constant = -271
        self.view.setNeedsUpdateConstraints()
    }
    
    func moveDownInputBar() {
        toolbarDistanceToBottom.constant = 0
        self.view.setNeedsUpdateConstraints()
    }
    
    func moveUpInputBarContentView(_ animated: Bool)
    {
        if(animated){
            self.toolbarContentView.frame.origin.y = screenHeight
            UIView.animate(withDuration: 0.3, animations: {
                self.moveUpInputBar()
                self.toolbarContentView.frame.origin.y = screenHeight - 271
                }, completion:{ (Bool) -> Void in
            })
        }else{
            self.moveUpInputBar()
            self.toolbarContentView.frame.origin.y = screenHeight - 271
        }
    }
    
    // MARK: - send messages
    func sendMessage(_ text : String?, date: Date, picture : UIImage?, sticker : UIImage?, location : CLLocation?, snapImage : Data?, audio : Data?) {
        if let realText = text {
            commentThisPin("media", pinID: pinIDPinDetailView, text: "\(self.replyToUser)\(realText)")
        }
        self.replyToUser = ""
        self.inputToolbar.contentView.textView.text = ""
        self.lableTextViewPlaceholder.isHidden = false
        self.inputToolbar.contentView.textView.resignFirstResponder()
    }
    
    //MARK: -  UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let picture = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.sendMessage(nil, date: Date(), picture: picture, sticker : nil, location: nil, snapImage : nil, audio: nil)
        
        //        UIImageWriteToSavedPhotosAlbum(picture, self, #selector(ChatViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func image(_ image:UIImage, didFinishSavingWithError error: NSError, contextInfo:AnyObject?) {
        self.appWillEnterForeground()
    }
    
    //MARK: - toolbar Content view delegate
    func showAlertView(withWarning text:String) {
        
    }
    
    func sendStickerWithImageName(_ name : String) {
        
    }
    func sendImages(_ images:[UIImage]) {
        
    }
    
    func showFullAlbum() {
        
    }
    
    func endEdit() {
        self.view.endEditing(true)
        if inputToolbar != nil {
            self.inputToolbar.contentView.textView.resignFirstResponder()
        }
    }
    
    //MARK: - TEXTVIEW delegate
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.inputToolbar.contentView.textView {
            let spacing = CharacterSet.whitespacesAndNewlines
            
            if self.inputToolbar.contentView.textView.text.trimmingCharacters(in: spacing).isEmpty == false {
                self.lableTextViewPlaceholder.isHidden = true
            }
            else {
                self.lableTextViewPlaceholder.isHidden = false
            }
            if textView.text.characters.count == 0 {
                // when text has no char, cannot send message
                buttonSend.isEnabled = false
                buttonSend.setImage(UIImage(named: "cannotSendMessage"), for: UIControlState())
            } else {
                buttonSend.isEnabled = true
                buttonSend.setImage(UIImage(named: "canSendMessage"), for: UIControlState())
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        buttonKeyBoard.setImage(UIImage(named: "keyboardEnd"), for: UIControlState())
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        buttonKeyBoard.setImage(UIImage(named: "keyboard"), for: UIControlState())
        self.showKeyboard()
    }
    
    //MARK: - observe key path
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
        let textView = object as! UITextView
        if (textView == self.inputToolbar.contentView.textView && keyPath! == "contentSize") {
            
            let oldContentSize = (change![NSKeyValueChangeKey.oldKey]! as AnyObject).cgSizeValue
            
            let newContentSize = (change![NSKeyValueChangeKey.newKey]! as AnyObject).cgSizeValue
            
            let dy = (newContentSize?.height)! - (oldContentSize?.height)!;
            
            if toolbarHeightConstraint != nil {
                self.adjustInputToolbarForComposerTextViewContentSizeChange(dy)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if inputToolbar != nil {
            self.inputToolbar.contentView.textView.resignFirstResponder()
        }
        if touchToReplyTimer != nil {
            touchToReplyTimer.invalidate()
        }
        if tableCommentsForPin.contentOffset.y >= 227 {
            if self.controlBoard != nil {
                self.controlBoard.isHidden = false
            }
        }
        if tableCommentsForPin.contentOffset.y < 227 {
            if self.controlBoard != nil {
                self.controlBoard.isHidden = true
            }
        }
    }
    
}