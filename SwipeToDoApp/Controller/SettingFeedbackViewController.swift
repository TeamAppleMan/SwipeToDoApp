//
//  SettingFeedbackViewController.swift
//  SwipeToDoApp
//
//  Created by 前田航汰 on 2022/04/29.
//

import UIKit
import WebKit
import PKHUD

class SettingFeedbackViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet private weak var webView: WKWebView!
    private let contactUrl = "https://forms.gle/3aT6RegBGJ1L8KPt7"

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.uiDelegate = self

        HUD.show(.progress, onView: view)
        if let url = URL(string: contactUrl) {
            self.webView.load(URLRequest(url: url))
        } else {
            print("お問い合わせフォームのURLが取得できませんでした。")
        }
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("お問い合わせフォームの読み込み開始")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("お問い合わせフォームの読み込み完了")
        HUD.hide(animated: true)
    }

    @IBAction private func didTapExitButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
