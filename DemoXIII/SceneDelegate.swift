//
//  SceneDelegate.swift
//  DemoX
//
//  Created by homejay on 2021/2/15.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        //使用此方法可以有選擇地配置UIWindow窗口並將其附加到提供的UIWindowScene場景。
        //如果使用情節提要，則`window`屬性將自動初始化並附加到場景中。
        //此委託並不意味著連接場景或會話是新的（請參閱`application：configurationForConnectingSceneSession`）。
        
        //這是UISceneSession生命週期中調用的第一個方法。 此方法將創建新的UIWindow，設置根視圖控制器，並使該窗口成為要顯示的關鍵窗口。
        
        //適合做一些初始化的動作,比方抓取網路資料,設定畫面的主要顏色等
        
        //guard let windowScene = (scene as? UIWindowScene) else { return }
        
        /*
        //這樣初始介面會是ContainerViewController()而不是Login故先隱藏，但就沒側邊菜單
        window = UIWindow(windowScene: windowScene)
        let containerViewController = ContainerViewController()
        window!.rootViewController = containerViewController
        window!.makeKeyAndVisible()
        */
        
        //更改所有navigationBar的屬性
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.black
        navigationBarAppearace.barTintColor = UIColor.white
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        
        
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        //在系統釋放場景時調用。
        //這是在場景進入背景後不久或會話被丟棄時發生的。
        //釋放與此場景關聯的所有資源，這些資源可在場景下次連接時重新創建。
        //場景可能稍後會重新連接，因為它的會話並不一定會被丟棄（請參閱`application：didDiscardSceneSessions`）。
        
        //當場景即將開始時（例如，應用程序首次激活時）或從背景過渡到前景時，將調用此方法。
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        //當場景從非活動狀態轉換為活動狀態時調用。
        //使用此方法重新啟動場景處於非活動狀態時已暫停（或尚未開始）的所有任務。
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        //當場景從活動狀態轉換為非活動狀態時調用。
        //這可能是由於暫時的中斷（例如打進來的電話）而發生的。
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        //當場景從背景過渡到前景時調用。
        //使用此方法撤消在輸入背景時所做的更改。
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        //當場景從前景過渡到背景時調用。
        //使用此方法保存數據，釋放共享資源並存儲足夠的特定於場景的狀態信息
        //將場景恢復到當前狀態。
    }


}

