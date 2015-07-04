//
//  SearchHistoryTableViewCell.swift
//  flickrDemo
//
//  Created by idan haviv on 7/3/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import UIKit

class SearchHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        label.text = ""
    }
    
    func cleanBeforeReuse()
    {
        label.text = ""
    }

}
