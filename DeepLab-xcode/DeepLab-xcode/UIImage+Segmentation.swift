//
//  UIImage+Segmentation.swift
//  DeepLab-xcode
//
//  Created by Austin Potts on 1/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import VideoToolbox

extension UIImage {
    
    public func segmentation() -> CGImage? {
        guard var cgImage = self.coarseSegmentation() else {
            return nil
        }
        let outputWidth:CGFloat = 500.0
        let outputSize = CGSize(width: outputWidth, height: outputWidth * (self.size.height / self.size.width))
        let resizeImg = UIImage(cgImage: cgImage).resize(size: outputSize)!
        let ciImg = CIImage(cgImage: resizeImg.cgImage!)
        let smoothFilter = SmoothFilter.init()
   