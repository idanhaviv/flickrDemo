//
//  ViewController.swift
//  flickrDemo
//
//  Created by idan haviv on 7/1/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let flickrManager = FlickrManager()
    
    //flickr api assumes UTF-8 encoded strings
    override func viewDidLoad() {
        super.viewDidLoad()
        flickrManager.searchRequest("spring")
    }
}


