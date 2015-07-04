//
//  SearchPhotoCell.swift
//  flickrDemo
//
//  Created by idan haviv on 7/3/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import UIKit

class SearchPhotoCell: UITableViewCell {

    var photo: UIImage?{
        didSet {
            self.photoView.image = photo
            activityIndicator.stopAnimating()
            activityIndicator.hidden = true
        }
    }
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func cleanBeforeReuse()
    {
        self.photo = nil
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
}
