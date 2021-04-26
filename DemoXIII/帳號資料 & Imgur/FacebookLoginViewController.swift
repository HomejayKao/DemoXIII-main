//
//  FacebookLoginViewController.swift
//  DemoXIII
//
//  Created by homejay on 2021/4/21.
//

import UIKit
import FacebookLogin
import FBSDKCoreKit_Basics //檢查使用者的登入狀態、讀取使用者的 FB profile 資訊
import FirebaseAuth

class FacebookLoginViewController: UIViewController {
    
    @IBOutlet var facebookLoginTapGesture: UITapGestureRecognizer!
    @IBOutlet weak var goToTheNextButton: UIButton!
    let fbLoginButton = FBLoginButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        fbLoginButton.delegate = self
        
        
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
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 59/255, green: 89/255, blue: 153/255, alpha: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //重新顯示 tabBar
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, animations: {
            self.tabBarController?.tabBar.isHidden = false
            self.tabBarController?.tabBar.alpha = 1
        }, completion: nil)
        
    }
    
    //Fabebook & Firebase ——————————————————————————————————————————————————————————————————————————————————————————————————————
    //FB登入
    @IBAction func facebookLoginTaped(_ sender: UITapGestureRecognizer) {
        let manager = LoginManager()
        
        manager.logIn(permissions: [.publicProfile, .email], viewController: nil) { loginResult in
            switch loginResult {
            case .success(granted: _, declined: _, token: _):
                
                //從 Profile 呼叫 function loadCurrentProfile 下載使用者的 profile 資訊，比方使用者的名字跟大頭照網址。
                
                if AccessToken.current != nil {
                    Profile.loadCurrentProfile { (profile, error) in
                        if let profile = profile {
                            
                            print("profile.name",profile.name)
                            print("profile.email",profile.email)
                            print("profile.imageURL",profile.imageURL(forMode: .square,
                                                                    size: CGSize(width: 300, height: 300)))
                            
                            
                            self.loginButton(self.fbLoginButton, didCompleteWith: .none, error: .none)
                            
                            //觸發跳頁
                            self.loginAndGoToTheNextVC(self.goToTheNextButton)
                            self.performSegue(withIdentifier: "loginToHomePageWithFacebook", sender: self.goToTheNextButton)
                        }
                    }
                }
                
                print("FacebookLogin＿＿＿＿＿＿＿＿＿＿success")
            case let .failed(error):
                print("FacebookLogin＿＿＿＿＿＿＿＿＿＿fail",error)
            case .cancelled:
                print("FacebookLogin＿＿＿＿＿＿＿＿＿＿cancel")
            }
            
            
        }
        
    }
    
    
    @IBAction func loginAndGoToTheNextVC(_ sender: UIButton) {
        print(#function)
    }
    
    @IBAction func facebookLogout(_ sender: UIButton) {
        
        //FB 登出
        let manager = LoginManager()
        manager.logOut()
        
        if let accessToken = AccessToken.current {
            print("\(accessToken.userID) login")
        } else {
            print("facebook logout")
        }
        
        loginButtonDidLogOut(fbLoginButton)
        
    }
    

    deinit {
        print("LoginViewController＿＿＿＿＿死亡")
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

extension FacebookLoginViewController:LoginButtonDelegate {
    //FB登入時觸發
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print("didCompleteWith失敗",error.localizedDescription)
            return
        }
        
        //Firebase - SingIn
        //先用 LoginManager 的 logIn 登入 FB，然後再用 AccessToken.current!.tokenString 產生 Firebase 登入需要的 credential，然後以 Auth.auth().signIn 登入。
        guard let currentToken = AccessToken.current?.tokenString else {
            print("no Current Token")
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: currentToken)
        
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            
            guard self != nil else {
                print("self = nil")
                return }
            guard error == nil else {
                print("FirebaseSignIn失敗",error?.localizedDescription)
                return
            }
            print("FirebaseSingIn成功")
            
            switch result {
            
            case .none:
                print("沒有值")
                
            case .some(_):
                print("有值LoginManagerLoginResult(描述登錄嘗試的結果)")
            }
            
            //也可以從 Auth.auth().currentUser 的 providerData 進一步取得從 FB 等第三方平台登入的相關資訊。
            if let user = Auth.auth().currentUser {
                print("\(user.providerID) login")
                if user.providerData.count > 0 {
                    
                    
                    print(user.providerData[0].providerID)
                    print(user.providerData[0].displayName!)
                    print(user.providerData[0].email!)
                    print(user.providerData[0].photoURL!)
                    
                }
            } else {
                print("FirebaseNotSignIn,NoCurrentUser")
            }
            
        }
        
    }
    
    //Firebase SignOut 登出
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("FirebaseSignOut成功")
        } catch let signOutError as NSError {
            print("FirebaseSignOut失敗")
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
    func makeGradientView() -> UIView {
        let gradientView = UIView()
        gradientView.frame = view.bounds
        
        let gradienLayer = CAGradientLayer()
        
        gradienLayer.frame = gradientView.bounds
        
        gradienLayer.colors = [UIColor(red: 160/255, green: 190/255, blue: 255/255, alpha: 1).cgColor,
                               UIColor(red: 59/255, green: 89/255, blue: 153/255, alpha: 1).cgColor]

        
        gradientView.layer.addSublayer(gradienLayer)
        
        return gradientView
    }
}
