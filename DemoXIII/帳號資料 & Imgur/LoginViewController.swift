//
//  LoginViewController.swift
//  DemoX
//
//  Created by homejay on 2021/2/15.
//

import UIKit

//尚未完成

class LoginViewController: UIViewController {

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let getUrl = "https://api.airtable.com/v0/appUFA1vsu2dfoYsc/%E5%AE%A2%E6%88%B6%E8%B3%87%E6%96%99%E8%A1%A8/"
    
    var recordArray = [InfoResponse.Records]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkController.shared.fetchAirtableAPI(urlString: getUrl) { (result) in
            switch result {
            
            case let .success(infoResponse):
                self.recordArray = infoResponse.records
                print("成功")
            case let .failure(error):
                print("失敗\(error)")
            }
        }
        
    }
    
    
    @IBAction func login(_ sender: Any) {
        if let accountText = accountTextField.text,
           let passwordText = passwordTextField.text {

            performSegue(withIdentifier: "loginToHomePage", sender: sender)
            for index in recordArray {
                
                
                if let account = index.fields.Account,
                   let password = index.fields.Password {

                    switch (accountText == account && passwordText == password) {
                    case (true && true):
                        
                        performSegue(withIdentifier: "loginToHomePage", sender: sender)
                    default:
                        makeAlert(title: "帳號密碼錯誤", message: "請重新輸入")
                        
                    }
                }
            }
        }
    }
    
    //錯誤通知
    func makeAlert(title:String ,message:String) {
        let singleAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        singleAlert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        
        present(singleAlert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    deinit {
        print("LoginViewController＿＿＿＿＿死亡")
    }
}
