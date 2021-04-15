//
//  EditCollectionReusableView.swift
//  DemoX
//
//  Created by homejay on 2021/3/7.
//

import UIKit

class EditCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var editTextField: UITextField!
    
    deinit {
        print("EditCollectionReusableView＿＿＿＿＿死亡")
    }
    
}
