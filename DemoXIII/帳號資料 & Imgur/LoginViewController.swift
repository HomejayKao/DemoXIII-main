//
//  LoginViewController.swift
//  DemoX
//
//  Created by homejay on 2021/2/15.
//

import UIKit

class LoginViewController: UIViewController {


    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let getUrl = "https://api.airtable.com/v0/appUFA1vsu2dfoYsc/%E5%AE%A2%E6%88%B6%E8%B3%87%E6%96%99%E8%A1%A8/"
    
    var recordArray = [InfoResponse.Records]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accountTextField.delegate = self
        passwordTextField.delegate = self
        
        
        //移除tabBar 上邊線top line
        self.tabBarController?.tabBar.layer.borderWidth = 0
        self.tabBarController?.tabBar.clipsToBounds = true
        
        //插入漸層圖
        view.insertSubview(makeGradientView(), at: 0)
        
        accountTextField.placeholder = "homejay1228"
        passwordTextField.placeholder = "home"
        
        accountTextField.text = "homejay1228"
        passwordTextField.text = "home"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //隱藏navigationBar
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.alpha = 0
        
        //更改tabBar的顏色
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 52/255, green: 168/255, blue: 83/255, alpha: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //重新顯示 tabBar
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, animations: {
            self.tabBarController?.tabBar.isHidden = false 
            self.tabBarController?.tabBar.alpha = 1
        }, completion: nil)
        
        
        NetworkController.shared.fetchAirtableAPI(urlString: getUrl) { (result) in
            switch result {
            
            case let .success(infoResponse):
                self.recordArray = infoResponse.records
                print("fetchAirtableAPI 成功")
            case let .failure(error):
                print("fetchAirtableAPI 失敗\(error)")
            }
        }
        
    }
    
    //Airtable login
    @IBAction func login(_ sender: Any) {
        
        
        guard accountTextField.text != "" else {
            let alert = AlertController.shared.makeSingleAlert(title: "錯誤", message: "帳號不可空白")
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard passwordTextField.text != "" else {
            let alert = AlertController.shared.makeSingleAlert(title: "錯誤", message: "密碼不可空白")
            present(alert, animated: true, completion: nil)
            return
        }
        
        var isSuccess = false
        
        for record in recordArray {
            if let account = record.fields.Account,
               let password = record.fields.Password {
                
                if accountTextField.text == account , passwordTextField.text == password {
                    
                    isSuccess = true
                    performSegue(withIdentifier: "loginToHomePage", sender: sender)
                    
                }
            }
        }
        
        if isSuccess == false {
            let alert = AlertController.shared.makeSingleAlert(title: "登入失敗", message: "請重新嘗試")
            present(alert, animated: true, completion: nil)
        }
        
        self.view.endEditing(true)
    }
    
    func makeGradientView() -> UIView {
        let gradientView = UIView()
        gradientView.frame = view.bounds
        
        let gradienLayer = CAGradientLayer()
        
        gradienLayer.frame = gradientView.bounds
        
        gradienLayer.colors = [
            UIColor(red: 136/255, green: 219/255, blue: 183/255, alpha: 1).cgColor,
            UIColor(red: 52/255, green: 168/255, blue: 83/255, alpha: 1).cgColor,
        ]

        gradientView.layer.addSublayer(gradienLayer)
        
        return gradientView
    }
    
    //收鍵盤(點螢幕空白處)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    deinit {
        print("LoginViewController＿＿＿＿＿死亡")
    }
}

//收鍵盤(點return) ＆ 跳下一個textField
extension LoginViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case accountTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            textField.endEditing(true)
        default:
            break
        }
        return true
    }
}



