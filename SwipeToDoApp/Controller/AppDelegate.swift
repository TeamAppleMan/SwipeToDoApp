//
//  AppDelegate.swift
//  SwipeToDoApp
//
//  Created by 近藤米功 on 2022/04/20.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Mikeコメ：下記だとうまくいかないです。。
        // アンインストール後は問題なく使える状態です。
        // migrationはじまり
        let config = Realm.Configuration(
            schemaVersion: 1,

            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: CategoryList.className()) { oldObject, newObject in
                        let categoryList = migration.create(CategoryList.className())
                        let list = newObject?["list"] as? List<MigrationObject>
                        list?.append(categoryList)
                    }
                }
            })

        // Tell Realm to use this new configuration object for the default Realm
        //(訳)default Realmに対して、新しい設定オブジェクトを使うように、Realmに指示する。
        Realm.Configuration.defaultConfiguration = config

        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        let realm = try! Realm()
        // migrationここまで

        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunch"
        let firstLunch = [firstLunchKey: false]
        userDefaults.register(defaults: firstLunch)

        let categoryList = realm.objects(CategoryList.self)
        var list: List<CategoryList>!
        if categoryList.isEmpty {
            print("書記爆弾")
            let imageProgramming: Data! = (UIImage(named: "運動"))?.pngData()
            let imageShopping: Data! = (UIImage(named: "仕事"))?.pngData()
            let imageMtg: Data! = (UIImage(named: "家事"))?.pngData()
            let programming: CategoryList! = CategoryList.init(value: ["name": "運動","photo": imageProgramming!])
            let shopping: CategoryList! = CategoryList.init(value: ["name": "仕事","photo": imageShopping!])
            let mtg: CategoryList! = CategoryList.init(value: ["name": "家事","photo": imageMtg!])
            do {
                try realm.write{
                    let itemList = ItemList()
                    itemList.list.append(programming)
                    itemList.list.append(shopping)
                    itemList.list.append(mtg)
                    realm.add(itemList)
                }
            } catch {
                print("AppDelegateでrealmエラー")
            }
        }
        return true
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


}

