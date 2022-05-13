//
//  SettingTableViewController.swift
//  SwipeToDoApp
//
//  Created by 前田航汰 on 2022/04/29.
//

import UIKit

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var versionNumber: UILabel!
    private let reviewUrl = "https://apps.apple.com/jp/app/swipetodo/id1623714500?mt=8&action=write-review"
    private let operationUrl = "https://local-tumbleweed-7ea.notion.site/SwipeToDo-ea54cf669ca246a997f091803dbbb04e"
    private let feedbackUrl = "https://forms.gle/3aT6RegBGJ1L8KPt7"
    private let privacyUrl = "https://tetoblog.org/swipetodo/privacy/"
    private let ruleUrl = "https://tetoblog.org/swipetodo/rule/"

    override func viewDidLoad() {
        super.viewDidLoad()
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        versionNumber.text = version
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [0, 0] {
            prepareWebWithArrow(url: operationUrl, title: "操作方法")
        } else if indexPath == [1, 0] {
            reviewApp()
        } else if indexPath == [1, 1] {
            shareApp()
        } else if indexPath == [1, 2] {
            prepareWebWithNotArrow(url: feedbackUrl, title: "お問い合わせ")
        } else if indexPath == [2, 0] {
            prepareWebWithArrow(url: privacyUrl, title: "プライバシーポリシー")
        } else if indexPath == [2, 1] {
            prepareWebWithArrow(url: ruleUrl,  title: "利用規約")
        }

        // 選択された色がスーっと消えていく
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func reviewApp() {
        if let url = URL(string: reviewUrl) {
            UIApplication.shared.open(url)
        }
    }

    private func prepareWebWithNotArrow(url: String, title: String) {
        let nextNC = storyboard?.instantiateViewController(withIdentifier: "WebWithNotArrowNC") as? UINavigationController
        let nextVC = nextNC?.topViewController as? SettingFeedbackViewController
        nextVC?.navigationItem.title = title
        nextVC?.catchUrl(url: url)
        present(nextNC!, animated: true, completion: nil)
    }

    private func prepareWebWithArrow(url: String, title: String) {
        let nextNC = storyboard?.instantiateViewController(withIdentifier: "WebWithArrowNC") as? UINavigationController
        let nextVC = nextNC?.topViewController as? SettingMethodOfOperationViewController
        nextVC?.catchUrl(url: url)
        nextVC?.navigationItem.title = title
        present(nextNC!, animated: true, completion: nil)
    }

    private func shareApp() {
        // TODO: 文字を考える
        let shareText = """
        今まで無かったToDoアプリ
        「Swipe ToDo」

        スワイプでToDoを消費。
        グラフでモチベーション管理。
        まさに、
        途中で挫折しないToDoアプリ
        """

        let activityItems = [shareText] as [Any]

        // 初期化処理
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        // iPadでクラッシュするため、iPadのみレイアウトの変更
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        self.present(activityVC, animated: true)
    }

    @IBAction func didTapExitButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
