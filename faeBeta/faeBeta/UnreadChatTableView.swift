//
//  UnreadChatTableView.swift
//  faeBeta
//
//  Created by Yue on 8/9/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

//MARK: Show unread chat tableView
extension FaeMapViewController {
    
    func loadMapChat()
    {
        self.labelUnreadMessages.hidden = true
        NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(self.updateUnreadChatIndicator), userInfo: nil, repeats: true)
    }

    func updateUnreadChatIndicator(){
        getFromURL("sync", parameter: nil, authentication: headerAuthentication()) { (status, result) in
            if(status / 100 == 2){
                if let cacheRecent = result as? NSDictionary {
                    let totalUnread = (cacheRecent["chat"] as! NSNumber).intValue + (cacheRecent["chat_room"] as! NSNumber).intValue
                    if(totalUnread / 10 >= 1){
                        self.labelUnreadMessages.text = "\(totalUnread)"
                        self.labelUnreadMessages.frame.size.width = 23
                    }else{
                        self.labelUnreadMessages.text = "\(totalUnread)"
                        self.labelUnreadMessages.frame.size.width = 20
                    }
                    
                    self.labelUnreadMessages.hidden = totalUnread == 0
                    UIApplication.sharedApplication().applicationIconBadgeNumber = Int(totalUnread)
                }
            }
        }
    }
    
    func stopMapChat(){
        firebase.child("Recent").removeAllObservers()// reference to all chat room
    }
    
    func animationMapChatShow(sender: UIButton!) {
        // check if the user's logged in the backendless
        if(backendless.userService.currentUser != nil){
            self.presentViewController (UIStoryboard(name: "Chat", bundle: nil).instantiateInitialViewController()!, animated: true,completion: nil )
        }
    }

    func segueToChat(withUserId: NSNumber ){
        
    }
    
    func animationMapChatHide(sender: UIButton!) {
        UIView.animateWithDuration(0.25, animations: ({
            self.mapChatSubview.alpha = 0.0
            self.mapChatWindow.alpha = 0.0
        }))
    }
}
