//
//  AlertController.swift
//  DemoX
//
//  Created by homejay on 2021/3/9.
//

import Foundation
import UIKit

class AlertController {
    static let shared = AlertController()
    
    func makeSingleAlert(title:String,message:String) -> UIAlertController{
        let singleAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        singleAlert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))

        return singleAlert
    }
    
    func makeYesNoAlert(title:String,message:String) -> UIAlertController {
        let yesNoAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "ok", style: .default) { (UIAlertAction) in
            print("自己的func or 程式碼")
            //自己的func or 程式碼
        }
        
        yesNoAlert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        yesNoAlert.addAction(cancelAction)

        return yesNoAlert
    }
    
    func makeWarningAlert(title:String,message:String) -> UIAlertController {
        let warningAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            print("自己的func or 程式碼 , 按Delete後的動作")
        }
        
        warningAlert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:  nil)
        
        warningAlert.addAction(cancelAction)
        
        return warningAlert
    }
    
    func makeEnterAlert(title:String,message:String) -> UIAlertController {
        let enterAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        enterAlert.addTextField { (UITextField) in
            UITextField.placeholder = "帳號"
        }
        
        enterAlert.addTextField { (UITextField) in
            UITextField.placeholder = "密碼"
            
            // 如果要輸入密碼 這個屬性要設定為 true
            UITextField.isSecureTextEntry = true
        }
        
        let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        enterAlert.addAction(okAction)
        enterAlert.addAction(cancelAction)

        return enterAlert
    }
    
    func makeMenuAlert(title:String,message:String) -> UIAlertController {
        let menuAlert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let menuArray = ["起始日期","結束日期"]
        
        for menu in menuArray {
            let menuAction = UIAlertAction(title: menu, style: .default, handler: nil)
            
            menuAlert.addAction(menuAction)
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        menuAlert.addAction(cancelAction)

        return menuAlert
    }
    
    
    deinit {
        print("AlertController物件＿＿＿＿＿＿＿＿＿死亡")
    }
}
