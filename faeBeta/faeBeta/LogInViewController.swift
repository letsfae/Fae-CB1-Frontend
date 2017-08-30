//
//  LogInViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import Foundation
import RealmSwift

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}

class LogInViewController: UIViewController {
    // MARK: - Interface
    fileprivate var imgIcon: UIImageView!
    fileprivate var btnSupport: UIButton!
    fileprivate var btnLogin: UIButton!
    fileprivate var lblLoginResult: UILabel!
    fileprivate var txtUsername: FAETextField!
    fileprivate var txtPassword: FAETextField!
    fileprivate var indicatorActivity: UIActivityIndicatorView!
    
    // Mark: - View did/will ..
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupInterface()
        addObservers()
        createActivityIndicator()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtUsername.becomeFirstResponder()
    }
    
    fileprivate func setupNavigationBar() {
        let uiviewNavBar = FaeNavBar(frame: .zero)
        view.addSubview(uiviewNavBar)
        uiviewNavBar.loadBtnConstraints()
        uiviewNavBar.leftBtn.setImage(#imageLiteral(resourceName: "NavigationBackNew"), for: .normal)
        uiviewNavBar.leftBtn.addTarget(self, action: #selector(self.navBarLeftButtonTapped), for: .touchUpInside)
        uiviewNavBar.rightBtn.isHidden = true
        uiviewNavBar.bottomLine.isHidden = true
    }
    
    fileprivate func setupInterface() {
        // icon
        imgIcon = UIImageView()
        imgIcon.frame = CGRect(x: screenWidth / 2 - 30, y: 70 * screenHeightFactor, width: 60 * screenHeightFactor, height: 60 * screenHeightFactor)
        imgIcon.image = #imageLiteral(resourceName: "Faevorite_icon")
        view.addSubview(imgIcon)
        
        // username textField
        txtUsername = FAETextField(frame: CGRect(x: 15, y: 174 * screenHeightFactor, width: screenWidth - 30, height: 34))
        txtUsername.placeholder = "Username/Email"
        txtUsername.adjustsFontSizeToFitWidth = true
        txtUsername.keyboardType = .emailAddress
        view.addSubview(txtUsername)
        
        // result label
        lblLoginResult = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 36))
        lblLoginResult.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblLoginResult.text = "Oops… Can’t find any Accounts\nwith this Username/Email!"
        lblLoginResult.textColor = UIColor._2499090()
        lblLoginResult.numberOfLines = 2
        lblLoginResult.center = view.center
        lblLoginResult.textAlignment = .center
        lblLoginResult.isHidden = true
        view.addSubview(lblLoginResult)
        
        // password textField
        txtPassword = FAETextField(frame: CGRect(x: 15, y: 243 * screenHeightFactor, width: screenWidth - 30, height: 34))
        txtPassword.placeholder = "Password"
        txtPassword.isSecureTextEntry = true
        txtPassword.delegate = self
        view.addSubview(txtPassword)
        
        // support button
        btnSupport = UIButton(frame: CGRect(x: (screenWidth - 150) / 2, y: screenHeight - 50 * screenHeightFactor - 71, width: 150, height: 22))
        btnSupport.center.x = screenWidth / 2
        var font = UIFont(name: "AvenirNext-Bold", size: 13)
        btnSupport.setAttributedTitle(NSAttributedString(string: "Sign In Support", attributes: [NSForegroundColorAttributeName: UIColor._2499090(), NSFontAttributeName: font!]), for: UIControlState())
        btnSupport.contentHorizontalAlignment = .center
        btnSupport.addTarget(self, action: #selector(LogInViewController.supportButtonTapped), for: .touchUpInside)
        view.insertSubview(btnSupport, at: 0)
        
        // log in button
        font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        btnLogin = UIButton(frame: CGRect(x: 0, y: screenHeight - 30 - 50 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        btnLogin.center.x = screenWidth / 2
        btnLogin.setAttributedTitle(NSAttributedString(string: "Log in", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font!]), for: UIControlState())
        btnLogin.layer.cornerRadius = 25 * screenHeightFactor
        btnLogin.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        btnLogin.backgroundColor = UIColor._255160160()
        btnLogin.isEnabled = false
        view.insertSubview(btnLogin, at: 0)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        txtUsername.addTarget(self, action: #selector(self.textfieldDidChange(_:)), for: .editingChanged)
        txtPassword.addTarget(self, action: #selector(self.textfieldDidChange(_:)), for: .editingChanged)
    }
    
    func createActivityIndicator() {
        indicatorActivity = UIActivityIndicatorView()
        indicatorActivity.activityIndicatorViewStyle = .whiteLarge
        indicatorActivity.center = view.center
        indicatorActivity.hidesWhenStopped = true
        indicatorActivity.color = UIColor._2499090()
        view.addSubview(indicatorActivity)
        view.bringSubview(toFront: indicatorActivity)
    }
    
    func loginButtonTapped() {
        indicatorActivity.startAnimating()
        view.endEditing(true)
        lblLoginResult.isHidden = true
        
        let user = FaeUser()
        if txtUsername.text!.range(of: "@") != nil {
            user.whereKey("email", value: txtUsername.text!)
        } else {
            user.whereKey("user_name", value: txtUsername.text!)
        }
        user.whereKey("password", value: txtPassword.text!)
        user.whereKey("device_id", value: headerDeviceID)
        user.whereKey("is_mobile", value: "true")
        user.logInBackground { (status: Int, message: Any?) in
            if status / 100 == 2 {
                self.navigationController?.popToRootViewController(animated: false)
                if let vcRoot = UIApplication.shared.keyWindow?.rootViewController {
                    if vcRoot is InitialPageController {
                        if let vc = vcRoot as? InitialPageController {
                            vc.goToFaeMap()
                        }
                    }
                }
            } else {
                // Vicky 07/12/2017  - 把使用error message的判断改为使用error code判断
                print("[LOGIN STATUS]: \(status), [LOGIN ERROR MESSAGE]: \(message!)")
                
                if status == 500 {
                    self.setLoginResult("Internet Error!")
                }
                
                let loginJSONInfo = JSON(message!)
                if let errorCode = loginJSONInfo["error_code"].string {
                    if errorCode == "404-3" {
                        self.setLoginResult("Oops… Can’t find any Accounts\nwith this Username/Email!")
                    } else if errorCode == "401-1" {
                        self.setLoginResult("That’s not the Correct Password!\nPlease Check your Password!")
                    } else {
                        self.setLoginResult("Internet Error!")
                    }
                }
                self.indicatorActivity.stopAnimating()
                // Vicky 07/12/2017 End
            }
        }
    }
    
    func setLoginResult(_ result: String) {
        lblLoginResult.text = result
        lblLoginResult.isHidden = false
    }
    
    func supportButtonTapped() {
        let vc = SignInSupportViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Navigation
    func navBarLeftButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - keyboard
    // This is just a temporary method to make the login button clickable
    func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let frameKeyboard: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.btnLogin.frame.origin.y += (screenHeight - frameKeyboard.height) - self.btnLogin.frame.origin.y - 50 * screenHeightFactor - 14
            self.btnSupport.frame.origin.y += (screenHeight - frameKeyboard.height) - self.btnSupport.frame.origin.y - 50 * screenHeightFactor - 14 - 22 - 19
            self.lblLoginResult.alpha = 0
        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.btnLogin.frame.origin.y = screenHeight - 30 - 50 * screenHeightFactor
            self.btnSupport.frame.origin.y = screenHeight - 50 * screenHeightFactor - 71
            self.lblLoginResult.alpha = 1
        })
    }
    // MARK: - helper
    func handleTap() {
        view.endEditing(true)
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - textfield
    func textfieldDidChange(_ textfield: UITextField) {
        if txtUsername.text!.characters.count > 0 && txtPassword.text?.characters.count >= 8 {
            btnLogin.backgroundColor = UIColor._2499090()
            btnLogin.isEnabled = true
        } else {
            btnLogin.backgroundColor = UIColor._255160160()
            btnLogin.isEnabled = false
        }
    }
}

extension LogInViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 16
    }
}
