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
    var screenMinSize: CGFloat
    var screenHeight: CGFloat
    var screenWidth: CGFloat
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var horizontalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var verticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    required init(coder aDecoder: NSCoder)
    {
        let screenRect = UIScreen.mainScreen().bounds
        screenWidth = screenRect.size.width
        screenHeight = screenRect.size.height
        screenMinSize = min(screenHeight, screenWidth)
        
        super.init(coder: aDecoder)
    }
    
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
                    self.imageView.contentMode = .ScaleAspectFill
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                    self.imageView.image = self.resizedImageToFitScreen(image!)
                    self.view.layoutSubviews()
                })
            }
            else
            {
                NSLog("error fetching image")
            }
        }
    }
    
    func resizedImageToFitScreen(image: UIImage) -> UIImage
    {
        let oldImageHeight = image.size.height
        let oldImageWidth = image.size.width
        let heightScale = screenHeight / oldImageHeight
        let widthScale = screenWidth / oldImageWidth
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
