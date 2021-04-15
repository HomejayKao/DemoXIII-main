//
//  ResultTableViewCell.swift
//  DemoX
//
//  Created by homejay on 2021/2/20.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
   
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    deinit {
        print("ResultTableViewCell＿＿＿＿＿死亡")
    }

}

