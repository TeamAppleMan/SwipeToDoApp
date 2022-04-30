//
//  Lottie04ViewController.swift
//  SwipeToDoApp
//
//  Created by 前田航汰 on 2022/04/30.
//

import UIKit
import Lottie

class Lottie04ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimation()
    }

    func showAnimation() {
        let animationView = AnimationView(name: "LottieLocket")
        animationView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height-400)
        animationView.center = self.view.center
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 1
        view.addSubview(animationView)

        animationView.play()
    }

    @IBAction func didTapStartButton(_ sender: Any) {
        let firstLunchKey = "firstLunchKey"
        UserDefaults.standard.set(true, forKey: firstLunchKey)

        let TabBarController = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
        self.present(TabBarController, animated: true, completion: nil)
    }

}
