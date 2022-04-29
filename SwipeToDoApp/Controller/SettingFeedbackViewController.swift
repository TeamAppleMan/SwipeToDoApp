//
//  SettingFeedbackViewController.swift
//  SwipeToDoApp
//
//  Created by 前田航汰 on 2022/04/29.
//

import UIKit
import WebKit

class SettingFeedbackViewController: UIViewController {

    @IBOutlet private weak var webView: WKWebView!
    let indicator = UIActivityIndicatorView()
    let semaphore = DispatchSemaphore(value: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: 通信中にインジケーターを追加したいが、非同期処理完了時の判定に頭悩ませ中
        //indicator.center = view.center
        //indicator.style = .large
        //indicator.color = UIColor(red: 44/255, green: 169/255, blue: 225/255, alpha: 1)
        //view.addSubview(indicator)

        if let url = URL(string: "https://forms.gle/3aT6RegBGJ1L8KPt7") {
            self.webView.load(URLRequest(url: url))
            semaphore.signal()
        } else {
            print("URLが取得できませんでした。")
        }
    }

    @IBAction func didTapExitButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
