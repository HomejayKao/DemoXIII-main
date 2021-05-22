//
//  Hololive.swift
//  DemoX
//
//  Created by homejay on 2021/3/11.
//

import Foundation

struct Hololive {
    
    let imageName:String
    let channel_ID:String
    let playlist_ID:String
    let video_ID:String? = nil
    let number = 0
    let twitterName:String
    
    static func returnImageNameArray() -> [String] {
        let imageNames = ["Sora",
                          "Roboco",
                          "Miko",
                          "Suisei",
                          "Fubuki",
                          "Meru",
                          "Akirose",
                          "Haachama",
                          "Matsuri",
                          "Aqua",
                          "Ayame",
                          "Shion",
                          "Choco",
                          "Subaru",
                          "Flare",
                          "Noel",
                          "Pekora",
                          "Marine",
                          "Rusia",
                          "Coco",
                          "Kanata",
                          "Luna",
                          "Towa",
                          "Watame",
                          "Botan",
                          "Lami",
                          "Polka",
                          "Nene",
                          "Korone",
                          "Mio",
                          "Okayu",
                          "Calliope",
                          "Kiara",
                          "Gura",
                          "Ame",
                          "Ina",
                          "Iofi",
                          "Moona",
                          "Risu"]
        
        return imageNames
    }
    
    static func returnThirdImageNameArray() -> [String] {
        let imageNames = [//"Marine",
                          "Rushia",
                          "Pekora",
                          "Noel",
                          "Flare"]
        return imageNames
    }
    
    static func returnThirdChannel_ID() -> [String] {
        let imageNames = [//"UCCzUftO8KOVkV4wQG1vkUvg",
                          "UCl_gCybOJRIgOXw6Qb4qJzQ",
                          "UC1DCedRgGHBdm81E1llLhOQ",
                          "UCdyqAaZDKHXg4Ahi7VENThQ",
                          "UCvInZx9h3jC2JzsIzoOebWg",]
        return imageNames
    }
    
    static func returnThirdPlaylist_ID() -> [String] {
        let imageNames = [//"UUCzUftO8KOVkV4wQG1vkUvg",
                          "UUl_gCybOJRIgOXw6Qb4qJzQ",
                          "UU1DCedRgGHBdm81E1llLhOQ",
                          "UUdyqAaZDKHXg4Ahi7VENThQ",
                          "UUvInZx9h3jC2JzsIzoOebWg",]
        return imageNames
    }
    
    static func returnThirdTwitterName() -> [String] {
        let imageNames = [//"houshoumarine",
                          "uruharushia",
                          "usadapekora",
                          "shiroganenoel",
                          "shiranuiflare",]
        return imageNames
    }
    
    static func makeHololiveList(imageNames:[String],channels:[String],playlists:[String],twitterNames:[String]) -> [Hololive] {
        var hololiveListArray = [Hololive]()
        
        for i in 0...imageNames.count - 1 {
            
            let member = Hololive(imageName: imageNames[i], channel_ID: channels[i], playlist_ID: playlists[i] ,twitterName: twitterNames[i])
            
            hololiveListArray.append(member)
        }
        return hololiveListArray
    }
    
}



