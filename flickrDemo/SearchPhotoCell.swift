//
//  SearchPhotoCell.swift
//  flickrDemo
//
//  Created by idan haviv on 7/3/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import UIKit

class SearchPhotoCell: UITableViewCell {

    @IBOutlet weak var photoView: UIImageView!
    
    func cleanBeforeReuse()
    {
        
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        self.photoView.bounds = self.contentView.bounds
//    }
}
