//
//  SettingMethodOfOperationViewController.swift
//  SwipeToDoApp
//
//  Created by 前田航汰 on 2022/04/29.
//

import UIKit
import WebKit

class SettingMethodOfOperationViewController: UIViewController {

    @IBOutlet private weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = false

        if let url = URL(string: "https://local-tumbleweed-7ea.notion.site/d20077be02e243568132ff53b58874d2") {
            self.webView.load(URLRequest(url: url))
        } else {
            print("URLが取得できませんでした。")
        }
    }

    @IBAction func didTapExitButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
