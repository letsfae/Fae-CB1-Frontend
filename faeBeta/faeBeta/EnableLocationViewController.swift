//
//  EnableLocationViewController.swift
//  faeBeta
//
//  Created by blesssecret on 8/15/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class EnableLocationViewController: UIViewController {
    // MARK: - Interface 
    fileprivate var imageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    fileprivate var descriptionLabel: UILabel!
    fileprivate var infoLabel: UILabel!
    fileprivate var enableLocationButton: UIButton!
    fileprivate var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setup()
    {
        imageView = UIImageView(frame: CGRect(x: 68 * screenWidthFactor, y: 159 * screenHeightFactor, width: 291 * screenWidthFactor, height: 255 * screenHeightFactor))
        imageView.image = UIImage(named: "EnableLocationImage")
        self.view.addSubview(imageView)
        
        titleLabel = UILabel(frame: CGRect(x: 15,y: 469 * screenHeightFactor,width: screenWidth - 30,height: 27))
        titleLabel.attributedText = NSAttributedString(string:"Location Access", attributes: [NSForegroundColorAttributeName: UIColor.faeAppInputTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 20)!])
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        descriptionLabel = UILabel(frame: CGRect(x: 15,y: 514 * screenHeightFactor ,width: screenWidth - 30,height: 44))
        descriptionLabel.numberOfLines = 2
        descriptionLabel.attributedText = NSAttributedString(string:"Fae Map is a Social Map Platform,\nit needs to use Location to work.", attributes: [NSForegroundColorAttributeName: UIColor.faeAppDescriptionTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!])
        descriptionLabel.textAlignment = .center
        view.addSubview(descriptionLabel)
        
        infoLabel = UILabel(frame: CGRect(x: 15,y: 605 * screenHeightFactor,width: screenWidth - 30,height: 18))
        infoLabel.attributedText = NSAttributedString(string:"Fae’s Ninja System always protects your location.", attributes: [NSForegroundColorAttributeName: UIColor.faeAppDescriptionTextGrayColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 13)!])
        infoLabel.textAlignment = .center
        self.view.addSubview(infoLabel)
        
        enableLocationButton = UIButton(frame: CGRect(x: 0, y: screenHeight - 30 - 50 * screenHeightFactor, width: screenWidth - 114 * screenWidthFactor * screenWidthFactor, height: 50 * screenHeightFactor))
        enableLocationButton.center.x = screenWidth / 2
        enableLocationButton.setAttributedTitle(NSAttributedString(string: "Enable Location", attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 20)!]), for:UIControlState())
        enableLocationButton.layer.cornerRadius = 25 * screenHeightFactor
        enableLocationButton.backgroundColor = UIColor.faeAppRedColor()
        enableLocationButton.addTarget(self, action: #selector(EnableLocationViewController.enableLocationButtonTapped), for: .touchUpInside)
        self.view.addSubview(enableLocationButton)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkLocationEnabled), userInfo: nil, repeats: true)
    }
    
    func enableLocationButtonTapped()
    {
        let authstate = CLLocationManager.authorizationStatus()
        if(authstate != CLAuthorizationStatus.authorizedAlways){
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
    }
    
    func checkLocationEnabled()
    {
        let authstate = CLLocationManager.authorizationStatus()
        let notificationType = UIApplication.shared.currentUserNotificationSettings
        
        if(authstate == CLAuthorizationStatus.authorizedAlways){
            timer.invalidate()
            if (notificationType?.types == UIUserNotificationType() && self.navigationController != nil) {
                self.navigationController?.pushViewController(UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "EnableNotificationViewController") , animated: true)
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
