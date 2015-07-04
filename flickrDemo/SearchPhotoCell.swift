//
//  SearchPhotoCell.swift
//  flickrDemo
//
//  Created by idan haviv on 7/3/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import UIKit

class SearchPhotoCell: UITableViewCell {

    @IBOutlet weak var photoView: UIImageView!{
        didSet {
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func cleanBeforeReuse()
    {
        self.photoView.image = nil
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
}
