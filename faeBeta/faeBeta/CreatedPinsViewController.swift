//
//  CreatedPinsViewController.swift
//  faeBeta
//
//  Created by Shiqi Wei on 4/17/17.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit
import SwiftyJSON
import UIKit.UIGestureRecognizerSubclass
//import SDWebImage
//import RealmSwift

class CreatedPinsViewController: PinsViewController, UITableViewDataSource{

    // get the Created Pins
    func getPinsData() {
        let getCreatedPinsData = FaeMap()
        getCreatedPinsData.getCreatedPins() {(status: Int, message: Any?) in
            if status / 100 == 2 {
                print("Successfully get Created pins!")
                self.arrPinData.removeAll()
                let PinsOfCreatedPinsJSON = JSON(message!)
                if PinsOfCreatedPinsJSON.count > 0 {
                    for i in 0...(PinsOfCreatedPinsJSON.count-1) {
                        var dicCell = [String: AnyObject]()
                        if let time = PinsOfCreatedPinsJSON[i]["created_at"].string {
                            dicCell["created_at"] = time as AnyObject
                        }
                        if let pinId = PinsOfCreatedPinsJSON[i]["pin_id"].int{
                            dicCell["pin_id"] = pinId as AnyObject
                        }
                        if let type = PinsOfCreatedPinsJSON[i]["type"].string{
                            dicCell["type"] = type as AnyObject
                        }
                        let pinObject = PinsOfCreatedPinsJSON[i]["pin_object"]
                        if  pinObject != JSON.null{
                            //comment tab里面存的不叫description 叫content
                            if let content = pinObject["content"].string {
                                dicCell["content"] = content as AnyObject
                            }
                            //media tab里面存的不叫content 叫description
                            if let description = pinObject["description"].string {
                                dicCell["description"] = description as AnyObject
                            }
                            
                            if let liked_count = pinObject["liked_count"].int {
                                dicCell["liked_count"] = liked_count as AnyObject
                            }
                            
                            if let comment_count = pinObject["comment_count"].int {
                                dicCell["comment_count"] = comment_count as AnyObject?
                            }
                            
                            if let mediaImgArr = pinObject["file_ids"].array {
                                dicCell["file_ids"] = mediaImgArr as AnyObject?
                            }
                        }
                        self.arrPinData.append(dicCell)
                    }
                    /*有数据代表不是空表，要显示控件*/
                    self.hideOrShowTable(true)
                }
                else{
                    /*没有数据代表空表，要隐藏控件*/
                    self.hideOrShowTable(false)
                }
                // reload the table when get the data
                self.tblPinsData.reloadData()
            }
            else {
                print("Fail to get Created pins!")
            }
        }
    }
 
    override func loadtblPinsData(){
        super.loadtblPinsData()
        tblPinsData.register(CreatedPinsTableViewCell.self, forCellReuseIdentifier: "CreatedPinCell")
        tblPinsData.delegate = self
        tblPinsData.dataSource = self
        

        getPinsData()

        imgEmptyTbl.image = #imageLiteral(resourceName: "empty_savedpins_bg")
    }
    
    
    // Creat the search view when tap the fake searchbar
    override func searchBarTapDown(_ sender: UITapGestureRecognizer) {
        let searchVC = CollectionSearchViewController()
        searchVC.modalPresentationStyle = .overCurrentContext
        self.present(searchVC, animated: false, completion: nil)
        searchVC.tableTypeName = strTableTitle
        searchVC.dataArray = arrPinData
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrPinData.count
    }
    
    //Customize each cell in the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreatedPinCell", for: indexPath) as! CreatedPinsTableViewCell
        cell.setValueForCell(_: arrPinData[indexPath.section])
        // Hide the separator line
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.delegate = self
        cell.indexForCurrentCell = indexPath.section
        return cell
    }
    
    override func toDoItemRemoved(indexCell: Int, pinId: Int, pinType: String){
        let deleteMyPin = FaeMap()
        deleteMyPin.deletePin(type: pinType, pinId: pinId.description) {(status: Int, message: Any?) in
            if status / 100 == 2 {
                print("Successfully delete the pin!")
            }
        }
        self.arrPinData.remove(at: indexCell)
        let indexSet = NSMutableIndexSet()
        indexSet.add(indexCell)
        self.tblPinsData.performUpdate({
            self.tblPinsData.deleteSections(indexSet as IndexSet, with: UITableViewRowAnimation.top)
        }, completion: {
            self.tblPinsData.reloadData()
        })
        if(self.arrPinData.count == 0){
            hideOrShowTable(false)
        }
    }
    
    // PinTableViewCellDelegate protocol required function
    override func itemSwiped(indexCell: Int){
        let path : IndexPath = IndexPath(row: 0, section: indexCell)
        cellCurrSwiped = tblPinsData.cellForRow(at: path) as! CreatedPinsTableViewCell
        tblPinsData.addGestureRecognizer(gesturerecognizerTouch)
        gesturerecognizerTouch.cellInGivenId = cellCurrSwiped
    }
    
    override func toDoItemEdit(indexCell: Int, pinId: Int, pinType: String){
        
    }
    
    override func toDoItemShared(indexCell: Int, pinId: Int, pinType: String){
        
    }
    
    override func toDoItemVisible(indexCell: Int, pinId: Int, pinType: String){
        
    }
    
    override func toDoItemLocated(indexCell: Int, pinId: Int, pinType: String){
        
    }
    
}
