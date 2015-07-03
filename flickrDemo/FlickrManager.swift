//
//  FlickrManager.swift
//  flickrDemo
//
//  Created by idan haviv on 7/3/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import Foundation

class FlickrManager: NSObject{
    
    //property for managing requests in process
    var runningRequests = Set<OFFlickrAPIRequest>()
    
    var context: OFFlickrAPIContext?
    
    struct FlickrKeys {
        static let flickrKey = "c754f58e4b5c7bd4c8885347222b3238"
        static let flickrSecret = "976b2adbefb1063c"
    }
    
    //flickr api assumes UTF-8 encoded strings
    override init()
    {
        context = OFFlickrAPIContext(APIKey: FlickrKeys.flickrKey, sharedSecret: FlickrKeys.flickrSecret)
        super.init()
    }
    
    func searchRequest(text: String)
    {
        var request = OFFlickrAPIRequest.init(APIContext: context)
        request.delegate = self
        removePreviousRequests()
        
        let requestGeneratedSuccessfully = request.callAPIMethodWithGET("flickr.photos.search", arguments: ["text" : text])
        if requestGeneratedSuccessfully
        {
            runningRequests.insert(request)
        }
        else
        {
            NSLog("error creating request: \(request)")
        }
    }
    
    func removePreviousRequests()
    {
        if !runningRequests.isEmpty
        {
            NSLog("removing......")
            runningRequests.removeAll(keepCapacity: true)
        }
    }
}

extension FlickrManager: OFFlickrAPIRequestDelegate{
    
    func flickrAPIRequest(inRequest: OFFlickrAPIRequest!, didCompleteWithResponse inResponseDictionary: [NSObject : AnyObject]!)
    {
        NSLog("request: \(inRequest) completed with response: \(inResponseDictionary)")
    }
    
    func flickrAPIRequest(inRequest: OFFlickrAPIRequest!, didFailWithError inError: NSError!)
    {
        NSLog("request: \(inRequest) completed with error: \(inError)")
    }
}