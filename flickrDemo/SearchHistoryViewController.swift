//
//  SearchHistoryViewController.swift
//  flickrDemo
//
//  Created by idan haviv on 7/3/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import UIKit

class SearchHistoryViewController: UITableViewController {

    var filteredSearchHistory = [String](){
        didSet{
            tableView.reloadData()
        }
    }
    
    var delegate: SearchHistoryDelegate?

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filteredSearchHistory.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("search history cell", forIndexPath: indexPath) as! SearchHistoryTableViewCell
        cell.cleanBeforeReuse()
        if (filteredSearchHistory.count > indexPath.row)
        {
            cell.label.text = filteredSearchHistory[indexPath.row]
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        delegate?.userSelectedSearchWithText(filteredSearchHistory[indexPath.row])
    }
}