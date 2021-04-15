//
//  Profile.swift
//  DemoX
//
//  Created by homejay on 2021/3/11.
//

import Foundation

struct ProfileResponse:Codable {
    let id:Int?
    let name:String?
    let screen_name:String?
    let location:String?
    let description:String?
    let entities:Entities
    let followers_count:Int?
    let friends_count:Int?
    let created_at:String?
    let status:Status
    let profile_image_url_https:URL?
    let profile_banner_url:URL?
    
    struct Entities:Codable {
        let url:Urls
        
        struct Urls:Codable {
            let urls:[YoutubeChannelURL]
            
            struct YoutubeChannelURL:Codable {
                let expanded_url:URL?
            }
        }
    }
    
    struct Status:Codable {
        let created_at:String?
        let id:Int?
        let text:String?
        let entities:Entity
        
        struct Entity:Codable {
            let urls:[TweetURL]
            
            struct TweetURL:Codable {
                let expanded_url:URL?
            }
        }
    }
}
