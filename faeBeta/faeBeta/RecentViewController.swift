//
//  RecentViewController.swift
//  quickChat
//
//  Created by User on 6/6/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RecentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChooseUserDelegate, SwipeableCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var recents: [NSDictionary] = []
    var cellsCurrentlyEditing: NSMutableSet! = NSMutableSet()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.tableFooterView = UIView()
        navigationBarSet()
        loadRecents()
        addGestureRecognizer()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func navigationBarSet() {
        let centerView = UIView(frame: CGRect(x: 0,y: 0,width: 100,height: 30))
        let sortButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        sortButton.titleLabel?.text = ""
        sortButton.addTarget(self, action: #selector(RecentViewController.sortAlert), forControlEvents: .TouchUpInside)
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 249 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        titleLabel.text = "Social"
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont(name: "Avenir Next", size: 20)
        titleLabel.textColor = UIColor(red: 89 / 255, green: 89 / 255, blue: 89 / 255, alpha: 1.0)
        //        centerView.addSubview(titleLabel)
        //
        //
        //        var arrow = UIImageView(frame: CGRect(x: 47, y: 25, width: 10, height: 6))
        //        arrow.image = UIImage(named: "arrow")
        //        centerView.addSubview(arrow)
        //        centerView.addSubview(sortButton)
        self.navigationItem.titleView = titleLabel
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "locationPin"), style: .Plain, target: self, action: #selector(RecentViewController.navigationLeftItemTapped))
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(image: UIImage(named: "bellHollow"), style: .Plain, target: self, action: #selector(RecentViewController.navigationRightItemTapped)),UIBarButtonItem.init(image: UIImage(named: "cross"), style: .Plain, target: self, action: #selector(RecentViewController.crossTapped))]
        
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 86 , bottom: 0, right: 0)
    }
    
    func addGestureRecognizer()
    {
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RecentViewController.closeAllCell)))
    }
    
    //MARK:- tableView delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(cellsCurrentlyEditing.count == 0){
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            let recent = recents[indexPath.row]
            
            //create recent for both users
            
            restartRecentChat(recent)
            
            performSegueWithIdentifier("recentToChatSeg", sender: indexPath)
        }else{
            for indexP in cellsCurrentlyEditing {
                let cell = tableView.cellForRowAtIndexPath(indexP as! NSIndexPath) as! RecentTableViewCell
                cell.closeCell()
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //        let recent = recents[indexPath.row]
        //
        //        //remove recent form the array
        //
        //        recents.removeAtIndex(indexPath.row)
        //
        //        //delect recent from firebase
        //
        //        DeleteRecentItem(recent)
        //
        //        tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76
    }
    
    //MARK: action
    
    @IBAction func startNewChatBarButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("recentToChooseUserVC", sender: self)
    }
    
    //MARK : UItableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RecentTableViewCell
        cell.delegate = self
        let recent = recents[indexPath.row]
        
        cell.bindData(recent)
        if (self.cellsCurrentlyEditing.containsObject(indexPath)) {
            cell.openCell()
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "recentToChooseUserVC" {
            let vc = segue.destinationViewController as! ChooseUserViewController
            vc.delegate = self
        }
        if segue.identifier == "recentToChatSeg" {
            let indexPath = sender as! NSIndexPath
            let chatVC = segue.destinationViewController as! ChatViewController
            chatVC.hidesBottomBarWhenPushed = true
            
            
            let recent = recents[indexPath.row]
            
            chatVC.recent = recent
            chatVC.chatRoomId = recent["chatRoomId"] as? String
            let withUserUserId = recent["withUserUserId"] as! String
            // find user
            let whereClause = "objectId = '\(withUserUserId)'"
            
            let dataQuery = BackendlessDataQuery()
            dataQuery.whereClause = whereClause
            
            let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
            
            dataStore.find(dataQuery, response: { (users : BackendlessCollection!) in
                chatVC.withUser = users.data[0] as? BackendlessUser
                print("RecentViewController: withuser id: \(chatVC.withUser?.getProperty("device_id"))")
            }) { (fault : Fault!) in
                print("Error, couldn't retrive users: \(fault)")
            }
        }
        
    }
    
    func createChatroom(withUser: BackendlessUser) {
        
        let chatVC = ChatViewController()
        
        chatVC.hidesBottomBarWhenPushed = true
        // set chatVC recent to our recent.
        
        chatVC.withUser = withUser
        
        chatVC.chatRoomId = startChat(backendless.userService.currentUser, user2: withUser)
        
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    //MARK: load recents form firebase
    
    func loadRecents() {
        
        firebase.child("Recent").queryOrderedByChild("userId").queryEqualToValue(backendless.userService.currentUser.objectId).observeEventType(.Value) { (snapshot : FIRDataSnapshot) in
            self.recents.removeAll()
            
            if snapshot.exists() {
                let sorted = (snapshot.value!.allValues as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key : "date", ascending: false)])
                for recent in sorted {
                    self.recents.append(recent as! NSDictionary)
                    // add function to have offline access as well
                    firebase.child("Recent").queryOrderedByChild("chatRoomId").queryEqualToValue(recent["ChatRoomId"]).observeEventType(.Value, withBlock: { (snapshot : FIRDataSnapshot) in
                    })
                }
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: sortAlertView
    
    func sortAlert() {
        print("clicked")
        
        let grey = UIColor(red: 146 / 255, green: 146 / 255, blue: 146 / 255, alpha: 1.0)
        
        let meunMessage = NSMutableAttributedString(string: "Sort Chats By")
        
        meunMessage.addAttributes([NSFontAttributeName : UIFont(name: "Avenir Next", size: 18)!, NSForegroundColorAttributeName : grey], range: NSRange(location: 0, length: meunMessage.length))
        
        let optionMenu = UIAlertController(title: nil, message: "", preferredStyle: .ActionSheet)
        
        optionMenu.setValue(meunMessage, forKey: "attributedMessage")
        
        
        let time = UIAlertAction(title: "Time Received", style: .Default) { (aler : UIAlertAction!) in
            print("Take photo")
            
        }
        
        let unread = UIAlertAction(title: "Unread Messages", style: .Default) { (aler : UIAlertAction) in
            print("photo library")
        }
        
        let markers = UIAlertAction(title: "Markers", style: .Default) { (aler : UIAlertAction) in
            print("Share location")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (aler : UIAlertAction) in
            print("Cancel")
        }
        
        optionMenu.addAction(time)
        optionMenu.addAction(unread)
        optionMenu.addAction(markers)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func crossTapped() {
        performSegueWithIdentifier("recentToChooseUserVC", sender: self)
    }
    
    func navigationLeftItemTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func navigationRightItemTapped() {
        
    }
    
    func closeAllCell(recognizer:UITapGestureRecognizer){
        let point = recognizer.locationInView(tableView)
        if let indexPath = tableView.indexPathForRowAtPoint(point) {
            self.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }else{
            for indexP in cellsCurrentlyEditing {
                let cell = tableView.cellForRowAtIndexPath(indexP as! NSIndexPath) as! RecentTableViewCell
                cell.closeCell()
            }
        }
    }
    
    //MARK: - swipeable cell delegate
    
    func cellDidOpen(cell: UITableViewCell)
    {
        let currentEditingIndexPath = self.tableView.indexPathForCell(cell)
        if(currentEditingIndexPath != nil){
            self.cellsCurrentlyEditing.addObject(currentEditingIndexPath!)
        }
    }
    
    func cellDidClose(cell: UITableViewCell)
    {
        if(self.tableView.indexPathForCell(cell) != nil){
            self.cellsCurrentlyEditing.removeObject(self.tableView.indexPathForCell(cell)!)
        }
    }
    
    func deleteButtonTapped(cell: UITableViewCell) {
        let indexPath = tableView.indexPathForCell(cell)!
        let recent = recents[indexPath.row]
        
        //remove recent form the array
        
        recents.removeAtIndex(indexPath.row)
        
        //delect recent from firebase
        
        DeleteRecentItem(recent)
        
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesInRange: range)
        self.tableView.reloadSections(sections, withRowAnimation: .Automatic)
    }
}
