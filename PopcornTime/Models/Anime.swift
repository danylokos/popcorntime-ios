//
//  Anime.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/19/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import Foundation

class Anime: BasicInfo {
    var seasons = [Season]()

    required init(dictionary: NSDictionary) {
        super.init(dictionary: dictionary)
        
        let id = dictionary["id"] as! Int
        identifier = "\(id)"
        title = dictionary["name"] as? String
        year = dictionary["name"] as? String

        if let poster = dictionary["malimg"] as? String {
            images = [Image]()
            
            let URL = NSURL(string: poster)
            let image = Image(URL: URL!, type: .Poster)
            images.append(image)
        }
        
        smallImage = images.filter({$0.type == ImageType.Poster}).first
        bigImage = smallImage
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func update(dictionary: NSDictionary) {
        seasons.removeAll(keepCapacity: true)
        
        let episodesDicts = dictionary["episodes"] as! [NSDictionary]
        let seasonNumber:UInt = 0
        
        var videosContainer = [Int: [Video]]()
        var episodesContainer = [Int: Episode]()
        synopsis = dictionary["synopsis"] as? String
        if let sps = synopsis {
            synopsis = sps.stringByReplacingOccurrencesOfString("oatRightHeader\">EditSynopsis\n", withString: "")
        }

        
        for episodeDict in episodesDicts{
            let title = episodeDict["name"] as! String
            let numbersFromTitle = numbersFromAnimeTitle(title)
            let synopsis = episodeDict["overview"] as? String
            if numbersFromTitle.count > 0 {
                if let quality = episodeDict["quality"] as? String{
                    // Get entry data
                    let subGroup = episodeDict["subgroup"] as? String
                    let episodeNumber = numbersFromTitle.first!
                    let magnetLink = episodeDict["magnet"] as! String
                    let video = Video(name: title, quality: quality, size: 0, duration: 0, subGroup: subGroup, magnetLink: magnetLink)
                    
                    var videos = videosContainer[episodeNumber]
                    if (videos == nil) {
                        videos = [Video]()
                        videosContainer[episodeNumber] = videos
                    }
                    videosContainer[episodeNumber]!.append(video)
                    
                    
                    var episode = episodesContainer[episodeNumber]
                    if (episode == nil) {
                        episode = Episode(title: title, desc: synopsis, seasonNumber: seasonNumber, episodeNumber: UInt(episodeNumber), videos: [Video]())
                        episodesContainer[episodeNumber] = episode!
                    }
                }
            }
        }
        
        for entry in videosContainer {
            let episodeNumber = entry.0
            let videos = entry.1
            
            episodesContainer[episodeNumber]!.videos = videos
        }
        
        
        let episodes = Array(episodesContainer.values).sort { (a, b) -> Bool in
            return a.episodeNumber > b.episodeNumber
        }
        
        let season = Season(seasonNumber: seasonNumber, episodes: episodes)
        seasons.append(season)
    }
    
    private func numbersFromAnimeTitle(title: String) -> [Int]{
        let components = title.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "[]_() "))
        var numbers = [Int]()
        for component in components {
            if let number = Int(component) {
                if number < 10000 {
                    numbers.append(number)
                }
            }
        }
        return numbers
    }
}

extension Anime: ContainsEpisodes {
    func episodeFor(seasonIndex seasonIndex: Int, episodeIndex: Int) -> Episode {
        let episode = seasons[seasonIndex].episodes[episodeIndex]
        return episode
    }
    
    func episodesFor(seasonIndex seasonIndex: Int) -> [Episode] {
        return seasons[seasonIndex].episodes
    }
}