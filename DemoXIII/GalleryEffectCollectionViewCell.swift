//
//  GalleryEffectCollectionViewCell.swift
//  DemoX
//
//  Created by homejay on 2021/3/3.
//

import UIKit

class GalleryEffectCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var galleryImageView: UIImageView!
    @IBOutlet weak var imageViewGallery: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    deinit {
        print("GalleryEffectCollectionViewCell＿＿＿＿＿死亡")
    }

}
