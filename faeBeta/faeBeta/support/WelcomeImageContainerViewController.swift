//
//  WelcomeImageContainerViewController.swift
//  faeBeta
//
//  Created by Huiyuan Ren on 16/8/17.
//  Copyright © 2016年 fae. All rights reserved.
//

import UIKit

class WelcomeImageContainerViewController: UIViewController {
    var index: Int!
    var containerView : WelcomeContentContainerFace!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerView = WelcomeContentContainerFace()
        self.view.insertSubview(containerView, at: 0)
        self.containerView.frame = self.view.bounds
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupContentContainer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.containerView.frame = self.view.bounds
    }
    
    func setupContentContainer() {
        let imageName = "Welcome_" + "\(index+1)"
        var title: String = ""
        var description: String = ""
        switch index {
        case 0:
            title = " "
            self.containerView.titleIcon.image = UIImage(named: "FaeMapLabelIcon")
            description = "Connecting People to Favorite \nPlaces and Communities."
            break
        case 1:
            title = "More of your City"
            description = "Discover Great Places based on \nsurrounding Points of Interests."
            break
        case 2:
            title = "Interact with New People"
            description = "Talk with Interesting People \nfrom Local Communities."
            break
        case 3:
            title = "Explore the World"
            description = "Browse and Collect New Places \nfor your next Big Vacation."
            break
        case 4:
            title = "Always Secure"
            description = "Our Security System Protects \nyour Privacy at All Times."
            break
        default:
            break
        }
        self.containerView.populateContentContainer(imageName, title: title, description: description)
    }
}
