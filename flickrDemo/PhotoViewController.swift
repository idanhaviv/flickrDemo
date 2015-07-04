//
//  PhotoViewController.swift
//  flickrDemo
//
//  Created by idan haviv on 7/4/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import UIKit
import Alamofire

class PhotoViewController: UIViewController {

    var photoDetails: Photo?
    let flickrManager = FlickrManager()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var horizontalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var verticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        navigationController?.navigationBar.hidden = false
        
        if let photoDetails = photoDetails
        {
            fetchPhoto(photoDetails)
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
        }
        else
        {
            NSLog("error: photo details are not set")
        }
    }
    
    func fetchPhoto(photoDetails: Photo)
    {
        let photoSize = photoSizeForScreenSize()
        let photoURL = flickrManager.urlForPhoto(photoDetails, size: photoSize).URLString
        Alamofire.request(.GET, photoURL).response { (request, response, data, error) in
            
            if (error == nil)
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var image = UIImage(data: data as! NSData)
                    
                    self.view.removeConstraints([self.verticalSpacingConstraint, self.horizontalSpacingConstraint])
                    self.imageView.contentMode = .ScaleAspectFit
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                    self.imageView.image = image
                    self.view.layoutSubviews()
                })
            }
            else
            {
                NSLog("error fetching image")
            }
        }
    }
    
    func photoSizeForScreenSize() -> NSString?
    {
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        let maxSize = max(screenHeight, screenWidth)
        
        if maxSize > 1024
        {
            return OFFlickrLargeSize
        }
        else if maxSize > 500
        {
            return nil
        }
        else if maxSize > 240
        {
            return OFFlickrSmallSize
        }
        else if maxSize > 100
        {
            return OFFlickrThumbnailSize
        }
        else
        {
            return OFFlickrSmallSquareSize
        }
    }
}
