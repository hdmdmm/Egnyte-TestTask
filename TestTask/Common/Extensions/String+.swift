//
//  String+extension.swift
//  TestTask
//
//  Created by Dmitry Kh on 11.10.22.
//

import Foundation

extension String {
  public var localized: String {
    return NSLocalizedString(self, comment: "")
  }
}
