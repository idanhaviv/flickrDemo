//
//  Photo.swift
//  flickrDemo
//
//  Created by idan haviv on 7/3/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import Foundation

class Photo {
    
    var id: String?
    var owner: String?
    var title: String?
    var serverID: String?
    var farmID: String?
    var secret: String?
    
    init(properties: [String : AnyObject])
    {
        id = properties["id"] as? String
        owner = properties["owner"] as? String
        title = properties["title"] as? String
        serverID = properties["server"] as? String
        farmID = properties["farm"] as? String
        secret = properties["secret"] as? String
    }
}