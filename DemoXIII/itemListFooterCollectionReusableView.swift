//
//  itemListFooterCollectionReusableView.swift
//  DemoX
//
//  Created by homejay on 2021/3/5.
//

import UIKit

class itemListFooterCollectionReusableView: UICollectionReusableView {

    @IBOutlet weak var incomeExpenseSegmentedContorl: UISegmentedControl!
    
    deinit {
        print("itemListFooterCollectionReusableView＿＿＿＿＿死亡")
    }
    
}
