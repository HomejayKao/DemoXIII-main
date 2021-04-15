//
//  DetailCollectionViewCell.swift
//  DemoX
//
//  Created by homejay on 2021/2/18.
//

import UIKit

class DetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var listImageView: UIImageView!
    
    deinit {
        print("DetailCollectionViewCell＿＿＿＿＿死亡")
    }
}
