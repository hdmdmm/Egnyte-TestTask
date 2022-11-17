//
//  Array+.swift
//  TestTask
//
//  Created by Dmitry Kh on 13.10.22.
//

import Foundation

extension Array {
  public subscript(safeIndex index: Int) -> Element? {
    guard index >= 0, index < endIndex else {
      return nil
    }

    return self[index]
  }
}
