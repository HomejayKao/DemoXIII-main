//
//  PlayList.swift
//  DemoX
//
//  Created by homejay on 2021/3/10.
//

import Foundation

//所有自訂型別都要遵從Codable
struct PlaylistResponse:Codable {
    let nextPageToken:String? //代表API URL網址路徑 搭配 pageToken="" 就能取得下一頁的資料
    let items:[Item]
    let pageInfo:PageInfo
    
    struct PageInfo:Codable {
        let totalResults:Int?
        let resultsPerPage:Int?
    }
    
    struct Item:Codable {
        let snippet:Snippet
        
        struct Snippet:Codable{
            let title:String?
            let channelTitle:String?
            let thumbnails:Thumbnail
            let resourceId:ResourceId
            
            struct Thumbnail:Codable{
                let medium:ImageInfo
                
                struct ImageInfo:Codable {
                    let url:URL?
                    let width:Int?
                    let height:Int?
                }
            }
            
            struct ResourceId:Codable {
                let videoId:String?
            }
        }
        
    }
    
}
