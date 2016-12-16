//
//  CreatePinAddTagsTextView.swift
//  faeBeta
//
//  Created by YAYUAN SHI on 12/11/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

class CreatePinAddTagsTextView: CreatePinTextView, NSLayoutManagerDelegate {
    
    var tagNames =  [String]()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.layoutManager.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layoutManager.delegate = self

    }
//
//    func setup()
//    {
//        self.attributedText.
//    }
    
    func addLastInputTag()
    {
        var str = String(self.text.characters.filter() { $0 <= "~" })
        str = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let remain = self.attributedText.attributedSubstring(from: NSMakeRange(0, tagNames.count))
        self.attributedText = remain
        
        if str.characters.count > 0{
            appendNewTags(tagName: str)
        }

    }
    
    func appendNewTags(tagName: String){
        let attributtedString = self.attributedText.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString()
//        attributtedString.addAttributes([NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 20)!], range: NSMakeRange(0,attributtedString.length))

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 37))
        label.attributedText = NSAttributedString(string:tagName, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 20)!])
        label.numberOfLines = 1
        
        //calculate the size of the image
        label.sizeToFit()
        var size = label.frame.size
        label.frame = CGRect(x: 0, y: 0, width: size.width + 18, height: size.height + 8)
        label.textAlignment = .center
        size = label.frame.size
        
        //get a high quality image
        label.attributedText = NSAttributedString(string:tagName, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 48)!])
        label.sizeToFit()
        var size2 = label.frame.size
        label.frame = CGRect(x: 0, y: 0, width: size2.width + 48, height: size2.height + 22)
        label.layer.borderWidth = 4
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.cornerRadius = 24
        size2 = label.frame.size
        
        var image: UIImage? = nil
        UIGraphicsBeginImageContext(CGSize(width: size2.width + 35, height: size2.height))
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        if let screenShotImage = UIGraphicsGetImageFromCurrentImageContext(){
            image = screenShotImage
        }
        
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: -10, width: size.width + 13, height: size.height)
        
        let tagString = NSAttributedString(attachment: attachment)
        attributtedString.append(tagString)
        
        self.isScrollEnabled = false
        self.attributedText = attributtedString
        self.isScrollEnabled = true
        tagNames.append(tagName)
        
        self.font = UIFont(name: "AvenirNext-Regular", size: 20)
        self.textColor = UIColor.white
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 12
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var originalRect = super.caretRect(for: position)
        originalRect.size.height = self.font!.pointSize - self.font!.descender
        // "descender" is expressed as a negative value,
        // so to add its height you must subtract its value
        
        return originalRect
    }

}
