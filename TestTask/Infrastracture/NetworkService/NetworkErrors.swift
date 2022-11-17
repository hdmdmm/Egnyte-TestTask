//
//  NetworkErrors.swift
//  TestTask
//
//  Created by Dmitry Kh on 14.10.22.
//

import Foundation

enum NetworkError: LocalizedError, Equatable {
  case error(statusCode: Int, data: Data?)
  case notConnected
  case cancelled
  case generic(Error)
  case urlGeneration

  static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
    if case let .error(lhsCode, lhsData) = lhs,
       case let .error(rhsCode, rhsData) = rhs,
       lhsCode == rhsCode, lhsData == rhsData {
      return true
    }

    if case .notConnected = lhs, case .notConnected = rhs {
      return true
    }

    if case .cancelled = lhs, case .cancelled = rhs {
      return true
    }

    if case let .generic(lhsError) = lhs,
       case let .generic(rhsError) = rhs,
       (lhsError as NSError).code == (rhsError as NSError).code {
      return true
    }

    if case .urlGeneration = lhs, case .urlGeneration = rhs {
      return true
    }
    return false
  }


  var errorDescription: String? {
    switch self {
    case .error(statusCode: let statusCode, data: _):
      if (400..<500) ~= statusCode {
        return String (
          format: "The request has finished with clients error. HTTP.StatusCode: %d".localized,
          statusCode)
      }
      
      if (500..<600) ~= statusCode {
        return String (format: "Server error. HTTP.StatusCode: %d".localized, statusCode)
      }
      return String( format: "Handled error: %d".localized, statusCode)

    case .notConnected:
      return "Couldn't esteablish connection with server".localized

    case .cancelled:
      return "Due to cancellation by user the process has stopped".localized

    case .generic(let error):
      return String(
        format:"The process couldnt be finished due to error. %s".localized,
        error.localizedDescription)

    case .urlGeneration:
      return "Bad url inputs for a request".localized
    }
  }
}
