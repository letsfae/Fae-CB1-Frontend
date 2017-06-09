//
//  MBChatSpotsCell.swift
//  FaeMapBoard
//
//  Created by vicky on 4/12/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class MBChatSpotsCell: UITableViewCell {

    var uiviewCell: UIButton!
    var imgAvatar: UIImageView!
    var lblChatTitle: UILabel!
    var lblChatCont: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let separatorView = UIView(frame: CGRect(x: 89.5, y: 89, width: screenWidth - 89.5, height: 1))
        separatorView.backgroundColor = UIColor.faeAppLineBetweenCellGrayColor()
        self.addSubview(separatorView)
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadCellContent() {
        
        imgAvatar = UIImageView(frame: CGRect(x: 15, y: 15, width: 66, height:66))
        addSubview(imgAvatar)
        imgAvatar.layer.cornerRadius = 33
        imgAvatar.clipsToBounds = true
        imgAvatar.contentMode = .scaleAspectFill
        
        lblChatTitle = UILabel()
        addSubview(lblChatTitle)
        lblChatTitle.font = UIFont(name: "AvenirNext-Medium", size: 18)
        lblChatTitle.textColor = UIColor.faeAppInputTextGrayColor()
        addConstraintsWithFormat("H:|-95-[v0]-14-|", options: [], views: lblChatTitle)
        
        lblChatCont = UILabel()
        addSubview(lblChatCont)
        lblChatCont.font = UIFont(name: "AvenirNext-Medium", size: 13)
        lblChatCont.textColor = UIColor.faeAppTimeTextBlackColor()
        lblChatCont.lineBreakMode = .byTruncatingTail
        addConstraintsWithFormat("H:|-95-[v0]-14-|", options: [], views: lblChatCont)
        addConstraintsWithFormat("V:|-26-[v0(25)]-1-[v1(18)]", options: [], views: lblChatTitle, lblChatCont)
        
    }

}
