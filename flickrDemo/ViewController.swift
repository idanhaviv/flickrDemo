//
//  ViewController.swift
//  flickrDemo
//
//  Created by idan haviv on 7/1/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    let flickrManager = FlickrManager()
    var photos = [[String : String]]()
    
    //flickr api assumes UTF-8 encoded strings
    override func viewDidLoad() {
        super.viewDidLoad()
        flickrManager.delegate = self
        flickrManager.searchRequest("spring")
    }
}

extension ViewController: UITableViewDataSource{
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if var cell = tableView.dequeueReusableCellWithIdentifier("photo cell", forIndexPath: indexPath) as? SearchPhotoCell
        {
            cell.cleanBeforeReuse()
            updateCell(cell, indexPath: indexPath, photo: photos[indexPath.row])
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return photos.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func updateCell(cell: SearchPhotoCell, indexPath: NSIndexPath, photo: [String : String])
    {
        let photoURL = flickrManager.urlForPhoto(photo)
        Alamofire.request(.GET, photoURL.URLString)
            .response { (request, response, data, error) in
                
                if (error == nil)
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        var image = UIImage(data: data as! NSData)
                        cell.photoView.image = image
                        cell.layoutIfNeeded()
                        cell.layoutSubviews()
                    })
                    
//                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                else
                {
                    NSLog("error fetching image")
                }
        }
    }
}


extension ViewController: UITableViewDelegate{
    
}

extension ViewController: UITextFieldDelegate{
    
}

extension ViewController: FlickrManagerDelegate{
    func modelHasUpdated(photos: [[String : String]]) {
        self.photos = photos
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
}