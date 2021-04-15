//
//  Channel.swift
//  DemoX
//
//  Created by homejay on 2021/3/11.
//

import Foundation

struct ChannelResponse:Codable {
    let items:[Item]
    
    struct Item:Codable {
        let snippet:Snippet
        
        struct Snippet:Codable {
            let title:String?
            let description:String?
            let thumbnails:Thumbnail
            
            struct Thumbnail:Codable {
                let medium:Medium
                
                struct Medium:Codable {
                    let url:URL
                    let width:Int?
                    let height:Int?
                }
            }
        }
    }
}
