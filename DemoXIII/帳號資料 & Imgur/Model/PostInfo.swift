//
//  PostInfo.swift
//  DemoX
//
//  Created by homejay on 2021/2/15.
//

import Foundation

struct PostInfo:Codable {
    
    let records:[Item]
    
    struct Item:Codable {
        let fields:Field
        
        struct Field:Codable {
            let Name:String?
            let Phone:String?
            let Address:String?
            let Email:String?
            let Rating:Int?
            let Tags:[String]?
            let Account:String?
            let Password:String?
            let Attachments:[Attachment]
            let Gender:Bool?
            let Notes:String?
            
            struct Attachment:Codable {
                let url:String?
            }
        }
        
    }
}


