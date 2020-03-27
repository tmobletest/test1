//
//  TabBarViewController.swift
//  Github_App
//
//  Created by 深見龍一 on 2019/12/27.
//  Copyright © 2019 深見龍一. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    private let udf = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        let seachVC = UINavigationController(rootViewController: SearchUserViewController.init(nibName: nil, bundle: nil))
        // タブのFooter部分を設定
        seachVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)

        let favoriteVC = UINavigationController(rootViewController: FavoriteViewController.init(nibName: nil, bundle: nil))
        // タブのFooter部分を設定
        favoriteVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)

        let loginVC = UINavigationController(rootViewController: LoginViewController.init(nibName: nil, bundle: nil))
        // タブのFooter部分を設定
        loginVC.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 2)

        let myPageVC = UINavigationController(rootViewController: MyPageViewController.init(nibName: nil, bundle: nil))
        // タブのFooter部分を設定
        myPageVC.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 2)

        let oauthToken = udf.string(forKey: "oauthToken") ?? ""
        
        if oauthToken != "" // ログインした状態
        {
            self.viewControllers = [seachVC, favoriteVC, myPageVC]
        }else // ログインしていない状態
        {
            self.viewControllers = [seachVC, favoriteVC, loginVC]
        }
    }
}
