//
//  ViewController.swift
//  flickrDemo
//
//  Created by idan haviv on 7/1/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import UIKit

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
        if var cell = tableView.dequeueReusableCellWithIdentifier("photo cell", forIndexPath: indexPath) as? UITableViewCell
        {
            cleanCellBeforeReuse(cell)
            updateCell(cell, photo: photos[indexPath.row])
            
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
    
    func cleanCellBeforeReuse(cell: UITableViewCell)
    {
        
    }
    
    func updateCell(cell: UITableViewCell, photo: [String : String])
    {
        
    }
}


extension ViewController: UITableViewDelegate{
    
}

extension ViewController: UITextFieldDelegate{
    
}

extension ViewController: FlickrManagerDelegate{
    func modelHasUpdated(photos: [[String : String]]) {
        self.photos = photos
        tableView.reloadData()
    }
}