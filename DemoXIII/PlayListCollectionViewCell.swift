//
//  PlayListCollectionViewCell.swift
//  DemoX
//
//  Created by homejay on 2021/3/10.
//

import UIKit

class PlayListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    
    func setInfo(_ imageUrl:URL,_ title:String){
        NetworkController.shared.fetchImage(url: imageUrl) { (result) in
            switch result {
            
            case let .success(image):
                DispatchQueue.main.async {
                    self.videoImageView.image = image
                }
            case let .failure(error):
                print(error)
            }
        }
        
        videoTitleLabel.text = title
    }
    
    deinit {
        print("PlayListCollectionViewCell＿＿＿＿＿死亡")
    }
}
