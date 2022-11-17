//
//  Interfaces.swift
//  TestTask
//
//  Created by Dmitry Kh on 11.10.22.
//

import Foundation
import Combine

public protocol Request {
  var url: URL { get }
}

public protocol DownloadingDataServiceProtocol {
  func downloadData(by request: Request) -> AnyPublisher<(data: Data?, progress: Progress), Error>
}

public protocol SourcePathConfiguratorProtocol {
  func urlDataSource(path: String) -> URL?
}

public enum UseCasesErrors: LocalizedError {
  case wrongResourceName
  
  public var errorDescription: String? {
    switch self {
    case .wrongResourceName:
      return "Couldn't provide the resource without name.".localized
    }
  }
}
