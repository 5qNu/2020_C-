
//
//  ViewController.swift
//  DeepLab-xcode
//
//  Created by Austin Potts on 1/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var displayView: UIImageView!
    
      var sourceImg: UIImage! {
           didSet {
               displayView.image = sourceImg
           }
       }
       
       override func viewDidLoad() {
           super.viewDidLoad()
           sourceImg = UIImage.init(named: "test.jpg")!
       }
       
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
    
       }
    
       @IBAction func handlePickerTap(_ sender: Any) {
           let imagePicker =  UIImagePickerController()
           imagePicker.delegate = self
           present(imagePicker, animated: true, completion: nil)
       }
       
       @IBAction func handleSegmentTap(_ sender: Any) {
           if let cgImg = sourceImg.segmentation(){
               displayView.image = UIImage(cgImage: cgImg)
           }
       }
       
       @IBAction func handelGrayTap(_ sender: Any) {
           if let cgImg = sourceImg.segmentation(){
               let filter = GraySegmentFilter()
               filter.inputImage = CIImage.init(cgImage: sourceImg.cgImage!)
               filter.maskImage = CIImage.init(cgImage: cgImg)
               let output = filter.value(forKey:kCIOutputImageKey) as! CIImage
               
               let ciContext = CIContext(options: nil)
               let cgImage = ciContext.createCGImage(output, from: output.extent)!
               displayView.image = UIImage(cgImage: cgImage)
           }
       }


}