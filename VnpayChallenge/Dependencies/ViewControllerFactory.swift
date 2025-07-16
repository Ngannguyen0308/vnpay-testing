//
//  ViewControllerFactory.swift
//  VnpayChallenge
//
//  Created by ADMIN on 16/7/25.
//

import Foundation
import UIKit

final class ViewControllerFactory {
    private var dependencies = DependencyContainer()
    
    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
    }
    
    func makeTabbarViewController() -> UITabBarController {
        return TabbarControllerViewController(factory: self)
    }
    
    func makeHomeViewController() -> HomeViewController {
        let homeViewModel = HomeViewModel(
            photoListService: dependencies.photoListService
//            context: dependencies.persistenceStore.viewContext
        )
        
        return HomeViewController(viewModel: homeViewModel)
    }
}
