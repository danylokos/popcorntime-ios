//
//  Show.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/19/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import Foundation

class Show: BasicInfo {
    var seasons = [Season]()

    func thumbnail(original: String) -> String {
        return original.stringByReplacingOccurrencesOfString("original", withString: "thumb",
            options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
    }
    
    required init(dictionary: NSDictionary) {
        super.init(dictionary: dictionary)
        
        identifier = dictionary["imdb_id"] as! String
        title = dictionary["title"] as? String
        year = dictionary["year"] as? String
        
        if let imagesDict = dictionary["images"] as? NSDictionary {
            images = [Image]()
            if let banner = imagesDict["banner"] as? String {
                let URL = NSURL(string: thumbnail(banner))
                let image = Image(URL: URL!, type: .Banner)
                images.append(image)
            }
            if let fanart = imagesDict["fanart"] as? String {
                let URL = NSURL(string: thumbnail(fanart))
                let image = Image(URL: URL!, type: .Fanart)
                images.append(image)
            }
            if let poster = imagesDict["poster"] as? String {
                let URL = NSURL(string: thumbnail(poster))
                let image = Image(URL: URL!, type: .Poster)
                images.append(image)
            }
            
            smallImage = images.filter({$0.type == ImageType.Poster}).first
            bigImage = images.filter({$0.type == ImageType.Fanart}).first
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func update(dictionary: NSDictionary) {
        synopsis = dictionary["synopsis"] as? String
        
        seasons.removeAll(keepCapacity: true)
        var allEpisodes = [Episode]()
        var allSeasonsNumbers = [UInt:Bool]()
        
        let episodesDicts = dictionary["episodes"] as! [NSDictionary]!
        for episodeDict in episodesDicts{

            var videos = [Video]()

            let torrents = episodeDict["torrents"] as! [String : NSDictionary]
            for torrent in torrents{
                let quality = torrent.0
                if quality == "0" {
                    continue
                }
                
                let url = torrent.1["url"] as! String
                
                let video = Video(name: nil, quality: quality, size: 0, duration: 0, subGroup: nil, magnetLink: url)
                videos.append(video)
            }
            
            videos = videos.sort({ (a, b) -> Bool in
                var aQuality: Int = 0
                NSScanner(string: a.quality!).scanInteger(&aQuality)

                var bQuality: Int = 0
                NSScanner(string: b.quality!).scanInteger(&bQuality)
                
                return aQuality < bQuality
            })

            let seasonNumber = (episodeDict["season"] as! UInt)
            if (allSeasonsNumbers[seasonNumber] == nil) {
                allSeasonsNumbers[seasonNumber] = true
            }
            
            let title = episodeDict["title"] as? String
            let episodeNumber = (episodeDict["episode"] as! UInt)

            let synopsis = episodeDict["overview"] as? String
            let episode = Episode(title: title, desc: synopsis, seasonNumber: seasonNumber, episodeNumber: episodeNumber, videos: videos)
            allEpisodes.append(episode)
        }
        
        var seasonsNumbers = Array(allSeasonsNumbers.keys)
        seasonsNumbers.sortInPlace({ (a, b) -> Bool in
            return a < b
        })
        
        for seasonNumber in seasonsNumbers {
            let seasonEpisodes = allEpisodes.filter({ (episode) -> Bool in
                return episode.seasonNumber == seasonNumber
            })
            
            if seasonEpisodes.count > 0{
                let season = Season(seasonNumber: seasonNumber, episodes: seasonEpisodes)
                seasons.append(season)
            }
        }
    }
}

extension Show: ContainsEpisodes {
    func episodeFor(seasonIndex seasonIndex: Int, episodeIndex: Int) -> Episode {
        let episode = seasons[seasonIndex].episodes[episodeIndex]
        return episode
    }
    
    func episodesFor(seasonIndex seasonIndex: Int) -> [Episode] {
        return seasons[seasonIndex].episodes
    }
}
