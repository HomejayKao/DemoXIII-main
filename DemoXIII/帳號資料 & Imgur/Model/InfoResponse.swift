//
//  InfoResponse.swift
//  DemoX
//
//  Created by homejay on 2021/2/15.
//

import Foundation

struct InfoResponse:Codable {
    let records:[Records]
    
    struct Records:Codable {
        let fields:Field
        let id:String?
        let createdTime:String?
        
        struct Field:Codable {
            let Name:String?
            let Phone:String?
            let Address:String?
            let Email:String?
            let Rating:Int?
            let Tags:[String]?
            let Account:String?
            let Password:String?
            let Notes:String?
            let CreatedTime:String?
            let LastModified:String?
            
        }
    }
}
