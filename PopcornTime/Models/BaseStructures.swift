//
//  Video.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/21/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

struct Video {
    let name: String?
    let quality: String?
    let size: UInt?
    let duration: UInt?
    let subGroup: String?
    let magnetLink: String
}

struct Episode {
    let title: String?
    let desc: String?
    let seasonNumber: UInt
    let episodeNumber: UInt
    var videos = [Video]()
}

struct Season {
    let seasonNumber: UInt
    let episodes: [Episode]
}
