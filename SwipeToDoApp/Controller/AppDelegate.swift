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

        // migrationはじまり
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            //(訳)新しいスキーマのバージョンを設定。以前使っていたバージョンよりも高くなければいけない。これまでバージョンの設定をしていなければ、初期のバージョンの値は0。
            schemaVersion: 1,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            //(訳)上記のものより低いスキーマバージョンでrealmを開くときに、自動的に呼び出されるようにブロックの設定をする。
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
        //(訳)まだマイグレーションを行っていないので、oldSchemaVersion == 0。
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
        //(訳)Realmは新しいプロパティと削除されたプロパティを自動で検知します。そして、自動でディスク上のスキーマを更新する。
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

