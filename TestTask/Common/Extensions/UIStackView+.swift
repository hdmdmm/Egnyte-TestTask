//
//  UIStackView+extension.swift
//  TestTask
//
//  Created by Dmitry Kh on 12.10.22.
//

import Foundation
import UIKit

extension UIStackView {
  public func addArrangedSubviews(_ views: [UIView]) {
    views.forEach { addArrangedSubview($0) }
  }
}
