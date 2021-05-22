//
//  FirebaseEmailLoginViewController.swift
//  DemoXIII
//
//  Created by homejay on 2021/4/21.
//

import UIKit
import FirebaseAuth

class FirebaseEmailLoginViewController: UIViewController {

    @IBOutlet weak var goToTheNextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //判斷使用者是否登入
        if let user = Auth.auth().currentUser {
            print("\(user.uid) login")
        } else {
            print("not login")
        }
        
        //判斷使用者是否登入 (二)
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                print("\(user.uid) login")
            } else {
                print("not login")
            }
        }
        
        
        //移除tabBar 上邊線top line
        self.tabBarController?.tabBar.layer.borderWidth = 0
        self.tabBarController?.tabBar.clipsToBounds = true
        
        //插入漸層圖
        view.insertSubview(makeGradientView(), at: 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //隱藏navigationBar
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.alpha = 0
        
        //更改tabBar的顏色
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 251/255, green: 188/255, blue: 5/255, alpha: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //重新顯示 tabBar
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, animations: {
            self.tabBarController?.tabBar.isHidden = false
            self.tabBarController?.tabBar.alpha = 1
        }, completion: nil)
    }
    

    @IBAction func registerButtonTouchUp(_ sender: Any) {
        
        let alert = UIAlertController(title: "註冊", message: "信箱＆密碼", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "信箱"
        }
        alert.addTextField { textField in
            textField.placeholder = "密碼"
            
            //顯示****
            textField.isSecureTextEntry = true
            textField.textContentType = .password
        }
        
        let okAction = UIAlertAction(title: "ok", style: .default) { action in
            
            if let email = alert.textFields?[0].text,
               let password = alert.textFields?[1].text {
                self.createUser(email, password)
            }
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //呼叫 Auth 物件的 createUser，傳入帳密建立新的使用者，成功時可取得使用者的 email & uid。
    //建立帳號成功後使用者將是已登入狀態，下次重新啟動 App 也會是已登入狀態。
    func createUser(_ email:String,_ password:String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            guard let user = result?.user,
                  error == nil else {
                print("註冊失敗",error!.localizedDescription)
                
                guard let errorString = error?.localizedDescription.description else { return }
                
                let alert = AlertController.shared.makeSingleAlert(title: "註冊失敗", message: errorString)
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            let alert = AlertController.shared.makeSingleAlert(title: "註冊成功", message: "請前往登入")
            self.present(alert, animated: true, completion: nil)
            
            print("email",user.email!)
            print("uid",user.uid)
        }
    }
    
   
    @IBAction func loginButtonTouchUp(_ sender: Any) {
        
        let alert = UIAlertController(title: "登入", message: "信箱＆密碼", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = "homejay1228@gmail.com"
            textField.placeholder = "homejay1228@gmail.com"
        }
        alert.addTextField { textField in
            textField.text = "homejay1228"
            textField.placeholder = "homejay1228"
            textField.isSecureTextEntry = true
            textField.textContentType = .password
        }
        
        let okAction = UIAlertAction(title: "login", style: .default) { action in
            if let email = alert.textFields?[0].text,
               let password = alert.textFields?[1].text {
                self.signInAccount(email, password)
            }
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //呼叫 Auth 物件的 signIn 登入。
    //登入後使用者將維持登入狀態，就算我們重新啟動 App ，使用者還是能保持登入。
    func signInAccount(_ email:String ,_ password:String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            guard error == nil else {
                print("登入失敗",error!.localizedDescription)
                
                guard let errorString = error?.localizedDescription.description else { return }
                
                let alert = AlertController.shared.makeSingleAlert(title: "登入失敗", message: errorString)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            print("登入成功")
            self.performSegue(withIdentifier: "loginToHomePageWithFirebaseEmail", sender: self.goToTheNextButton)
            
        }
        
    }
    
    //設定使用者的名字跟照片網址
    func profileChange() {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.photoURL = URL(string: "https://images.pexels.com/photos/1170986/pexels-photo-1170986.jpeg")
        changeRequest?.displayName = "使用者名字"
        changeRequest?.commitChanges(completion: { error in
            guard error == nil else {
                print("設定失敗",error!.localizedDescription)
                return
            }
        })
    }
    
    @IBAction func logoutButtonTouchUp(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            print("登出成功")
        } catch {
            print("登出失敗",error)
        }
    }
    
    func makeGradientView() -> UIView {
        let gradientView = UIView()
        gradientView.frame = view.bounds
        
        let gradienLayer = CAGradientLayer()
        
        gradienLayer.frame = gradientView.bounds
        
        gradienLayer.colors = [
            UIColor(red: 255/255, green: 236/255, blue: 171/255, alpha: 1).cgColor,
            UIColor(red: 251/255, green: 188/255, blue: 5/255, alpha: 1).cgColor,
        ]

        gradientView.layer.addSublayer(gradienLayer)
        
        return gradientView
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
