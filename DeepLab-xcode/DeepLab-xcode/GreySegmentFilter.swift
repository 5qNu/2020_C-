
//
//  GreySegmentFilter.swift
//  DeepLab-xcode
//
//  Created by Austin Potts on 1/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreImage

class GraySegmentFilter : CIFilter {
    
    private let kernel: CIColorKernel
    var inputImage: CIImage?
    var maskImage: CIImage?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override init() {
        let kernelStr = """
            kernel vec4 gray(__sample source, __sample mask) {
                float maskValue = mask.r;
                float gray = dot(source.rgb, vec3(0.299, 0.587, 0.114));
                if(maskValue == 0.0){
                   return vec4(vec3(gray),1.0);