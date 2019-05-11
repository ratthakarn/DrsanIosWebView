//
//  TumblrProvider.swift
//
//  Created by Mark on 20/11/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation;
import SwiftyJSON;

class TumblrProvider: PhotosProvider {
    func getRequestUrl(params: [String], page: Int) -> String? {
        return String(format: "https://api.tumblr.com/v2/blog/%@.tumblr.com/posts?api_key=%@&type=photo&limit=%i&offset=%i", params[0], AppDelegate.tumblrAPI(), (page - 1) * 20, page * 20)
    }
    
    func parseRequest(params: [String], json: String) -> [Photo]? {
        let parseable = JSON.init(parseJSON: json)
        print("tumblr JSON: \(parseable)")
        
        var results = [Photo]()
        
        if let photos = parseable["response"]["posts"].array {
            for photoJSON in photos {
                let result = Photo(tumblrPhotoJSON: photoJSON)
               
                results.append(result)
            }
        }
        
        return results
    }
}
