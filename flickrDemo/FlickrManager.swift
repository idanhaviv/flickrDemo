//
//  FlickrManager.swift
//  flickrDemo
//
//  Created by idan haviv on 7/3/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import Foundation

protocol FlickrManagerDelegate{
    func modelHasUpdated(photos: [[String : String]])
}

class FlickrManager: NSObject{
    
    //property for managing requests in process
    var runningRequests = Set<OFFlickrAPIRequest>()
    var results = [[String : String]]()
    var context: OFFlickrAPIContext?
    var delegate: FlickrManagerDelegate?
    
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
        results = processResults(inResponseDictionary)
        if let delegate = delegate
        {
            delegate.modelHasUpdated(results)
        }
        
        NSLog("request: \(inRequest) completed with response: \(inResponseDictionary)")
    }
    
    func processResults(results: [NSObject : AnyObject]!)->[[String : String]]
    {
        var tempResultsArray = [[String : String]]()
        let tempDictionary = results["photos"] as! [NSObject : AnyObject]
        let photos = tempDictionary["photo"] as! [[String : String]]
        for photoInfo in photos
        {
            tempResultsArray.append(photoInfo)
        }
        
        return tempResultsArray
    }
    
    func flickrAPIRequest(inRequest: OFFlickrAPIRequest!, didFailWithError inError: NSError!)
    {
        NSLog("request: \(inRequest) completed with error: \(inError)")
    }
}