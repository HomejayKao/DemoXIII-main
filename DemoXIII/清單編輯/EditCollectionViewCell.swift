//
//  EditCollectionViewCell.swift
//  DemoX
//
//  Created by homejay on 2021/3/7.
//

import UIKit

class EditCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func setImageInfo(string:String) {
        imageView.image = UIImage(named: string)
    }
    
    deinit {
        print("EditCollectionViewCell＿＿＿＿＿死亡")
    }
}
