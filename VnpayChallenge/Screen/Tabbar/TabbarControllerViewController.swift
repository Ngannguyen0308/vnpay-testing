//
//  TabbarControllerViewController.swift
//  VnpayChallenge
//
//  Created by ADMIN on 16/7/25.
//

import UIKit
import Foundation

class TabbarControllerViewController: UITabBarController {
    private let factory: ViewControllerFactory
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = .white
        configureTabs()
    }
    
    init(factory: ViewControllerFactory) {
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - tabbar setup
    private func configureTabs() {
        let tabs = Tab.allCases
        
        let viewControllers = tabs.map { tab in
            return createNav(with: tab.image, selectedImage: tab.selectedImage, vc: tab.viewController(factory: factory))
        }
        self.setViewControllers(viewControllers, animated: true)
    }
    
    private func createNav(with image: UIImage, selectedImage: UIImage, vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem.image = image
        nav.tabBarItem.selectedImage = selectedImage.withRenderingMode(.alwaysOriginal)
        return nav
    }
}

extension TabbarControllerViewController {
    enum Tab: CaseIterable {
        case home
        case profile
        case cart
        
        var image: UIImage {
            switch self {
            case .home:
                return UIImage(named: "ic-home") ?? UIImage()
            case .cart:
                return UIImage(named: "ic-cart") ?? UIImage()
            case .profile:
                return UIImage(named: "ic-profile") ?? UIImage()
            }
        }
        
        var selectedImage: UIImage {
            switch self {
            case .home:
                return UIImage(named: "ic-home-selected") ?? UIImage()
            case .cart:
                return UIImage(named: "ic-cart-selected") ?? UIImage()
            case .profile:
                return UIImage(named: "ic-profile-selected") ?? UIImage()
            }
        }
        
        func viewController(factory: ViewControllerFactory) -> UIViewController {
            switch self {
            case .home:
                return factory.makeHomeViewController()
                
            case .cart, .profile:
                return UIViewController()
            }
        }
    }
}
