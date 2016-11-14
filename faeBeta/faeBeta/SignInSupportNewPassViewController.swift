//
//  SignInSupportNewPassViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
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
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SignInSupportNewPassViewController: RegisterBaseViewController {
    
    
    // MARK: - Variables
    
    var passwordTableViewCell: RegisterTextfieldTableViewCell!
    var password: String?
    var faeUser: FaeUser!
    var email: String?
    var code: String?
    
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        createBottomView(getInfoView())
        createTableView(59 + 135 * screenHeightFactor)
        continueButton.setTitle("Update", for: UIControlState())

        registerCell()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "NavigationBackNew"), style: UIBarButtonItemStyle.plain, target: self, action:#selector(self.backButtonPressed))

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordTableViewCell.makeFirstResponder()
    }
    
    // MARK: - Functions
    
    override func backButtonPressed() {
        view.endEditing(true)
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func continueButtonPressed() {
        view.endEditing(true)
        updatePasswordInUser()
    }
    
    func jumpToRegisterInfo() {
        let vc = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(withIdentifier: "RegisterInfoViewController") as! RegisterInfoViewController
        vc.faeUser = faeUser
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func getInfoView() -> UIView {
        
        let infoView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 85 * screenHeightFactor))
        
        let imageView = UIImageView(frame: CGRect(x: view.frame.size.width/2.0 - 160 * screenWidthFactor, y: 0, width: 320 * screenWidthFactor , height: 85 * screenHeightFactor))
        imageView.image = UIImage(named: "InfoPassword")
        
        infoView.addSubview(imageView)
        
        return infoView
    }
    
    
    func validation() {
        var isValid = false
        
        isValid = password != nil && password?.characters.count > 7
        
        enableContinueButton(isValid)
    }
    
    func updatePasswordInUser() {
        shouldShowActivityIndicator(true)
        let param = ["email":email!,
                     "code":code!,
                     "password":password!]
        postToURL("/reset_login/password", parameter: param as [String : AnyObject]?, authentication: headerAuthentication()) { (status:Int, message: Any?) in
            self.shouldShowActivityIndicator(false)
            if(status / 100 == 2){
                _ = self.navigationController?.popToRootViewController(animated: true)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "resetPasswordSucceed"), object: nil)
            }
        }
    }
    
    func registerCell() {
        
        tableView.register(UINib(nibName: "TitleTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleTableViewCellIdentifier")
        tableView.register(UINib(nibName: "SubTitleTableViewCell", bundle: nil), forCellReuseIdentifier: "SubTitleTableViewCellIdentifier")
        tableView.register(UINib(nibName: "RegisterTextfieldTableViewCell", bundle: nil), forCellReuseIdentifier: "RegisterTextfieldTableViewCellIdentifier")
        
    }
    
    // MARK: - Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SignInSupportNewPassViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCellIdentifier") as! TitleTableViewCell
            cell.setTitleLabelText("Protect your Account \n with a Strong Password!")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubTitleTableViewCellIdentifier") as! SubTitleTableViewCell
            cell.setSubTitleLabelText("Must be at least 8 characters!")
            return cell
        case 2:
            if passwordTableViewCell == nil {
                passwordTableViewCell = tableView.dequeueReusableCell(withIdentifier: "RegisterTextfieldTableViewCellIdentifier") as! RegisterTextfieldTableViewCell
                
                passwordTableViewCell.setPlaceholderLabelText("New Password",indexPath: indexPath)
                passwordTableViewCell.setRightPlaceHolderDisplay(true)
                passwordTableViewCell.delegate = self
                passwordTableViewCell.setCharacterLimit(16)
            }
            return passwordTableViewCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTableViewCellIdentifier") as! TitleTableViewCell
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 59
        case 1:
            return 60 * screenHeightFactor
        case 2:
            return 75 * screenHeightFactor
        default:
            return 0
        }
    }
}

extension SignInSupportNewPassViewController: RegisterTextfieldProtocol {
    
    func textFieldDidBeginEditing(_ indexPath: IndexPath) {
        activeIndexPath = indexPath
    }
    
    func textFieldShouldReturn(_ indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            passwordTableViewCell.endAsResponder()
            break
        default: break
        }
    }
    
    func textFieldDidChange(_ text: String, indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            password = text
            passwordTableViewCell.updateTextColorAccordingToPassword(text)
            break
        default: break
        }
        validation()
    }
}

