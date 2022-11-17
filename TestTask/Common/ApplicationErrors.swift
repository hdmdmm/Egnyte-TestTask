//
//  GeneralErrors.swift
//  TestTask
//
//  Created by Dmitry Kh on 11.10.22.
//

import Foundation

public enum ApplicationErrors: LocalizedError {
  case notImplemented
  
  public var errorDescription: String? {
    switch self {
    case .notImplemented: return "Under maintenance".localized
    }
  }
}
