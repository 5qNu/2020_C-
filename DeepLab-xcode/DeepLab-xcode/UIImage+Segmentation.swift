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
        smoothFilter.inputImage = ciImg
 
        let outputImage = smoothFilter.outputImage!
        let ciContext = CIContext(options: nil)
        cgImage = ciContext.createCGImage(outputImage, from: ciImg.extent)!
        return cgImage
    }
    
    public func coarseSegmentation() -> CGImage? {
        let deeplab = DeepLabV3.init()
        //input size 513*513
        let pixBuf = self.pixelBuffer(width: 513, height: 513)
        
        guard let output = try? deeplab.prediction(image: pixBuf!) else {
            return nil
        }
        
        let shape = output.semanticPredictions
        let (d,w,h) = (Int(truncating: shape[0]), Int(truncating: shape[1]), Int(truncating: shape[2]))
        let pageSize = w*h
        var res:Array<Int> = []
        var pageIndexs:Array<Int> = []
        for i in 0..<d {
            pageIndexs.append(pageSize * i)
        }
 
        func argmax(arr:Array<Int>) -> Int{
            precondition(arr.count > 0)
            var maxValue = arr[0]
            var maxValueIndex = 0
            for i in 1..<arr.count {
                if arr[i] > maxValue {
                    maxValue = arr[i]
                    maxValueIndex = i
                }
            }
            return maxValueIndex
        }
        
        for i in 0..<w {
            for j in 0..<h {
                var itemArr:Array<Int> = []
                let pageOffset = i * w + j
                for k in 0..<d {
                    let padding = pageIndexs[k]
                    itemArr.append(Int(truncating: output.semanticPredictions[padding + pageOffset]))
                }
                /*
                types map  [
                    'background', 'aeroplane', 'bicycle', 'bird', 'boat', 'bottle', 'bus',
                    'car', 'cat', 'chair', 'cow', 'diningtable', 'dog', 'horse', 'motorbike',
                    'person', 'pottedplant', 'sheep', 'sofa', 'train', 'tv'
                    ]
                 */
                let type = argmax(arr: itemArr)
                res.append(type)
            }
        }
        
        let bytesPerComponent = MemoryLayout<UInt8>.size
        let bytesPerPixel = bytesPerComponent * 4
        let length = pageSize * bytesPerPixel
        var data = Data(count: length)
        data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) -> Void in
            var pointer = bytes
            /*
            This reserved only [cat,dog,person]
            */
            let reserve = [8,12,15]
            for pix in res{
                let v:UInt8 = reserve.contains(pix) ? 255 : 0
                for _ in 0...3 {
                    pointer.pointee = v
                    pointer += 1
                }
            }
        }
        let provider: CGDataProvider = CGDataProvider(data: data as CFData)!
        let cgimg = CGImage(
            width: w,
            height: h,
            bitsPerComponent: bytesPerComponent * 8,
            bitsPerPixel: bytesPerPixel * 8,
            bytesPerRow: bytesPerPixel * w,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: CGColorRenderingIntent.defaultIntent
            )
        return cgimg
    }
}

extension UIImage {

  public func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
    return pixelBuffer(width: width, height: height,
                       pixelFormatType: kCVPixelFormatType_32ARGB,
                       colorSpace: CGColorSpaceCreateDeviceRGB(),
                       alphaInfo: .noneSkipFirst)
  }
 
  func pixelBuffer(width: Int, height: 