//
//  SetAvatarViewController.swift
//  faeBeta
//
//  Created by Jichao on 2017/11/11.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import Photos
import RealmSwift

class SetAvatar {
    
    static func uploadUserImage(image: UIImage, vc: UIViewController, type: String, isProfilePic: Bool = true) {
        //let currentVC: UIViewController
        var activityIndicator = UIActivityIndicatorView()
        var imgView = UIImageView()
        switch type {
        case "leftSliding":
            let currentVC = vc as! LeftSlidingMenuViewController
            activityIndicator = currentVC.activityIndicator
            imgView = currentVC.imgAvatar
        case "firstTimeLogin":
            let currentVC = vc as! FirstTimeLoginViewController
            activityIndicator = currentVC.activityIndicator
            imgView = currentVC.imageViewAvatar
        case "setNamecard":
            let currentVC = vc as! SetInfoNamecard
            activityIndicator = currentVC.activityIndicator
            if isProfilePic {
                imgView = currentVC.uiviewNameCard.imgAvatar
            } else {
                imgView = currentVC.uiviewNameCard.imgCover
            }
        default: break
        }
        vc.view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        if isProfilePic {
            let avatar = FaeImage()
            avatar.image = image
            avatar.faeUploadProfilePic { (code: Int, message: Any?) in
                activityIndicator.stopAnimating()
                vc.view.isUserInteractionEnabled = true
                if code / 100 == 2 {
                    imgView.image = image
                    print("[uploadProfileAvatar] succeed")
                    let realm = try! Realm()
                    let realmUser = UserImage()
                    realmUser.user_id = "\(Key.shared.user_id)"
                    realmUser.userSmallAvatar = RealmChat.compressImageToData(image)! as NSData
                    try! realm.write {
                        realm.add(realmUser, update: true)
                    }
                }
                else {
                    print("[uploadProfileAvatar] fail")
                    self.showAlert(title: "Upload Profile Avatar Failed", message: "please try again", vc: vc)
                    return
                }
            }
        } else {
            let coverPhoto = FaeImage()
            coverPhoto.image = image
            coverPhoto.faeUploadCoverPhoto { (code: Int, message: Any?) in
                activityIndicator.stopAnimating()
                vc.view.isUserInteractionEnabled = true
                if code / 100 == 2 {
                    imgView.image = image
                    print("[uploadProfileAvatar] succeed")
                    let realm = try! Realm()
                    let realmUser = UserImage()
                    realmUser.user_id = "\(Key.shared.user_id)"
                    realmUser.userCoverPhoto = RealmChat.compressImageToData(image)! as NSData
                    try! realm.write {
                        realm.add(realmUser, update: true)
                    }
                }
                else {
                    print("[faeUploadCoverPhoto] fail")
                    self.showAlert(title: "Upload Cover Photo Failed", message: "please try again", vc: vc)
                    return
                }
            }
        }
    }
    
    static func showAlert(title: String, message: String, vc: UIViewController, more: Bool = false, second_option: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive)
        alertController.addAction(okAction)
        if more {
            let secondOpt = UIAlertAction(title: second_option, style: UIAlertActionStyle.default) {
                (alert: UIAlertAction) in
                if second_option == "Settings" {
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
            }
            alertController.addAction(secondOpt)
        }
        vc.present(alertController, animated: true, completion: nil)
    }
    
    static func addUserImage(vc: UIViewController, type: String) {
        var imageDelegate: SendMutipleImagesDelegate!
        var imagePickerDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)!
        switch type {
        case "leftSliding":
            let currentVC = vc as! LeftSlidingMenuViewController
            imageDelegate = currentVC
            imagePickerDelegate = currentVC
        case "firstTimeLogin":
            let currentVC = vc as! FirstTimeLoginViewController
            imageDelegate = currentVC
            imagePickerDelegate = currentVC
        case "setNamecard":
            let currentVC = vc as! SetInfoNamecard
            imageDelegate = currentVC
            imagePickerDelegate = currentVC
        default: break
        }
        let menu = UIAlertController(title: nil, message: "Choose image", preferredStyle: .actionSheet)
        menu.view.tintColor = UIColor._2499090()
        let showLibrary = UIAlertAction(title: "Choose from library", style: .default) { (alert: UIAlertAction) in
            var photoStatus = PHPhotoLibrary.authorizationStatus()
            if photoStatus != .authorized {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    photoStatus = status
                    if photoStatus != .authorized {
                        self.showAlert(title: "Cannot access photo library", message: "Open System Setting -> Fae Map to turn on the camera access", vc: vc)
                        return
                    }
                    let imagePicker = FullAlbumCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
                    imagePicker.imageDelegate = imageDelegate
                    imagePicker.vcComeFromType = .lefeSlidingMenu
                    imagePicker.vcComeFrom = vc
                    imagePicker._maximumSelectedPhotoNum = 1
                    vc.present(imagePicker, animated: true, completion: nil)
                })
            } else {
                let albumPicker = FullAlbumCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
                albumPicker.imageDelegate = imageDelegate
                albumPicker.vcComeFromType = .lefeSlidingMenu
                albumPicker.vcComeFrom = vc
                albumPicker._maximumSelectedPhotoNum = 1
                vc.present(albumPicker, animated: true, completion: nil)
            }
        }
        let showCamera = UIAlertAction(title: "Take photos", style: .default) { (alert: UIAlertAction) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = imagePickerDelegate
            imagePicker.sourceType = .camera
            var photoStatus = PHPhotoLibrary.authorizationStatus()
            if photoStatus != .authorized {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    photoStatus = status
                    if photoStatus != .authorized {
                        self.showAlert(title: "Cannot access photo library", message: "Open System Setting -> Fae Map to turn on the camera access", vc: vc, more: true, second_option: "Settings")
                        return
                    }
                    menu.removeFromParentViewController()
                    vc.present(imagePicker, animated: true, completion: nil)
                })
            } else {
                switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
                case .authorized:
                    menu.removeFromParentViewController()
                    vc.present(imagePicker, animated: true, completion: nil)
                    break
                case .denied, .notDetermined, .restricted:
                    self.showAlert(title: "Cannot access photo library", message: "Open System Setting -> Fae Map to turn on the camera access", vc: vc, more: true, second_option: "Settings")
                    return
                }
                
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction) in
            
        }
        menu.addAction(showLibrary)
        menu.addAction(showCamera)
        menu.addAction(cancel)
        vc.present(menu, animated: true, completion: nil)
    }
}
