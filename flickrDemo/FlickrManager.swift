//
//  FlickrManager.swift
//  flickrDemo
//
//  Created by idan haviv on 7/3/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import Foundation

protocol FlickrManagerDelegate{
    func modelHasUpdated(photos: [Photo])
}

class FlickrManager: NSObject{
    //todo: handle flickr request errors
    
    //property for managing requests in process
    var runningRequests = Set<OFFlickrAPIRequest>()
    var results = [Photo]()
    var context: OFFlickrAPIContext
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
    
    func urlForPhoto(photo: Photo, size: NSString? = OFFlickrThumbnailSize) -> NSURL
    {
        return context.photoSourceURLFromPhotoDetails(photo, size: size)
    }
    
    //range argument should be in a batch of 30, e.g. 0-29, 30-59 etc.
    func searchRequest(text: String, range: Range<Int> = Range(start: 0, end: 29))
    {
        if !rangeInProperFormat(range)
        {
            NSLog("range is not in proper format: \(range)")
            return
        }
        
        NSLog("search text: \(text)")
        var request = OFFlickrAPIRequest.init(APIContext: context)
        request.delegate = self
        removePreviousRequests()
        let page = (range.endIndex + 1) / 30
        let requestGeneratedSuccessfully = request.callAPIMethodWithGET("flickr.photos.search", arguments: ["text" : text, "per_page" : "30", "page" : page])
        if requestGeneratedSuccessfully
        {
            runningRequests.insert(request)
        }
        else
        {
            NSLog("error creating request: \(request)")
        }
    }
    
    //returns true iff range contains 30 numbers and is a unit of 30's batch e.g. 0-29, 30-59 etc.
    func rangeInProperFormat(range: Range<Int>) -> Bool
    {
        return ((range.endIndex - range.startIndex + 1) % 30 == 0) && (((range.endIndex + 1) % 30) == 0)
    }
    
    func removePreviousRequests()
    {
        if !runningRequests.isEmpty
        {
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
    }
    
    func processResults(results: [NSObject : AnyObject]!)->[Photo]
    {
        let photoResults = convertResultsDictionaryToPhotoArray(results)
        let tempDictionary = results["photos"] as! [NSObject : AnyObject]
        let page = tempDictionary["page"] as! String
        //todo: maybe check for gaps in pages? e.g. we have results for pages 1,2 and received page 4
        self.results += photoResults
        return self.results
    }
    
    func convertResultsDictionaryToPhotoArray(results: [NSObject : AnyObject]!)->[Photo]
    {
        var tempResultsArray = [Photo]()
        let tempDictionary = results["photos"] as! [NSObject : AnyObject]
        let photos = tempDictionary["photo"] as! [[String : String]]
        for photoInfo in photos
        {
            let photo = Photo(properties: photoInfo)
            tempResultsArray.append(photo)
        }
        
        return tempResultsArray
    }
    
    func flickrAPIRequest(inRequest: OFFlickrAPIRequest!, didFailWithError inError: NSError!)
    {
        NSLog("request: \(inRequest) completed with error: \(inError)")
    }
}

extension OFFlickrAPIContext{
    
    func photoSourceURLFromPhotoDetails(photo: Photo, size: NSString?) -> NSURL
    {
        var photoDetails = photoDetailsDictionaryFromPhoto(photo)
        return photoSourceURLFromDictionary(photoDetails, size: size as? String)
    }
    
    func photoDetailsDictionaryFromPhoto(photo: Photo) -> [String : String]
    {
        var dictionary = ["id" : photo.id, "owner" : photo.owner, "title" : photo.title, "server" : photo.serverID,
            "farm" : photo.farmID, "secret" : photo.secret]
        return dictionary
    }
}