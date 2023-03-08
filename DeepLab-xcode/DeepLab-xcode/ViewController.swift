
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
    