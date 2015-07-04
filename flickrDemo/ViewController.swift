//
//  ViewController.swift
//  flickrDemo
//
//  Created by idan haviv on 7/1/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import UIKit
import Alamofire

protocol SearchHistoryDelegate{
    func userSelectedSearchWithText(text: String)
}

class ViewController: UIViewController {
    //todo: test the parsing of photo from the dictionary, and the construction of the url
    //todo: fit image size on rotation
    @IBOutlet weak var tableView: UITableView!
    var searchHistory = [String](){
        didSet {
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
            {
                appDelegate.searchHistory = searchHistory
            }
        }
    }
    
    var filteredSearchHistory = [String]()
    let flickrManager = FlickrManager()
    var photos = [Photo]()
    var photosSearchController = UISearchController()
    let searchHistoryTableViewController: SearchHistoryViewController!
    var lastSearchText: String?
    var selectedPhotoData: Photo?
    
    var imagesCache = NSCache() //keys: photo id values: UIImage
    
    required init(coder aDecoder: NSCoder)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        searchHistoryTableViewController = storyboard.instantiateViewControllerWithIdentifier("search history") as! SearchHistoryViewController
        
        super.init(coder: aDecoder)
        searchHistoryTableViewController.delegate = self
    }
    
    //flickr api assumes UTF-8 encoded strings
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flickrManager.delegate = self
        searchHistoryTableViewController.view.hidden = true
        self.photosSearchController = loadSearchViewController()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        navigationController?.navigationBar.hidden = true
    }
    
    func filterContentForSearchText(searchText: String)
    {
        filteredSearchHistory = [String]() //clean previous filtered history
        filteredSearchHistory = searchHistory.filter({
            $0.rangeOfString(searchText) != nil
        })
        updateSearchHistory(filteredSearchHistory)
    }
    
    func updateSearchHistory(filteredHistory: [String])
    {
        searchHistoryTableViewController.filteredSearchHistory = filteredSearchHistory
        searchHistoryTableViewController.view.hidden = false
    }
    
    func loadSearchViewController() -> UISearchController
    {
        let controller = UISearchController(searchResultsController: self.searchHistoryTableViewController)
        controller.searchResultsUpdater = self
        controller.hidesNavigationBarDuringPresentation = false
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.delegate = self
        controller.searchBar.searchBarStyle = .Minimal
        controller.searchBar.sizeToFit()
        self.tableView.tableHeaderView = controller.searchBar

        return controller
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let photoVC = segue.destinationViewController as? PhotoViewController
        {
            photoVC.photoDetails = selectedPhotoData
        }
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
    
    func updateCell(cell: SearchPhotoCell, indexPath: NSIndexPath, photo: Photo)
    {
        if let cachedImage = imagesCache.objectForKey(photo.id) as? UIImage
        {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.photo = cachedImage
                cell.layoutIfNeeded()
                cell.layoutSubviews()
            })
            
            return
        }
        
        //image is not cached
        fetchAndCacheImage(photo, cell: cell)
    }
    
    func fetchAndCacheImage(photo: Photo, cell: SearchPhotoCell)
    {
        let photoURL = flickrManager.urlForPhoto(photo)
        Alamofire.request(.GET, photoURL.URLString)
            .response { (request, response, data, error) in
                
                if (error == nil)
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        var image = UIImage(data: data as! NSData)
                        
                        cell.photo = image
                        cell.layoutIfNeeded()
                        cell.layoutSubviews()
                    
                        self.imagesCache.setObject(image!, forKey: photo.id)
                    })
                }
                else
                {
                    NSLog("error fetching image")
                }
        }
    }
}

extension ViewController: UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        selectedPhotoData = photos[indexPath.row]
        performSegueWithIdentifier("show photo segue", sender: self)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //fetch more photos when only 5 more to load
        if indexPath.row >= photos.count - 6, let lastSearchText = lastSearchText
        {
            flickrManager.searchRequest(lastSearchText, range: Range(start: photos.count, end: photos.count + 29))
        }
    }
}

extension ViewController: FlickrManagerDelegate{
    
    func modelHasUpdated(photos: [Photo]) {
        self.photos = photos
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
}

extension ViewController: UISearchBarDelegate{
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        filteredSearchHistory = [String]()
        searchHistoryTableViewController.view.hidden = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: true)
        
        if let text = searchBar.text where count(text) > 0
        {
            self.lastSearchText = text
            
            if !contains(searchHistory, text)
            {
                searchHistory.append(text)
            }
            
            flickrManager.searchRequest(text)
        }
        photosSearchController.active = false
    }
}

extension ViewController: UISearchResultsUpdating
{
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        searchHistoryTableViewController.filteredSearchHistory = filteredSearchHistory
        searchHistoryTableViewController.view.hidden = false
    }
}

extension ViewController: SearchHistoryDelegate
{
    func userSelectedSearchWithText(text: String)
    {
        flickrManager.searchRequest(text)
        searchHistoryTableViewController.view.hidden = true
    }
}

