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
    //todo: when returning from search controller don't reload
    //todo: maybe show the table on top
    @IBOutlet weak var tableView: UITableView!
    var searchHistory = [String]()
    var filteredSearchHistory = [String](){
        didSet {
            searchHistoryTableViewController.filteredSearchHistory = filteredSearchHistory
            searchHistoryTableViewController.view.hidden = false
        }
    }
    let flickrManager = FlickrManager()
    var photos = [[String : String]]()
    var photosSearchController = UISearchController()
    let searchHistoryTableViewController: SearchHistoryViewController!
    
    required init(coder aDecoder: NSCoder) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        searchHistoryTableViewController = storyboard.instantiateViewControllerWithIdentifier("search history") as! SearchHistoryViewController
        
        super.init(coder: aDecoder)
    }
    
    //flickr api assumes UTF-8 encoded strings
    override func viewDidLoad() {
        super.viewDidLoad()
        flickrManager.delegate = self
        flickrManager.searchRequest("spring")
        searchHistoryTableViewController.view.hidden = true
        loadSearchView()
    }
    
    func filterContentForSearchText(searchText: String)
    {
        filteredSearchHistory = [String]() //clean previous filtered history
        filteredSearchHistory = searchHistory.filter({
            $0.rangeOfString(searchText) != nil
        })
    }
    
    func loadSearchView()
    {
        self.photosSearchController = ({
            // Two setups provided below:
            
            // Setup One: This setup present the results in the current view.
            let controller = UISearchController(searchResultsController: self.searchHistoryTableViewController)
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.delegate = self
            controller.searchBar.searchBarStyle = .Minimal
            controller.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controller.searchBar
            
            /*
            // Setup Two: Alternative - This presents the results in a sepearate tableView
            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let alternateController:AlternateTableViewController = storyBoard.instantiateViewControllerWithIdentifier("aTV") as! AlternateTableViewController
            let controller = UISearchController(searchResultsController: alternateController)
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            controller.searchResultsUpdater = alternateController
            controller.definesPresentationContext = false
            controller.searchBar.sizeToFit()
            self.countryTable.tableHeaderView = controller.searchBar
            */
            return controller
        })()
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
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
}

extension ViewController: FlickrManagerDelegate{
    func modelHasUpdated(photos: [[String : String]]) {
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
    
    func searchBarResultsListButtonClicked(searchBar: UISearchBar) {
        //todo
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchHistoryTableViewController.view.hidden = true
        searchHistory.append(searchBar.text)
        flickrManager.searchRequest(searchBar.text)
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

