//
//  SearchList.swift
//  DemoX
//
//  Created by homejay on 2021/3/10.
//

import Foundation

struct SearchlistResponse:Codable{
    let nextPageToken:String?
    let regionCode:String
    let items:[Item]
    
    struct Item:Codable {
        let id:VideoID?
        let snippet:Snippet?
        
        struct VideoID:Codable {
            let videoId:String?
        }
        
        struct Snippet:Codable {
            let publishedAt:String?
            let channelId:String?
            let title:String?
            let channelTitle:String?
            let thumbnails:Thumbnail?
            
            struct Thumbnail:Codable {
                let medium:imageInfo?
                
                struct imageInfo:Codable {
                    let url:URL?
                    let width:Int?
                    let height:Int?
                }
            }
        }
    }
}
