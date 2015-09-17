//
//  ParseManager.swift
//  
//
//  Created by Andriy K. on 6/23/15.
//
//

import UIKit

class ParseShowData: NSObject {
    
    private var collection = [String : PFObject]()
    
    convenience init(episodesFromParse: [PFObject]) {
        self.init()
        for episode in episodesFromParse {
            let seasonIndex = episode.objectForKey(ParseManager.sharedInstance.seasonKey) as! Int
            let episodeIndex = episode.objectForKey(ParseManager.sharedInstance.episodeKey) as! Int
            let key = dictKey(seasonIndex, episode: episodeIndex)
            collection[key] = episode
        }
    }
    
    func isEpisodeWatched(season: Int, episode: Int) -> Bool {
        let key = dictKey(season, episode: episode)
        if let episode = collection[key] {
            if let isWatched = episode.objectForKey(ParseManager.sharedInstance.watchedKey) as? Bool {
                return isWatched
            }
        }
        return false
    }
    
    private func dictKey(season: Int, episode: Int) -> String {
        return "\(season)_\(episode)"
    }
    
}

class ParseManager: NSObject {
    
    static let sharedInstance = ParseManager()
    
    let showClassName = "Show"
    let episodeClassName = "Episode"
    let showIdKey = "showId"
    let userKey = "user"
    let titleKey = "title"
    let seasonKey = "season"
    let episodeKey = "episodeNumber"
    let showKey = "show"
    let watchedKey = "watched"
    
    private override init() {
    }
    
    // MARK: - Public API
    
    var user: PFUser? {
        return PFUser.currentUser()
    }
    
    func markEpisode(episodeInfo: Episode, basicInfo: BasicInfo) {
        if let user = user {
            let query = PFQuery(className:showClassName)
            query.whereKey(userKey, equalTo:user)
            query.whereKey(showIdKey, equalTo:basicInfo.identifier)
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                
                var show: PFObject
                
                if let object = objects?.first as PFObject? {
                    show = object
                } else {
                    show = PFObject(className: self.showClassName)
                    show.setObject(basicInfo.identifier, forKey: self.showIdKey)
                    if let title = basicInfo.title {
                        show.setObject(title, forKey: self.titleKey)
                    }
                    let relation = show.relationForKey(self.userKey)
                    relation.addObject(user)
                }
                
                show.saveInBackgroundWithBlock({ (success, error) -> Void in

                    let queryEpisode = PFQuery(className:self.episodeClassName)
                    queryEpisode.whereKey(self.seasonKey, equalTo:episodeInfo.seasonNumber)
                    queryEpisode.whereKey(self.episodeKey, equalTo:episodeInfo.episodeNumber)
                    queryEpisode.whereKey(self.showKey, equalTo: show)
                    
                    queryEpisode.findObjectsInBackgroundWithBlock { (episodes, episodeError) -> Void in

                        var episode: PFObject
                        
                        if let ep = episodes?.first as PFObject? {
                            episode = ep
                        } else {
                            let newEpisode = PFObject(className: self.episodeClassName)
                            let relationShow = newEpisode.relationForKey(self.showKey)
                            relationShow.addObject(show)
                            newEpisode.setObject(episodeInfo.seasonNumber, forKey: self.seasonKey)
                            newEpisode.setObject(episodeInfo.episodeNumber, forKey: self.episodeKey)
                            episode = newEpisode
                        }
                        episode.setObject(true, forKey: self.watchedKey)
                        
                        episode.saveInBackgroundWithBlock(nil)
                    }
                })
            }
        }
    }
    
    /// Mark  [Episode] as watched on Parse.
    func markEpisodes(episodesInfo: [Episode], basicInfo: BasicInfo, completionHandler: PFBooleanResultBlock?) {
        
        if episodesInfo.count == 0 {
            return
        }

        let episodeNumbers = episodesInfo.map(){ episode in
            return episode.episodeNumber
        }
        let seasonNumber = episodesInfo.first!.seasonNumber

        
        if let user = user {
            let query = PFQuery(className:showClassName)
            query.whereKey(userKey, equalTo:user)
            query.whereKey(showIdKey, equalTo:basicInfo.identifier)
            query.findObjectsInBackgroundWithBlock {
                (objects, error) -> Void in

                var show: PFObject

                if let object = objects?.first as PFObject? {
                    show = object
                } else {
                    show = PFObject(className: self.showClassName)
                    show.setObject(basicInfo.identifier, forKey: self.showIdKey)
                    if let title = basicInfo.title {
                        show.setObject(title, forKey: self.titleKey)
                    }
                    let relation = show.relationForKey(self.userKey)
                    relation.addObject(user)
                }

                show.saveInBackgroundWithBlock({ (success, error) -> Void in
                    let queryEpisode = PFQuery(className:self.episodeClassName)
                    queryEpisode.whereKey(self.seasonKey, equalTo: seasonNumber)
                    queryEpisode.whereKey(self.episodeKey, containedIn: episodeNumbers)
                    queryEpisode.whereKey(self.showKey, equalTo: show)
                    
                    queryEpisode.findObjectsInBackgroundWithBlock { (results, episodeError) -> Void in
                        
                        var marked = [UInt]()
                        var pfObjects = [PFObject]()
                        
                        if let parseEpisodes = results as [PFObject]? {
                            print("\(parseEpisodes.count): episodes already on Parse")
                            for parseEp in parseEpisodes {
                                parseEp.setObject(true, forKey: self.watchedKey)
                                if let parseEpNumber = parseEp.objectForKey(self.episodeKey) as? UInt {
                                    marked.append(parseEpNumber)
                                    pfObjects.append(parseEp)
                                    print("parse ep:\(parseEpNumber) marked")
                                }
                            }
                        }
            
                        
                        for ep in episodesInfo {
                            if marked.contains(ep.episodeNumber) == false {
                                let newEpisode = PFObject(className: self.episodeClassName)
                                let relationShow = newEpisode.relationForKey(self.showKey)
                                relationShow.addObject(show)
                                newEpisode.setObject(ep.seasonNumber, forKey: self.seasonKey)
                                newEpisode.setObject(ep.episodeNumber, forKey: self.episodeKey)
                                newEpisode.setObject(true, forKey: self.watchedKey)
                                marked.append(ep.episodeNumber)
                                pfObjects.append(newEpisode)
                                print("ep:\(ep.episodeNumber) marked")
                            }
                        }
                        
                        PFObject.saveAllInBackground(pfObjects, block: completionHandler)
                    }
                })
            }
        }
    }
    
    func parseEpisodesData(basicInfo: BasicInfo, handler: (ParseShowData) -> Void) {
        if let user = user {
            let query = PFQuery(className: showClassName)
            query.whereKey(userKey, equalTo: user)
            query.whereKey(showIdKey, equalTo:basicInfo.identifier)
            query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
                if let show = results?.first as PFObject? {
                    let queryEpisode = PFQuery(className: self.episodeClassName)
                    queryEpisode.whereKey(self.showKey, equalTo: show)
                    do {
                        let episodes = try queryEpisode.findObjects() as [PFObject]
                        let parserData = ParseShowData(episodesFromParse: episodes)
                        handler(parserData)
                    } catch let error as  NSError {
                        print(error)
                    }
                }
            })
        }
    }
    
}
