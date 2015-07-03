//
//  ViewController.swift
//  flickrDemo
//
//  Created by idan haviv on 7/1/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var context: OFFlickrAPIContext?
    var request: OFFlickrAPIRequest?
    struct FlickrKeys {
        static let flickrKey = "c754f58e4b5c7bd4c8885347222b3238"
        static let flickrSecret = "976b2adbefb1063c"
    }
    
    //flickr api assumes UTF-8 encoded strings
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = OFFlickrAPIContext(APIKey: FlickrKeys.flickrKey, sharedSecret: FlickrKeys.flickrSecret)
        requestCall()
    }

    func requestCall()
    {
        request = OFFlickrAPIRequest.init(APIContext: context)
        request!.delegate = self
//        var response = request.callAPIMethodWithGET("flickr.photos.getRecent", arguments: ["per_page":"1"])
        var response = request!.callAPIMethodWithGET("flickr.photos.search", arguments: ["text" : "new york"])
    }


}

extension ViewController: OFFlickrAPIRequestDelegate{
    
    func flickrAPIRequest(inRequest: OFFlickrAPIRequest!, didCompleteWithResponse inResponseDictionary: [NSObject : AnyObject]!) {
        NSLog("asf")
    }
    
    func flickrAPIRequest(inRequest: OFFlickrAPIRequest!, didFailWithError inError: NSError!) {
        NSLog("asf")
    }
}
