//
//  SetNameViewController.swift
//  faeBeta
//
//  Created by Faevorite 2 on 2017-10-06.
//  Copyright © 2017 fae. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol SetNameBirthGenderDelegate: class {
    func updateInfo(target: String?)
}

class SetNameViewController: UIViewController, FAENumberKeyboardDelegate, UITextFieldDelegate {
    var lblTitle: UILabel!
    var btnSave: UIButton!
    var fName: String? = ""
    var lName: String? = ""
    var btnGender: UIButton!
    
    var textFName: FAETextField!
    var textLName: FAETextField!
    var textBirth: FAETextField!
    var textPswd: FAETextField!
    var textNewEmail: FAETextField!
    var dateOfBirth: String? = ""
    var numKeyPad: FAENumberKeyboard!
    var gender: String? = ""
    var btnMale: UIButton!
    var btnFemale: UIButton!
    var faeUser = FaeUser()
    var imgExclamationMark: UIImageView!
    var keyboardHeight: CGFloat!
    var btnForgot: UIButton!
    var lblWrongPswd: FaeLabel!
    var lblWrongEmail: FaeLabel!
    var indicatorView: UIActivityIndicatorView!
    
    weak var delegate: SetNameBirthGenderDelegate?
    
    // variables in extension file
    var uiviewGrayBg: UIView!
    var uiviewChooseMethod: UIView!
    var lblChoose: UILabel!
    var btnPhone: UIButton!
    var btnEmail: UIButton!
    var btnCancel: UIButton!
    
    enum SettingEnterMode {
        case name
        case birth
        case gender
        case password
        case newEmail
    }
    
    enum PasswordEnterMode {
        case password
        case other
    }
    
    var enterMode: SettingEnterMode!
    var pswdEnterMode: PasswordEnterMode!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNavBar()
        loadContent()
        createActivityIndicator()
    }
    
    fileprivate func loadNavBar() {
        let btnBack = UIButton(frame: CGRect(x: 0, y: 21 + device_offset_top, width: 48, height: 48))
        view.addSubview(btnBack)
        btnBack.setImage(#imageLiteral(resourceName: "Settings_back"), for: .normal)
        btnBack.addTarget(self, action: #selector(actionBack(_:)), for: .touchUpInside)
    }
    
    fileprivate func loadContent() {
        lblTitle = FaeLabel(CGRect(x: 0, y: 72, width: screenWidth, height: 56), .center, .medium, 20, UIColor._898989())
        lblTitle.numberOfLines = 0
        view.addSubview(lblTitle)
        btnSave = UIButton(frame: CGRect(x: 0, y: screenHeight - 277 - 50 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnSave.center.x = screenWidth / 2
        btnSave.layer.cornerRadius = 25 * screenHeightFactor
        btnSave.layer.masksToBounds = true
        btnSave.setTitle("Save", for: UIControlState())
        btnSave.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnSave.backgroundColor = UIColor._2499090()
        btnSave.addTarget(self, action: #selector(self.actionSave(_:)), for: .touchUpInside)
        view.addSubview(btnSave)
        
        switch enterMode {
        case .name:
            lblTitle.text = "\nYour Full Name"
            loadName()
            break
        case .birth:
            lblTitle.text = "\nYour Birthday"
            loadBirth()
            break
        case .gender:
            lblTitle.text = "\nYour Gender"
            loadGenderImg()
            break
        case .password:
            if pswdEnterMode == .password {
                lblTitle.text = "Enter your Current Password \nto set a New Password"
            } else {
                lblTitle.text = "Please Enter your\nPassword to Continue"
            }
            loadPassword()
        case .newEmail:
            lblTitle.text = "\nYour New Email"
            loadChangeEmailPage()
            break
        default:
            break
        }
        
        if enterMode == .name || enterMode == .password || enterMode == .newEmail {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        }
    }
    
    fileprivate func loadName() {
        textFName = FAETextField(frame: CGRect(x: 30, y: 174 * screenHeightFactor, width: screenWidth - 60, height: 34))
        textFName.fontSize = 25
        textFName.placeholder = "First Name"
        textFName.text = fName
        textFName.autocapitalizationType = .words
        textFName.becomeFirstResponder()
        view.addSubview(textFName)
        
        textLName = FAETextField(frame: CGRect(x: 30, y: 243 * screenHeightFactor, width: screenWidth - 60, height: 34))
        textLName.fontSize = 25
        textLName.placeholder = "Last Name"
        textLName.text = lName
        textLName.autocapitalizationType = .words
        
        textFName.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged )
        textLName.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged )
        view.addSubview(textLName)
        
        if fName == "" || lName == "" {
            enableSaveButton(false)
        }
    }
    
    fileprivate func loadBirth() {
        textBirth = FAETextField(frame: CGRect(x: 15, y: 174, width: screenWidth - 30, height: 34))
        textBirth.fontSize = 25
        textBirth.placeholder = "MM/DD/YYYY"
        textBirth.text = dateOfBirth
        textBirth.isEnabled = dateOfBirth != ""
        
        view.addSubview(textBirth)
        
        // setup the fake keyboard for numbers input
        numKeyPad = FAENumberKeyboard(frame: CGRect(x: 0, y: screenHeight - 244 * screenHeightFactor, width: screenWidth, height: 244 * screenHeightFactor))
        view.addSubview(numKeyPad)
        numKeyPad.delegate = self
        numKeyPad.transform = CGAffineTransform(translationX: 0, y: 0)
        
        imgExclamationMark = UIImageView(frame: CGRect(x: screenWidth / 2 + 70, y: 180, width: 7, height: 21))
        imgExclamationMark.image = #imageLiteral(resourceName: "exclamation_red_new")
        imgExclamationMark.isHidden = true
        view.addSubview(imgExclamationMark)
    }
    
    fileprivate func loadGenderImg() {
        btnMale = UIButton(frame: CGRect(x: screenWidth / 2 - 120, y: 220 * screenHeightFactor, width: 80, height: 80))
        btnMale.setImage(#imageLiteral(resourceName: "male_unselected"), for: .normal)
        btnMale.setImage(#imageLiteral(resourceName: "male_selected"), for: .selected)
        btnMale.addTarget(self, action: #selector(maleButtonTapped), for: .touchUpInside)
        
        btnFemale = UIButton(frame: CGRect(x: screenWidth / 2 + 40, y: 220 * screenHeightFactor, width: 80, height: 80))
        btnFemale.setImage(#imageLiteral(resourceName: "female_unselected"), for: .normal)
        btnFemale.setImage(#imageLiteral(resourceName: "female_selected"), for: .selected)
        btnFemale.addTarget(self, action: #selector(femaleButtonTapped), for: .touchUpInside)
        view.addSubview(btnMale)
        view.addSubview(btnFemale)
        btnMale.isSelected = gender == "male" ? true : false
        btnFemale.isSelected = gender == "female" ? true : false
        
        if gender != "male" && gender != "female" {
            enableSaveButton(false)
        }
    }
    
    fileprivate func loadPassword() {
        btnSave.setTitle("Continue", for: .normal)
        enableSaveButton(false)
        btnForgot = UIButton(frame: CGRect(x: 0, y: screenHeight - 314 - 50 * screenHeightFactor, width: 120, height: 18))
        btnForgot.center.x = screenWidth / 2
        btnForgot.setTitle("Forgot Password", for: UIControlState())
        btnForgot.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 13)
        btnForgot.setTitleColor(UIColor._2499090(), for: .normal)
        btnForgot.addTarget(self, action: #selector(self.actionForgot(_:)), for: .touchUpInside)
        view.addSubview(btnForgot)
        
        textPswd = FAETextField(frame: CGRect(x: 15, y: 174, width: screenWidth - 30, height: 34))
        textPswd.placeholder = "Password"
        textPswd.fontSize = 25
        textPswd.isSecureTextEntry = true
        textPswd.becomeFirstResponder()
        view.addSubview(textPswd)
        textPswd.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        lblWrongPswd = FaeLabel(CGRect(x: 0, y: 272 * screenHeightFactor, width: screenWidth, height: 36), .center, .medium, 13, UIColor._2499090())
        lblWrongPswd.numberOfLines = 0
        lblWrongPswd.text = "That's not the Correct Password!\nPlease Check your Password!"
        view.addSubview(lblWrongPswd)
        lblWrongPswd.isHidden = true
        
        loadResetPassword()
    }
    
    fileprivate func loadChangeEmailPage() {
        btnSave.setTitle("Save", for: .normal)
        enableSaveButton(false)
        
        textNewEmail = FAETextField(frame: CGRect(x: 15, y: 177, width: screenWidth - 30, height: 30))
        textNewEmail.placeholder = "Email Address"
        textNewEmail.becomeFirstResponder()
        view.addSubview(textNewEmail)
        textNewEmail.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        lblWrongEmail = FaeLabel(CGRect(x: 0, y: 272 * screenHeightFactor, width: screenWidth, height: 36), .center, .medium, 13, UIColor._2499090())
        lblWrongEmail.numberOfLines = 0
        lblWrongEmail.text = "The email is already in Use!"
        view.addSubview(lblWrongEmail)
        lblWrongEmail.isHidden = true
    }
    
    @objc func actionBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func actionSave(_ sender: UIButton) {
        indicatorView.startAnimating()
        var keyValue = [String: String]()
        switch enterMode {
        case .name:
            fName = textFName.text
            lName = textLName.text
            keyValue["first_name"] = fName!
            keyValue["last_name"] = lName!
            postToURL("users/account", parameter: keyValue, authentication: Key.shared.headerAuthentication(), completion: { (status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully update name")
                    Key.shared.userFirstname = self.fName!
                    Key.shared.userLastname = self.lName!
                    self.delegate?.updateInfo(target: "name")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("Fail to update name")
                }
                self.indicatorView.stopAnimating()
            })
            break
        case .birth:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let date = dateFormatter.date(from: dateOfBirth!)
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date!)
            keyValue["birthday"] = dateString
            postToURL("users/account", parameter: keyValue, authentication: Key.shared.headerAuthentication(), completion: { (status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully update birthday")
                    Key.shared.userBirthday = dateString
                    self.delegate?.updateInfo(target: "birth")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("Fail to update birthday")
                }
                self.indicatorView.stopAnimating()
            })
            break
        case .gender:
            keyValue["gender"] = gender!
            postToURL("users/account", parameter: keyValue, authentication: Key.shared.headerAuthentication(), completion: { (status: Int, message: Any?) in
                if status / 100 == 2 {
                    print("Successfully update gender")
                    Key.shared.gender = self.gender!
                    self.delegate?.updateInfo(target: "gender")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("Fail to update gender")
                }
                self.indicatorView.stopAnimating()
            })
            break
        case .password:
            faeUser.whereKey("password", value: textPswd.text!)
            faeUser.verifyPassword({(status: Int, message: Any?) in
                if status / 100 == 2 {
                    let vc = SignInSupportNewPassViewController()
                    vc.enterMode = .oldPswd
                    vc.oldPassword = self.textPswd.text!
                    Key.shared.userPassword = self.textPswd.text!
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.lblWrongPswd.isHidden = false
                }
                self.indicatorView.stopAnimating()
            })
        case .newEmail:
            faeUser.whereKey("email", value: textNewEmail.text!)
            faeUser.checkEmailExistence {(status: Int, message: Any?) in
                if status / 100 == 2 {
                    let json = JSON(message!)
                    if json == JSON.null {
                        self.indicatorView.stopAnimating()
                        return
                    }
                    if json["existence"].boolValue {
                        self.lblWrongEmail.isHidden = false
                        self.indicatorView.stopAnimating()
                    } else {
                        self.faeUser.whereKey("email", value: self.textNewEmail.text!)
                        self.faeUser.updateEmail {(status: Int, message: Any?) in
                            if status / 100 == 2 {
                                let vc = VerifyCodeViewController()
                                vc.enterMode = .email
                                vc.enterEmailMode = .settings
                                vc.boolUpdateEmail = true
                                vc.strEmail = self.textNewEmail.text!
                                self.navigationController?.pushViewController(vc, animated: true)
                            } else {
                                print("[Update Email Fail] \(status) \(message!)")
                            }
                            self.indicatorView.stopAnimating()
                        }
                    }
                } else {
                    self.indicatorView.stopAnimating()
                   print("[Check Email Existence Fail] \(status) \(message!)")
                }
            }
            break
        default:
            break
        }
    }
    
    @objc func maleButtonTapped() {
        showGenderSelected("male")
    }
    
    @objc func femaleButtonTapped() {
        showGenderSelected("female")
    }
    
    func showGenderSelected(_ gender: String) {
        self.gender = gender
        let isMaleSelected = gender == "male"
        btnMale.isSelected = isMaleSelected
        btnFemale.isSelected = !isMaleSelected
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if enterMode == .name {
            print(textFName.text!)
            if textFName.text == "" || textLName.text == "" {
                enableSaveButton(false)
            } else {
                enableSaveButton(true)
            }
        } else if enterMode == .password {
            if (textPswd.text?.count)! < 8 {
                enableSaveButton(false)
            } else {
                enableSaveButton(true)
            }
        } else if enterMode == .newEmail {
            enableSaveButton(isValidEmail(textNewEmail.text!))
        }
    }
    
    @objc func actionForgot(_ sender: UIButton) {
        animationShowSelf()
    }
    
    //MARK: - FAENumberKeyboard delegate
    func keyboardButtonTapped(_ num: Int) {
        if num != -1 {
            if (dateOfBirth?.count)! < 10 {
                dateOfBirth = "\(dateOfBirth!)\(num)"
            }
            
            let numOfCharacters = dateOfBirth?.count
            if numOfCharacters == 2 || numOfCharacters == 5 {
                dateOfBirth = "\(dateOfBirth!)/"
            }
        } else {
            if (dateOfBirth?.count)! >= 0 {
                dateOfBirth = String(dateOfBirth!.dropLast())
                let numOfCharacters = dateOfBirth?.count
                if numOfCharacters == 2 || numOfCharacters == 5 {
                    dateOfBirth = String(dateOfBirth!.dropLast())
                }
            }
            imgExclamationMark.isHidden = true
        }
        validation()
        textBirth.text = dateOfBirth
    }
    
    func validation() {
        var boolIsValid = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let date = dateFormatter.date(from: dateOfBirth!)
        boolIsValid = date != nil && dateOfBirth!.count == 10
        
        if date == nil && dateOfBirth!.count == 10 {
            imgExclamationMark.isHidden = false
        }
        
        if boolIsValid {
            let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
            let currentYearInt = ((calendar as NSCalendar?)?.component(NSCalendar.Unit.year, from: date!))!
            
            boolIsValid = boolIsValid && currentYearInt > ((calendar as NSCalendar?)?.component(NSCalendar.Unit.year, from: Date()))! - 99 && currentYearInt < ((calendar as NSCalendar?)?.component(NSCalendar.Unit.year, from: Date()))!
            imgExclamationMark.isHidden = boolIsValid
        }
        
        if boolIsValid {
            boolIsValid = (date! as NSDate).earlierDate(Date()) == date!
        }
        
        enableSaveButton(boolIsValid)
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let range = testStr.range(of: emailRegEx, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func enableSaveButton(_ enable: Bool) {
        btnSave.isEnabled = enable
        if enable {
            btnSave.backgroundColor = UIColor._2499090()
        } else {
            btnSave.backgroundColor = UIColor._255160160()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
        
        btnSave.frame.origin.y = screenHeight - keyboardHeight - 17 - 50 * screenHeightFactor
        if enterMode == .password {
            btnForgot.frame.origin.y = screenHeight - keyboardHeight - 53 - 50 * screenHeightFactor
        } else if enterMode == .newEmail {
            lblWrongEmail.frame.origin.y = screenHeight - keyboardHeight - 53 - 50 * screenHeightFactor
        }
    }
    
    func createActivityIndicator() {
        indicatorView = UIActivityIndicatorView()
        indicatorView.activityIndicatorViewStyle = .whiteLarge
        indicatorView.center = view.center
        indicatorView.hidesWhenStopped = true
        indicatorView.color = UIColor._2499090()
        
        view.addSubview(indicatorView)
        view.bringSubview(toFront: indicatorView)
    }
}

// load choose reset password page
extension SetNameViewController {
    func loadResetPassword() {
        uiviewGrayBg = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        view.addSubview(uiviewGrayBg)
        uiviewGrayBg.backgroundColor = UIColor._107105105_a50()
        loadForgotPswd()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionCancel(_:)))
        uiviewGrayBg.addGestureRecognizer(tapGesture)
        uiviewGrayBg.isHidden = true
    }
    
    fileprivate func loadForgotPswd() {
        uiviewChooseMethod = UIView(frame: CGRect(x: 0, y: 200, w: 290, h: 262))
        uiviewChooseMethod.center.x = screenWidth / 2
        uiviewChooseMethod.backgroundColor = .white
        uiviewChooseMethod.layer.cornerRadius = 20
        uiviewGrayBg.addSubview(uiviewChooseMethod)
        
        lblChoose = UILabel(frame: CGRect(x: 0, y: 20, w: 290, h: 50))
        lblChoose.textAlignment = .center
        lblChoose.numberOfLines = 0
        lblChoose.text = "How do you want to \nReset your Password?"
        lblChoose.textColor = UIColor._898989()
        lblChoose.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        uiviewChooseMethod.addSubview(lblChoose)
        
        btnPhone = UIButton(frame: CGRect(x: 41, y: 90, w: 208, h: 50))
        btnPhone.setTitle("Use Phone", for: .normal)
        btnEmail = UIButton(frame: CGRect(x: 41, y: 155, w: 208, h: 50))
        btnEmail.setTitle("Use Email", for: .normal)
        
        var btnActions = [UIButton]()
        btnActions.append(btnPhone)
        btnActions.append(btnEmail)
        
        for i in 0..<btnActions.count {
            btnActions[i].tag = i
            btnActions[i].setTitleColor(UIColor._2499090(), for: .normal)
            btnActions[i].titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18 * screenHeightFactor)
            btnActions[i].addTarget(self, action: #selector(actionChooseMethod(_:)), for: .touchUpInside)
            btnActions[i].layer.borderWidth = 2
            btnActions[i].layer.borderColor = UIColor._2499090().cgColor
            btnActions[i].layer.cornerRadius = 26 * screenWidthFactor
            uiviewChooseMethod.addSubview(btnActions[i])
        }
        
        btnCancel = UIButton()
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.setTitleColor(UIColor._2499090(), for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18 * screenHeightFactor)
        btnCancel.addTarget(self, action: #selector(actionCancel(_:)), for: .touchUpInside)
        uiviewChooseMethod.addSubview(btnCancel)
        view.addConstraintsWithFormat("H:|-80-[v0]-80-|", options: [], views: btnCancel)
        view.addConstraintsWithFormat("V:[v0(25)]-\(15 * screenHeightFactor)-|", options: [], views: btnCancel)
    }
    
    @objc func actionCancel(_ sender: Any?) {
        animationHideSelf()
    }
    
    @objc func actionChooseMethod(_ sender: UIButton) {
        if sender.tag == 0 {  // use phone
            let vc = SignInPhoneViewController()
            vc.enterMode = .signInSupport
            vc.enterFrom = .settings
            navigationController?.pushViewController(vc, animated: true)
        } else {  // use email
            let vc = SignInEmailViewController()
            vc.enterMode = .signInSupport
            vc.enterFrom = .settings
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // animations
    func animationShowSelf() {
        uiviewGrayBg.isHidden = false
        uiviewGrayBg.alpha = 0
        uiviewChooseMethod.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewGrayBg.alpha = 1
            self.uiviewChooseMethod.alpha = 1
        }, completion: nil)
    }
    
    func animationHideSelf() {
        uiviewGrayBg.alpha = 1
        uiviewChooseMethod.alpha = 1
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.uiviewChooseMethod.alpha = 0
            self.uiviewGrayBg.alpha = 0
        }, completion: nil)
    }
    // animations end
}

