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
  
  init(episodesFromParse: [PFObject]?) {
    super.init()
    if let episodesFromParse = episodesFromParse {
      for episode in episodesFromParse {
        let seasonIndex = episode.objectForKey("season") as! Int
        let episodeIndex = episode.objectForKey("episodeNumber") as! Int
        let key = dictKey(seasonIndex, episode: episodeIndex)
        collection[key] = episode
      }
    }
  }
  
  func isEpisodeWatched(season: Int, episode: Int) -> Bool {
    let key = dictKey(season, episode: episode)
    if let episode = collection[key] {
      if let isWatched = episode.objectForKey("watched") as? Bool {
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
  
  private override init() {
    println(__FUNCTION__)
  }
  
  var user: PFUser? {
    return PFUser.currentUser()
  }
  
  func markEpisode(episodeInfo: Episode, basicInfo: BasicInfo) {
    if let user = user {
      var query = PFQuery(className:"Show")
      query.whereKey("user", equalTo:user)
      query.whereKey("showId", equalTo:basicInfo.identifier)
      query.findObjectsInBackgroundWithBlock {
        (objects: [AnyObject]?, error: NSError?) -> Void in
        
        var show: PFObject
        
        if let object = objects?.first as? PFObject {
          show = object
          println("show fetched from parse")
        } else {
          show = PFObject(className: "Show")
          show.setObject(basicInfo.identifier, forKey: "showId")
          if let title = basicInfo.title {
            show.setObject(title, forKey: "title")
          }
          let relation = show.relationForKey("user")
          relation.addObject(user)
          println("show not fetched, create new one")
        }
        
        show.saveInBackgroundWithBlock({ (success) -> Void in
          println("show saved: \(success)")
          let queryEpisode = PFQuery(className:"Episode")
          queryEpisode.whereKey("season", equalTo:episodeInfo.seasonNumber)
          queryEpisode.whereKey("episode", equalTo:episodeInfo.episodeNumber)
          queryEpisode.whereKey("show", equalTo: show)
          
          queryEpisode.findObjectsInBackgroundWithBlock {
            (episodes: [AnyObject]?, episodeError: NSError?) -> Void in
            
            var episode: PFObject
            
            if let ep = episodes?.first as? PFObject {
              episode = ep
            } else {
              let newEpisode = PFObject(className: "Episode")
              let relationShow = newEpisode.relationForKey("show")
              relationShow.addObject(show)
              newEpisode.setObject(episodeInfo.seasonNumber, forKey: "season")
              newEpisode.setObject(episodeInfo.episodeNumber, forKey: "episodeNumber")
              episode = newEpisode
            }
            episode.setObject(true, forKey: "watched")
            
            episode.saveInBackgroundWithBlock({ (success) -> Void in
              println("episode saved: \(success)")
            })
          }
        })
      }
    }
  }
  
  func parseEpisodesData(basicInfo: BasicInfo) -> ParseShowData {
    if let user = user {
      var query = PFQuery(className:"Show")
      query.whereKey("user", equalTo:user)
      query.whereKey("showId", equalTo:basicInfo.identifier)
      if let show = query.findObjects()?.first as? PFObject {
        let queryEpisode = PFQuery(className:"Episode")
        queryEpisode.whereKey("show", equalTo: show)
        if let episodes = queryEpisode.findObjects() as? [PFObject] {
          return ParseShowData(episodesFromParse: episodes)
        }
      }
    }
    return ParseShowData(episodesFromParse: nil)
  }
  
}
