//
//  BaseViewController.swift
//  CurrencyConverterApp
//
//  Created by Usman Abid on 2024-2-06.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
    }
    
    func parseNetworkError(error: NetworkError) {
        var errorMessage = ""
        switch error {
        case .invalidURL(let message):
            errorMessage = message
        case .invalidResponse(let message):
            errorMessage = message
        case .decodingError(let message):
            errorMessage = message
        case .genericError(let message):
            errorMessage = message
        case .internetError(let message):
            errorMessage = message
        
        }
        
        showErrorView(errorMessage: errorMessage)
    }
    
    func showErrorView(errorMessage: String) {
        let errorDialogMessage = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        //Add OK button to a dialog message
        errorDialogMessage.addAction(ok)
        // Present alert to user
        self.present(errorDialogMessage, animated: true, completion: nil)
    }
}

extension BaseViewController: ProgressLoadingViewable {}

extension Reactive where Base: BaseViewController {
    
    /// Bindable sink for `startAnimating()`, `stopAnimating()` methods.
    internal var isAnimating: Binder<Bool> {
        return Binder(self.base, binding: { (vc, active) in
            if active {
                vc.startAnimating()
            } else {
                vc.stopAnimating()
            }
        })
    }
    
}

extension BaseViewController {
    public func add(asChildViewController viewController: UIViewController,to parentView:UIView) {
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        parentView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = parentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
}

