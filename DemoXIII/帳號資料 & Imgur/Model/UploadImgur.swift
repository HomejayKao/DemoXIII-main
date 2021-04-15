//
//  UploadImgur.swift
//  DemoX
//
//  Created by homejay on 2021/3/22.
//

import Foundation

struct UploadImgur: Codable {
    
    let data: UploadData
    
    struct UploadData: Codable {
        let link: URL
    }
}
