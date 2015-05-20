//
//  APIManager.swift
//  popcornTime
//
//  Created by Danylo Kostyshyn on 3/13/15.
//  Copyright (c) 2015 Danylo Kostyshyn. All rights reserved.
//

/*
http://ytspt.re/api/list.json?limit=30&order=desc&sort=seeds
http://ytspt.re/api/listimdb.json?imdb_id=tt2245084
http://ytspt.re/api/list.json?limit=30&keywords=terminator&order=desc&sort=seeds&set=1
http://www.yifysubtitles.com//subtitle-api/big-hero-6-yify-36523.zip

http://eztvapi.re/shows/1?limit=30&order=desc&sort=seeds
http://eztvapi.re/show/tt0898266
http://eztvapi.re/shows/1?limit=30&keywords=the+big+bang&order=desc&sort=seeds

http://ptp.haruhichan.com/list.php?
http://ptp.haruhichan.com/anime.php?id=912
*/

import Foundation

class APIManager {

    typealias APIManagerFailure = (error: NSError?) -> ()
    typealias APIManagerSuccessItems = (items: [AnyObject]?) -> ()
    typealias APIManagerSuccessItem = (item: [String: AnyObject]?) -> ()
    
    private let APIManagerMoviesEndPoint = "http://ytspt.re/api"
    private let APIManagerShowsEndPoint = "http://eztvapi.re"
    private let APIManagerResultsLimit = 30
    
    class func sharedManager() -> APIManager {
        struct Static { static let instance: APIManager = APIManager() }
        return Static.instance
    }
    
    private func data(url: NSURL, sucess: ((AnyObject?) -> ())?, failure: APIManagerFailure?) {
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {
            (data, response, error) -> Void in
            
            var serializationError: NSError?
            var JSONObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &serializationError)

            if let serializationError = serializationError {
                println("\(serializationError)")
                
                if let failure = failure {
                    failure(error: serializationError)
                }
            }
            
            if let sucess = sucess {
                sucess(JSONObject)
            }
            
        }).resume()
    }
    
    // MARK: Movies
    
    func topMovies(success: APIManagerSuccessItems?, failure: APIManagerFailure?) {
        var path = String(format: "list.json?limit=%d&order=desc&sort=seeds", APIManagerResultsLimit)
        var url = NSURL(string: APIManagerMoviesEndPoint.stringByAppendingPathComponent(path))
        
        data(url!, sucess: { (JSONObject) -> () in
            if let success = success {
                var dict = JSONObject as [String: AnyObject]
                success(items: dict["MovieList"] as [AnyObject]?)
            }
        }, failure: failure)
    }
    
    func movieInfo(imdbId: String, success: APIManagerSuccessItems?, failure: APIManagerFailure?) {
        var path = String(format: "listimdb.json?imdb_id=%@", imdbId)
        var url = NSURL(string: APIManagerMoviesEndPoint.stringByAppendingPathComponent(path))
        
        data(url!, sucess: { (JSONObject) -> () in
            if let success = success {
                var dict = JSONObject as [String: AnyObject]
                success(items: dict["MovieList"] as [AnyObject]?)
            }
        }, failure: failure)
    }
    
    func searchMovie(name: String, success: APIManagerSuccessItems?, failure: APIManagerFailure?) {
        var path = String(format: "list.json?limit=%lu&keywords=%@&order=desc&sort=seeds&set=1", APIManagerResultsLimit, name)
        var url = NSURL(string: APIManagerMoviesEndPoint.stringByAppendingPathComponent(path))
        
        data(url!, sucess: { (JSONObject) -> () in
            if let success = success {
                var dict = JSONObject as [String: AnyObject]
                success(items: dict["MovieList"] as [AnyObject]?)
            }
        }, failure: failure)
    }
    
    // MARK: Shows    
    
    func topShows(page: UInt, success: APIManagerSuccessItems?, failure: APIManagerFailure?) {
        var path = String(format: "shows/%lu?limit=%lu&order=desc&sort=seeds", (page + 1), APIManagerResultsLimit)
        var url = NSURL(string: APIManagerShowsEndPoint.stringByAppendingPathComponent(path))
        
        data(url!, sucess: { (JSONObject) -> () in
            if let success = success {
                success(items: JSONObject as [AnyObject]?)
            }
        }, failure: failure)
    }
    
    func showInfo(imdbId: String, success: APIManagerSuccessItem?, failure: APIManagerFailure?) {
        var path = String(format: "show/%@", imdbId)
        var url = NSURL(string: APIManagerShowsEndPoint.stringByAppendingPathComponent(path))
        
        data(url!, sucess: { (JSONObject) -> () in
            if let success = success {
                success(item: JSONObject as [String: AnyObject]?)
            }
        }, failure: failure)
    }
    
    func searchShow(name: String, success: APIManagerSuccessItems?, failure: APIManagerFailure?) {
        var path = String(format: "shows/1?limit=%lu&keywords=%@&sort=seeds", APIManagerResultsLimit, name)
        var url = NSURL(string: APIManagerShowsEndPoint.stringByAppendingPathComponent(path))
        
        data(url!, sucess: { (JSONObject) -> () in
            if let success = success {
                success(items: JSONObject as [AnyObject]?)
            }
        }, failure: failure)
    }
    
}