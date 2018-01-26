//
//  PlacesListCell.swift
//  FaeContacts
//
//  Created by Wenjia on 7/15/17.
//  Copyright © 2017 Yue. All rights reserved.
//

import UIKit

class PlacesListCell: UITableViewCell {
    
    var imgPic: UIImageView!
    var lblPlaceName: UILabel!
    var lblAddress: UILabel!
    var bottomLine: UIView!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        selectionStyle = .none
        loadRecommendedCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValueForPlace(_ placeInfo: PlacePin) {
        lblPlaceName.text = placeInfo.name
        lblAddress.text = placeInfo.address1 + ", " + placeInfo.address2
        imgPic.backgroundColor = .white
        General.shared.downloadImageForView(place: placeInfo, url: placeInfo.imageURL, imgPic: imgPic)
    }
    
    fileprivate func loadRecommendedCellContent() {
        imgPic = UIImageView()
        imgPic.frame = CGRect(x: 12 * screenWidthFactor, y: 12, width: 48, height: 48)
        imgPic.contentMode = .scaleAspectFill
        imgPic.clipsToBounds = true
        addSubview(imgPic)
        
        lblPlaceName = UILabel()
        lblPlaceName.textAlignment = .left
        lblPlaceName.lineBreakMode = .byTruncatingTail
        lblPlaceName.textColor = UIColor._898989()
        lblPlaceName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addSubview(lblPlaceName)
        addConstraintsWithFormat("H:|-\(73*screenWidthFactor)-[v0]-\(20*screenWidthFactor)-|", options: [], views: lblPlaceName)
        
        lblAddress = UILabel()
        lblAddress.textAlignment = .left
        lblAddress.lineBreakMode = .byTruncatingTail
        lblAddress.textColor = UIColor._107107107()
        lblAddress.font = UIFont(name: "AvenirNext-Medium", size: 12)
        addSubview(lblAddress)
        addConstraintsWithFormat("H:|-\(73*screenWidthFactor)-[v0]-\(20*screenWidthFactor)-|", options: [], views: lblAddress)
        addConstraintsWithFormat("V:|-16-[v0(20)]-0-[v1(16)]", options: [], views: lblPlaceName, lblAddress)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor._200199204()
        addSubview(bottomLine)
        addConstraintsWithFormat("H:|-\(69*screenWidthFactor)-[v0]-0-|", options: [], views: bottomLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)
    }
}

class CategoryListCell: UITableViewCell {
    
    var imgPic: UIImageView!
    var lblCatName: UILabel!
    var bottomLine: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        selectionStyle = .none
        loadCellContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValueForCategory(_ cat: (key: String, value: Int)) {
        imgPic.image = UIImage(named: "place_result_\(cat.value)")
        lblCatName.text = cat.key
    }
    
    func loadCellContent() {
        imgPic = UIImageView()
        imgPic.frame = CGRect(x: 7 * screenWidthFactor, y: 7, width: 58, height: 58)
        imgPic.contentMode = .scaleAspectFill
        imgPic.clipsToBounds = true
        addSubview(imgPic)
        
        lblCatName = UILabel()
        lblCatName.textAlignment = .left
        lblCatName.lineBreakMode = .byTruncatingTail
        lblCatName.textColor = UIColor._898989()
        lblCatName.font = UIFont(name: "AvenirNext-Medium", size: 15)
        addSubview(lblCatName)
        addConstraintsWithFormat("H:|-\(73*screenWidthFactor)-[v0]-\(20*screenWidthFactor)-|", options: [], views: lblCatName)
        addConstraintsWithFormat("V:|-24-[v0]", options: [], views: lblCatName)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor._200199204()
        addSubview(bottomLine)
        addConstraintsWithFormat("H:|-\(69*screenWidthFactor)-[v0]-0-|", options: [], views: bottomLine)
        addConstraintsWithFormat("V:[v0(1)]-0-|", options: [], views: bottomLine)
    }
}
