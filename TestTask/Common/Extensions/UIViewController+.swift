//
//  UIViewController+extension.swift
//  TestTask
//
//  Created by Dmitry Kh on 11.10.22.
//

import UIKit

public protocol Alertable {
  func alert(message: String, title: String)
}

extension Alertable where Self: UIViewController {
  public func alert(message: String, title: String = "") {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(OKAction)
    self.present(alertController, animated: true, completion: nil)
  }
}
