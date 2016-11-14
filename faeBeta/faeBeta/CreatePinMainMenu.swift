//
//  CreatePinMainMenu.swift
//  faeBeta
//
//  Created by Yue on 10/20/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension CreatePinViewController {
    func initialCGRectForButton(_ button: UIButton, x: CGFloat, y: CGFloat) {
        button.frame = CGRect(x: x, y: y, width: 0, height: 0)
    }
    
    func reCreateCGRectForButton(_ button: UIButton, x: CGFloat, y: CGFloat) {
        let width: CGFloat = 90/414 * screenWidth
        button.frame = CGRect(x: x, y: y, width: width, height: width)
    }
    
    func pinSelectionShowAnimation() {
        uiviewPinSelections.isHidden = false
        blurViewMap.isHidden = false
        blurViewMap.layer.opacity = 0.6
        
        // post-animated position of buttons for cool animation
        let buttonOriginX_1: CGFloat = 34/414 * screenWidth
        let buttonOriginX_2: CGFloat = 163/414 * screenWidth
        let buttonOriginX_3: CGFloat = 292/414 * screenWidth
        
        let buttonOriginY_1: CGFloat = 160/736 * screenHeight
        let buttonOriginY_2: CGFloat = 302/736 * screenHeight
        let buttonOriginY_3: CGFloat = 444/736 * screenHeight
        
        // post-animated position of labels for cool animation
        let labelDiff: CGFloat = 33/736 * screenHeight
        let labelTitleDiff: CGFloat = 66/736 * screenHeight
        
        UIView.animate(withDuration: 1.4, delay: 0, options: .curveEaseOut, animations: {
            self.blurViewMap.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.2, delay: 0.35, options: .transitionFlipFromBottom, animations: {
            self.buttonClosePinBlurView.alpha = 1.0
            self.buttonClosePinBlurView.frame = CGRect(x: 0, y: self.screenHeight-65, width: self.screenWidth, height: 65)
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.15, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.labelSubmitTitle.center.y -= labelTitleDiff
            self.labelSubmitTitle.alpha = 1.0
            self.reCreateCGRectForButton(self.buttonMedia, x: buttonOriginX_1, y: buttonOriginY_1)
            self.labelSubmitMedia.center.y += labelDiff
            self.labelSubmitMedia.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.25, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonChats, x: buttonOriginX_2, y: buttonOriginY_1)
            self.labelSubmitChats.center.y += labelDiff
            self.labelSubmitChats.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.35, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonComment, x: buttonOriginX_3, y: buttonOriginY_1)
            self.labelSubmitComment.center.y += labelDiff
            self.labelSubmitComment.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.25, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonEvent, x: buttonOriginX_1, y: buttonOriginY_2)
            self.labelSubmitEvent.center.y += labelDiff
            self.labelSubmitEvent.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.35, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonFaevor, x: buttonOriginX_2, y: buttonOriginY_2)
            self.labelSubmitFaevor.center.y += labelDiff
            self.labelSubmitFaevor.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.45, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonNow, x: buttonOriginX_3, y: buttonOriginY_2)
            self.labelSubmitNow.center.y += labelDiff
            self.labelSubmitNow.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.35, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonJoinMe, x: buttonOriginX_1, y: buttonOriginY_3)
            self.labelSubmitJoinMe.center.y += labelDiff
            self.labelSubmitJoinMe.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.45, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonSell, x: buttonOriginX_2, y: buttonOriginY_3)
            self.labelSubmitSell.center.y += labelDiff
            self.labelSubmitSell.alpha = 1.0
            }, completion: nil)
        UIView.animate(withDuration: 0.883, delay: 0.55, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.reCreateCGRectForButton(self.buttonLive, x: buttonOriginX_3, y: buttonOriginY_3)
            self.labelSubmitLive.center.y += labelDiff
            self.labelSubmitLive.alpha = 1.0
            }, completion: nil)
    }
}
