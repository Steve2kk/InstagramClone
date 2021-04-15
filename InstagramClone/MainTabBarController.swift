//
//  MainTabBarController.swift
//  InstagramClone
//
//  Created by Vsevolod Shelaiev on 15.01.2021.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController,UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginViewController()
                let navController = UINavigationController(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        setupUIAndViewControllers()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2 {
            let layout = UICollectionViewFlowLayout()
            let selectedPhotoController = PhotoSelectorController(collectionViewLayout: layout)
            let selectedPhotoNavController = UINavigationController(rootViewController: selectedPhotoController)
            self.present(selectedPhotoNavController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func setupUIAndViewControllers() {
        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"),rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        let searchNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"),rootViewController: UserSearchController(collectionViewLayout: UICollectionViewFlowLayout()))
        let profileNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"),rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        let addPhotoNavContoller = templateNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
       
        tabBar.tintColor = .black
        viewControllers = [homeNavController,searchNavController,addPhotoNavContoller,profileNavController]

        guard let items = tabBar.items else {return}
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -10, right: 0)
        }
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage,selectedImage: UIImage,rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let templateVC = rootViewController
        let templateNavController = UINavigationController(rootViewController: templateVC)
        templateVC.tabBarItem.image = unselectedImage
        templateVC.tabBarItem.selectedImage = selectedImage
        return templateNavController
    }
}
