//

import Foundation

public enum ConfiguratorErrors: Error {
  case configFileNotFound
  case configInvalidPath
  case configDataMismatch
}

extension ConfiguratorErrors: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .configDataMismatch: return "config_data_mismatch".localized
    case .configInvalidPath: return "config_invalid_path".localized
    case .configFileNotFound: return "config_file_not_found".localized
    }
  }
}

public protocol ConfiguratorProtocol {
  associatedtype ConfiguratorModelType: Decodable
  var model: ConfiguratorModelType { get }
}

extension ConfiguratorProtocol {
  public static func load( _ fileName: String, _ bundle: Bundle = Bundle.main) throws -> ConfiguratorModelType {
    guard let url = bundle.url(forResource: fileName, withExtension: "plist")
    else {
      throw ConfiguratorErrors.configFileNotFound
    }

    guard let data = try? Data(contentsOf: url)
    else {
      throw ConfiguratorErrors.configInvalidPath
    }

    guard let configurator = try? PropertyListDecoder().decode(ConfiguratorModelType.self, from: data)
    else {
      throw ConfiguratorErrors.configDataMismatch
    }
    return configurator
  }
}
