//
//  FacebookProvider.swift
//  Hackers
//
//  Created by Mark on 20/11/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation;
import SwiftyJSON;

class FacebookProvider: SocialProvider {
    func getRequestUrl(identifier: String, params: SocialRequestParams) -> String? {
        var param = ""
        if let pageToken = params.nextPageToken {
            var queryStringDictionary: [AnyHashable : Any] = [:]
            let urlComponents = pageToken.components(separatedBy: "&")
            
            for keyValuePair: String in urlComponents {
                let pairComponents = keyValuePair.components(separatedBy: "=")
                let key = pairComponents.first?.removingPercentEncoding
                let value = pairComponents.last?.removingPercentEncoding
                
                queryStringDictionary[key] = value
            }
            
            let pagingToken = queryStringDictionary["__paging_token"] as? String
            let limit = queryStringDictionary["limit"] as? String
            let until = queryStringDictionary["until"] as? String
            
            param = "&__paging_token=\(pagingToken ?? "")&limit=\(limit ?? "")&until=\(until ?? "")"
        }

        let query = String(format: "https://graph.facebook.com/v3.1/%@/posts/?access_token=%@&date_format=U&fields=comments.limit(0).summary(1),likes.limit(0).summary(1),from,picture,message,story,name,link,created_time,full_picture,source,type,attachments%@", identifier, AppDelegate.facebookToken(), param)
        
        return query
    }
    
    
    func parseRequest(parseable: JSON) -> ([SocialItem]?, String?) {
        var results = [SocialItem]()
        
        if let posts = parseable["data"].array {
            for post in posts {
                let result = SocialItem(facebookPost: post)
                results.append(result)
            }
        }
        
        let pageToken = parseable["paging"]["next"].string
                
        return (results, pageToken)
    }
}
