//
//  AppDelegate.swift
//  DemoXIII
//
//  Created by homejay on 2021/3/25.
//

//希望 App 一啟動就能完成 FB 的相關設定，並且處理 FB 功能觸發的 App 切換，比方處理從 FB 或 Safari App 切換回 App 時回傳的資料。

import UIKit
import CoreData
import FacebookCore //加入 FacebookCore 後才能使用 FB 的相關程式。
import Firebase
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    //在 App 啟動時完成 FB 的相關設定，因此在 application(_:didFinishLaunchingWithOptions:) 裡執行，ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)。
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ApplicationDelegate.shared.application(application,
                                               didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure()
        
        //google登入
        //在您的應用程序委託的application:didFinishLaunchingWithOptions:方法中，配置FirebaseApp對象並設置登錄委託。
        
        return true
    }
    
    
    //如果有切換到 FB App，再從 FB App 切換回我們的 App 時會呼叫 application(_:open:options:)，故在裡面執行 ApplicationDelegate.shared 的 application(_:open: url:sourceApplication: annotation:)。
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        ApplicationDelegate.shared.application(app,
                                               open: url,
                                               sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                               annotation:options[UIApplication.OpenURLOptionsKey.annotation])
        ||
            
        //該方法應調用GIDSignIn實例的handleURL方法，該實例將正確處理你的應用程序在身份驗證過程結束時收到的URL。
         GIDSignIn.sharedInstance().handle(url)
        
    }
    
    
    //為了使你的應用程序可以在iOS 8及更高版本上運行，還應實現不建議使用的application:openURL:sourceApplication:annotation:方法。
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    
    
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "DateIncomeExpense")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                // 用代碼替換此實現，以適當地處理錯誤。
                // fatalError（）使應用程序生成崩潰日誌並終止。 儘管此功能在開發過程中可能很有用，但您不應在運輸應用程序中使用此功能。
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }


}

