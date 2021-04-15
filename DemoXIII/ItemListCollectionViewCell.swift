//
//  ItemListCollectionViewCell.swift
//  DemoX
//
//  Created by homejay on 2021/3/5.
//

import UIKit

class ItemListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    
    func setImageInfo(string:String) {
        itemImageView.image = UIImage(named: string)
    }
    
    deinit {
        print("ItemListCollectionViewCell＿＿＿＿＿死亡")
    }
    
}
