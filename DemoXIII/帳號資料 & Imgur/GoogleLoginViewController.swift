//
//  GoogleLoginViewController.swift
//  DemoXIII
//
//  Created by homejay on 2021/4/21.
//

import UIKit
import GoogleSignIn
import Firebase

class GoogleLoginViewController: UIViewController {

    @IBOutlet weak var goToTheNextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //要找到Firebase的ClientID不是在另一個Demo自己申請的，故是在左側Firebase的 GoogleService-Info.plist檔案內 REVERSED_CLIENT_ID
        //GIDSignIn.sharedInstance().clientID = "629159607959-nombpddh930u133c0pnkv29m2k4rf5mp.apps.googleusercontent.com" //"YOUR_CLIENT_ID"
        GIDSignIn.sharedInstance().delegate = self
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        
        GIDSignIn.sharedInstance()?.presentingViewController = self //在iOS 9 和10 時 為 SFSafariViewContoller。
        //GIDSignIn.sharedInstance()?.restorePreviousSignIn()//自動登錄用戶。
        
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
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 255/255, green: 113/255, blue: 124/255, alpha: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //重新顯示 tabBar
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, animations: {
            self.tabBarController?.tabBar.isHidden = false
            self.tabBarController?.tabBar.alpha = 1
        }, completion: nil)
    }

    
    @IBAction func googleSignInTaped(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signIn()
        print("Google Signed in")
    }
    
    @IBAction func googleSignOutButtonTouchUp(_ sender: Any) {
        
        //Google登出
        GIDSignIn.sharedInstance().signOut()
        print("Google Signed out")
        
        GIDSignIn.sharedInstance().disconnect()
        print("Google Disconnecting.")
        
        //Firebase 登出
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
        
        gradienLayer.colors = [
            UIColor(red: 255/255, green: 183/255, blue: 176/255, alpha: 1).cgColor,
            UIColor(red: 255/255, green: 113/255, blue: 124/255, alpha: 1).cgColor,
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

extension GoogleLoginViewController:GIDSignInDelegate {
    
    //登錄處理程序，Google登入時觸發
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("用戶之前未登錄過，或者已經退出.")
            } else {
                print("登入失敗",error.localizedDescription)
            }
            return //這個return很重要
        }
        
        print("用戶已登入")
        // 在此對登錄用戶執行任何操作。
        let userId = user.userID                  // 僅用於客戶端！
        let idToken = user.authentication.idToken // 用於安全發送到後端伺服器
        let fullName = user.profile.name
        let givenName = user.profile.givenName
        let familyName = user.profile.familyName
        let email = user.profile.email //如果將GIDSignIn.shouldFetchBasicProfile屬性設置為NO ，則GIDGoogleUser.profile.email字段將不可用。
        
        print(userId!)
        print(idToken!)
        print(fullName!)
        print(givenName!)
        print(familyName!)
        print(email!)
        
        //Firebase登入
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            
            
            guard let self = self else {
                print("self = nil")
                return }
            guard error == nil else {
                print("FirebaseSignIn失敗",error!.localizedDescription)
                return
            }
            print("FirebaseSingIn成功")
            
            self.performSegue(withIdentifier: "loginToHomePageWithGoogle", sender: self.goToTheNextButton)
            
            
            switch authResult {
            
            case .none:
                print("沒有值")
                
            case .some(_):
                print("有值(描述登錄嘗試的結果)")
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
    
    
    //斷開處理程序
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        print("用戶已斷開,disconnect,並非登出,兩者不一樣")
        // 當用戶從此處斷開與應用的連接時，請執行任何操作。
        
        
        
    }
        
    //注意：Sign-In SDK自動獲取access tokens，但是僅當您調用 signIn 或 restorePreviousSignIn 時，access tokens 才會刷新。
    //要顯式刷新access tokens，請調用 refreshTokensWithHandler:方法。
    //如果你需要access tokens並希望SDK自動處理刷新它，則可以使用 getTokensWithHandler:方法。
    //如果需要將當前登錄的用戶傳遞到後端伺服器，請將用戶的ID token發送到你的後端伺服器，並在伺服器上驗證該token。
    //請勿使用userId字段中可用的Google ID 或 用戶的個人資料信息 將當前登錄的用戶傳達給你的後端伺服器。而是發送ID token，可以在伺服器上對其進行安全驗證。
}
