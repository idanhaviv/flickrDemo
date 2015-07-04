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
    var screenMinSize: CGFloat?
    var screenHeight: CGFloat?
    var screenWidth: CGFloat?
    var portraitImage: UIImage?
    var landscapeImage: UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var horizontalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var verticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        navigationController?.navigationBar.hidden = false
        self.imageView.contentMode = .ScaleAspectFill
        
        let screenRect = UIScreen.mainScreen().bounds
        screenWidth = screenRect.size.width
        screenHeight = screenRect.size.height
        screenMinSize = min(screenHeight!, screenWidth!)
        
        setupImage()
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval)
    {
        navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        navigationController?.navigationBar.hidden = false
        
        let screenRect = UIScreen.mainScreen().bounds
        screenWidth = screenRect.size.height
        screenHeight = screenRect.size.width
        screenMinSize = min(screenHeight!, screenWidth!)
        
        setupImage()
    }
    
    func setupImage()
    {
        if let oldImage = imageView.image
        {
            UIView.animateWithDuration(0.7, animations: { () -> Void in
                self.imageView.alpha = 0
            })
        }
        
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
        if photoIsCached()
        {
            setCachedPhotoInImageView()
        }
        else
        {
            fetchPhotoFromFlickr(photoDetails)
        }
    }
    
    func photoIsCached() -> Bool
    {
        if (UIDevice.currentDevice().orientation == .Portrait)
        {
            return self.portraitImage != nil
        }
        else
        {
            return self.landscapeImage != nil
        }
    }
    
    func setCachedPhotoInImageView()
    {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
        
        if (UIDevice.currentDevice().orientation == .Portrait)
        {
            self.imageView.image = portraitImage
        }
        else
        {
            self.imageView.image = landscapeImage
        }
        
        self.fadeInImage()
        self.view.layoutSubviews()
    }
    
    func fetchPhotoFromFlickr(photoDetails: Photo)
    {
        let photoSize = photoSizeForScreenSize()
        let photoURL = flickrManager.urlForPhoto(photoDetails, size: photoSize).URLString
        Alamofire.request(.GET, photoURL).response { (request, response, data, error) in
            
            if (error == nil)
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var image = UIImage(data: data as! NSData)
                    if (self.verticalSpacingConstraint != nil && self.horizontalSpacingConstraint != nil)
                    {
                        self.view.removeConstraints([self.verticalSpacingConstraint, self.horizontalSpacingConstraint])
                    }
                    
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                    let img =  self.resizedImageToFitScreen(image!)
                    if !self.photoIsCached()
                    {
                        self.cacheImage(img)
                    }
                    self.imageView.image = img
                    self.fadeInImage()
                    self.view.layoutSubviews()
                })
            }
            else
            {
                NSLog("error fetching image")
            }
        }
    }
    
    func cacheImage(image: UIImage)
    {
        if (UIDevice.currentDevice().orientation == .Portrait)
        {
            self.portraitImage = image
        }
        else
        {
            self.landscapeImage = image
        }
    }
    
    func fadeInImage()
    {
        if self.imageView.alpha == 0
        {
            UIView.animateWithDuration(0.7, animations: { () -> Void in
                self.imageView.alpha = 1
            })
        }
    }
    
    func resizedImageToFitScreen(image: UIImage) -> UIImage
    {
        let oldImageHeight = image.size.height
        let oldImageWidth = image.size.width
        let heightScale = screenHeight! / oldImageHeight
        let widthScale = screenWidth! / oldImageWidth
        let scaleFactor = min(heightScale , widthScale)
        let newImageHeight = oldImageHeight * scaleFactor
        let newImageWidth = oldImageWidth * scaleFactor
        UIGraphicsBeginImageContext(CGSizeMake(newImageWidth, newImageHeight))
        image.drawInRect(CGRectMake(0, 0, newImageWidth, newImageHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage
    }
    
    func photoSizeForScreenSize() -> NSString?
    {
        if screenMinSize > 1024
        {
            return OFFlickrLargeSize
        }
        else if screenMinSize > 500
        {
            return nil
        }
        else if screenMinSize > 240
        {
            return OFFlickrSmallSize
        }
        else if screenMinSize > 100
        {
            return OFFlickrThumbnailSize
        }
        else
        {
            return OFFlickrSmallSquareSize
        }
    }
}
