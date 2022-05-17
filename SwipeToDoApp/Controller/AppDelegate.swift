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
            schemaVersion: 1,

            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {

                    migration.enumerateObjects(ofType: Task.className()) { _, new in
                        new!["id"] = NSUUID().uuidString
                    }

                    migration.create(CategoryLists.className())
                    migration.enumerateObjects(ofType: CategoryLists.className()) { _, _ in
                    }

                    migration.enumerateObjects(ofType: "CategoryList") { old, _ in
                        let category = migration.create(Category.className())
                        category["name"] = old?["name"]
                        category["photo"] = old?["photo"]
                    }
                    migration.deleteData(forType: "CategoryList")
                }
            }
        )

        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        // migrationここまで

        let userDefaults = UserDefaults.standard
        let firstLunchKey = "firstLunch"
        let firstLunch = [firstLunchKey: false]
        userDefaults.register(defaults: firstLunch)

        var categoryList = realm.objects(Category.self)
        if categoryList.isEmpty {
            print("書記爆弾")
            let imageProgramming: Data! = (UIImage(named: "運動"))?.pngData()
            let imageShopping: Data! = (UIImage(named: "仕事"))?.pngData()
            let imageMtg: Data! = (UIImage(named: "家事"))?.pngData()
            let programming: Category! = Category.init(value: ["name": "運動","image": imageProgramming!])
            let shopping: Category! = Category.init(value: ["name": "仕事","image": imageShopping!])
            let mtg: Category! = Category.init(value: ["name": "家事","image": imageMtg!])
            do {
                try realm.write{
                    let list = CategoryLists()
                    list.list.append(programming)
                    list.list.append(shopping)
                    list.list.append(mtg)
                    realm.add(list)
                }
            } catch {
                print("AppDelegateでrealmエラー")
            }
        }

        // realmのマイグレーション後にデータを入れる処理
        categoryList = realm.objects(Category.self)
        var list: List<Category>!
        list = realm.objects(CategoryLists.self).first!.list
        print(list!)
        if list.isEmpty && !categoryList.isEmpty {
            for i in categoryList {
                try! realm.write {
                    list.append(i)
                }
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

