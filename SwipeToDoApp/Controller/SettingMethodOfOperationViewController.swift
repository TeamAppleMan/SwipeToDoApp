//
//  SettingMethodOfOperationViewController.swift
//  SwipeToDoApp
//
//  Created by 前田航汰 on 2022/04/29.
//

import UIKit
import WebKit
import PKHUD

class SettingMethodOfOperationViewController: UIViewController, WKUIDelegate, WKNavigationDelegate  {

    @IBOutlet private weak var webView: WKWebView!
    private let operationUrl = "https://local-tumbleweed-7ea.notion.site/d20077be02e243568132ff53b58874d2"

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.uiDelegate = self

        HUD.show(.progress, onView: view)
        if let url = URL(string: operationUrl) {
            self.webView.load(URLRequest(url: url))
        } else {
            print("操作方法のURLが取得できませんでした。")
        }
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("操作方法の読み込み開始")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("操作方法の読み込み完了")
        HUD.hide(animated: true)
    }

    @IBAction private func didTapExitButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
