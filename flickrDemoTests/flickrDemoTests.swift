//
//  flickrDemoTests.swift
//  flickrDemoTests
//
//  Created by idan haviv on 7/1/15.
//  Copyright (c) 2015 idan haviv. All rights reserved.
//

import UIKit
import XCTest
import Alamofire

class flickrDemoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //tests the creation of a Photo object from dictionary and parsing the url needed for fetching a photo from Flickr
    func testFlickrFetchPhotoURLConstruction() {
        let photoDetails = ["id" : "123", "owner" : "111G", "title" : "becky", "server" : "12", "farm" : "1", "secret" : "abcd1"]
        let photo = Photo(properties: photoDetails)
        let photoURL = FlickrManager().urlForPhoto(photo).URLString
        let expectedURL = "https://farm1.staticflickr.com/12/123_abcd1_t.jpg"
        XCTAssertEqual(photoURL, expectedURL, "url construction for fetching photo from flickr is not as expected")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
