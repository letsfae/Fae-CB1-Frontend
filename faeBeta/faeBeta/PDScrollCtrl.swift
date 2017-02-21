//
//  PDCVControl.swift
//  faeBeta
//
//  Created by Yue on 12/3/16.
//  Copyright © 2016 fae. All rights reserved.
//

import UIKit

extension PinDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableCommentsForPin {
            if touchToReplyTimer != nil {
                touchToReplyTimer.invalidate()
            }
//            print("[scrollViewDidScroll] offset: \(scrollView.contentOffset.y)")
            if tableCommentsForPin.contentOffset.y >= 227 {
                if self.controlBoard != nil {
                    self.controlBoard.isHidden = false
                }
            }
            if tableCommentsForPin.contentOffset.y < 227 {
                if self.controlBoard != nil {
                    self.controlBoard.isHidden = true
                }
            }
        }
        // DO NOT DELETE CODES BELOW !!!
//        if scrollView == scrollViewMedia {
//            print("[scrollViewDidScroll] offset: \(scrollView.contentOffset.x)")
//            if self.lastContentOffset < scrollView.contentOffset.x && scrollView.contentOffset.x > 0 {
//                UIView.animate(withDuration: 0.1, animations: {
//                    self.scrollViewMedia.frame.origin.x = 0
//                    self.scrollViewMedia.frame.size.width = screenWidth
//                })
//            }
//            // self.lastContentOffset > scrollView.contentOffset.x && self.lastContentOffset < (scrollView.contentSize.width - scrollView.frame.width) &&
//            else if scrollView.contentOffset.x <= 0 {
//                UIView.animate(withDuration: 0.1, animations: {
//                    if self.mediaMode == .small {
//                        self.scrollViewMedia.frame.origin.x = 15
//                        self.scrollViewMedia.frame.size.width = screenWidth - 15
//                    }
//                    else {
//                        self.scrollViewMedia.frame.origin.x = 27
//                        self.scrollViewMedia.frame.size.width = screenWidth - 27
//                    }
//                })
//            }
//            self.lastContentOffset = scrollView.contentOffset.x
//        }
    }
}
