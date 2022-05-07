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
    @IBOutlet private weak var backButton: UIBarButtonItem!
    @IBOutlet private weak var forwardButton: UIBarButtonItem!

    private let operationUrl = "https://local-tumbleweed-7ea.notion.site/SwipeToDo-ea54cf669ca246a997f091803dbbb04e"

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
        judgeToolBarButton()
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        webView.goBack()
    }

    @IBAction func didTapForwardButton(_ sender: Any) {

        webView.goForward()
    }

    func webView(_ webView: WKWebView, contextMenuWillPresentForElement elementInfo: WKContextMenuElementInfo) {
        print("???")
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("操作方法の読み込み開始")
        judgeToolBarButton()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("操作方法の読み込み完了")
        HUD.hide(animated: true)
        judgeToolBarButton()
    }

    private func judgeToolBarButton() {
        if webView.canGoBack {
            backButton.isEnabled = true
        } else {
            backButton.isEnabled = false
        }

        if webView.canGoForward {
            forwardButton.isEnabled = true
        } else {
            forwardButton.isEnabled = false
        }
    }

    @IBAction private func didTapExitButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
