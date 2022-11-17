//
//  SourcePathConfigurator.swift
//  TestTask
//
//  Created by Dmitry Kh on 11.10.22.
//

import Foundation

struct AppConfiguratorModel: Decodable {
  let host: String
  let service: String?
  // add the config keys here and in the AppConfigurator.plist file
}

struct AppConfigurator: ConfiguratorProtocol {
  let model: AppConfiguratorModel
  
  let baseURL: URL

  init(fileName: String) throws {
    model = try Self.load(fileName)
    
    guard let url = URL(string: model.host) else {
      throw ConfiguratorErrors.configDataMismatch
    }

    baseURL = url
  }
}

extension AppConfigurator: SourcePathConfiguratorProtocol {

  func urlDataSource(path: String) -> URL? {
    let fullPath = (model.service ?? "") + path
    return URL(string: fullPath, relativeTo: baseURL)
  }
}
