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

    func thumbnail(_ original: String) -> String {
        return original.replacingOccurrences(of: "original", with: "thumb",
            options: NSString.CompareOptions.caseInsensitive, range: nil)
    }
    
    required init(dictionary: [AnyHashable: Any]) {
        super.init(dictionary: dictionary)
        
        identifier = dictionary["imdb_id"] as! String
        title = dictionary["title"] as? String
        year = dictionary["year"] as? String
        
        if let imagesDict = dictionary["images"] as? NSDictionary {
            images = [Image]()
            if let banner = imagesDict["banner"] as? String {
                let URL = Foundation.URL(string: thumbnail(banner))
                let image = Image(URL: URL!, type: .banner)
                images.append(image)
            }
            if let fanart = imagesDict["fanart"] as? String {
                let URL = Foundation.URL(string: thumbnail(fanart))
                let image = Image(URL: URL!, type: .fanart)
                images.append(image)
            }
            if let poster = imagesDict["poster"] as? String {
                let URL = Foundation.URL(string: thumbnail(poster))
                let image = Image(URL: URL!, type: .poster)
                images.append(image)
            }
            
            smallImage = images.filter({$0.type == ImageType.poster}).first
            bigImage = images.filter({$0.type == ImageType.fanart}).first
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func update(_ dictionary: [AnyHashable: Any]) {
        synopsis = dictionary["synopsis"] as? String
        
        seasons.removeAll(keepingCapacity: true)
        var allEpisodes = [Episode]()
        var allSeasonsNumbers = [UInt:Bool]()
        
        guard let episodesDicts = dictionary["episodes"] as? [[AnyHashable: Any]] else { return }
        for episodeDict in episodesDicts {

            var videos = [Video]()

            if let torrents = episodeDict["torrents"] as? [String : NSDictionary] {
                for torrent in torrents {
                    let quality = torrent.0
                    if quality == "0" {
                        continue
                    }
                    
                    let url = torrent.1["url"] as! String
                    
                    let video = Video(name: nil, quality: quality, size: 0, duration: 0, subGroup: nil, magnetLink: url)
                    videos.append(video)
                }
            }
            
            videos = videos.sorted(by: { (a, b) -> Bool in
                var aQuality: Int = 0
                Scanner(string: a.quality!).scanInt(&aQuality)

                var bQuality: Int = 0
                Scanner(string: b.quality!).scanInt(&bQuality)
                
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
        seasonsNumbers.sort(by: { (a, b) -> Bool in
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
    func episodeFor(seasonIndex: Int, episodeIndex: Int) -> Episode {
        let episode = seasons[seasonIndex].episodes[episodeIndex]
        return episode
    }
    
    func episodesFor(seasonIndex: Int) -> [Episode] {
        return seasons[seasonIndex].episodes
    }
}
