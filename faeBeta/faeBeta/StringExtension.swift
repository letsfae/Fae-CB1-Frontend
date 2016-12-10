//
//  StringExtension.swift
//  faeBeta
//
//  Created by Yue on 11/2/16.
//  Copyright © 2016 fae. All rights reserved.
//

import Foundation

extension String {
    func formatFaeDate() -> String {
        // convert to NSDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let myDate = dateFormatter.date(from: self)
        
        if myDate != nil {
            dateFormatter.dateFormat = "MMMM dd, YYYY"
            let localTimeZone = NSTimeZone.local.abbreviation()
            let elapsed = Int(Date().timeIntervalSince(myDate!))
            print("DEBUG TIMEE")
            print(elapsed)
            if localTimeZone != nil {
                dateFormatter.timeZone = TimeZone(abbreviation: "\(localTimeZone!)")
                let normalFormat = dateFormatter.string(from: myDate!)
                dateFormatter.dateFormat = "EEEE, HH:mm"
                let dayFormat = dateFormatter.string(from: myDate!)
                // Greater than or equal to one day
                if elapsed >= 604800 {
                    return "\(normalFormat)"
                }
                else if elapsed >= 172800 {
                    return "\(dayFormat)"
                }
                else if elapsed >= 86400 {
                    return "Yesterday"
                }
                else if elapsed >= 7200 {
                    let hoursPast = Int(elapsed/3600)
                    return "\(hoursPast) hours ago"
                }
                else if elapsed >= 3600 {
                    return "1 hour ago"
                }
                else if elapsed >= 120 {
                    let minsPast = Int(elapsed/60)
                    return "\(minsPast) mins ago"
                }
                else if elapsed >= 60 {
                    return "1 min ago"
                }
                else {
                    return "Just Now"
                }
            }
        }
        // convert to required string
        return "Invalid Date"
    }
    
    func formatPinCommentsContent() -> NSMutableAttributedString {
        
        let colorFae = UIColor(red: 249/255, green: 90/255, blue: 90/255, alpha: 1.0)
        let regularColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1.0)
        
//        var content = "<a>@maplestory06</a> comment and like testing"
        var username = ""
        var endIndex = 0
        
        if let match = self.range(of: "(?<=<a>@)[^.]+(?=</a>)", options: .regularExpression) {
            username = "@\(self.substring(with: match))"
            endIndex = username.characters.count + 8
        }
        else {
            print("parse formatPinCommentsContent fails")
        }
        
        let index = self.index(self.startIndex, offsetBy: endIndex)
        let restContent = " \(self.substring(from: index))"
        
        let attrsUsername = [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 18.0)!, NSForegroundColorAttributeName: colorFae]
        let attrsRegular = [NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 18.0)!, NSForegroundColorAttributeName: regularColor]
        
        let usernameString = NSMutableAttributedString(string: username, attributes: attrsUsername)
        let regularString = NSMutableAttributedString(string: restContent, attributes: attrsRegular)
        
        usernameString.append(regularString)
        
        return usernameString
    }
    
    func stringByDeletingLastEmoji() -> String
    {
        var previous = self
        var finalString = ""
        
        
        if previous.characters.count > 0 && previous.characters.last != "]"{
            finalString = previous.substring(to: previous.characters.index(previous.endIndex, offsetBy: -1 ))
        }else if previous.characters.count > 0 && previous.characters.last == "]"{
            var i = 1
            var findEmoji = false
            while( i <= previous.characters.count){
                if previous.characters[previous.characters.index(previous.endIndex, offsetBy: -i )] == "[" {
                    let between = previous.substring(with:
                        previous.characters.index(previous.endIndex, offsetBy: -(i-1)) ..< previous.characters.index(previous.endIndex, offsetBy: -1 ))
                    if (StickerInfoStrcut.stickerDictionary["faeEmoji"]?.contains(between))!{
                        findEmoji = true
                        break
                    }
                }
                i += 1
            }
            
            if findEmoji{
                finalString = previous.substring(to: previous.characters.index(previous.endIndex, offsetBy: -i ))
            }else{
                finalString = previous.substring(to: previous.characters.index(previous.endIndex, offsetBy: -1 ))
            }
        }
        return finalString
    }
}
