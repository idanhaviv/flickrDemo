//
//  Photo.swift
//  flickrDemo
//
//  Created by idan haviv on 7/3/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import Foundation

class Photo {
    
    var id: String
    var owner: String
    var title: String
    var serverID: String
    var farmID: String
    var secret: String
    
    init(properties: [String : AnyObject])
    {
        if let
        id = properties["id"] as? String,
        owner = properties["owner"] as? String,
        title = properties["title"] as? String,
        serverID = properties["server"] as? String,
        farmID = properties["farm"] as? String,
        secret = properties["secret"] as? String
        {
            self.id = id
            self.owner = owner
            self.title = title
            self.serverID = serverID
            self.farmID = farmID
            self.secret = secret
        }
        else
        {
            self.id = ""
            self.owner = ""
            self.title = ""
            self.serverID = ""
            self.farmID = ""
            self.secret = ""
            NSLog("error initializing Photo from dictionary: \(properties)")
        }
    }
}
