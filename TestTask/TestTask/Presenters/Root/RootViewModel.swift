//
//  RootViewModel.swift
//  TestTask
//
//  Created by Dmitry Kh on 13.10.22.
//

import Foundation
import UIKit

struct ImageNameListModel: Decodable {
  let list: [String]
  let path: String?
}

struct ImageNameSource: ConfiguratorProtocol {
  let model: ImageNameListModel
  
  init(fileName: String) throws {
    model = try Self.load(fileName)
  }
}

struct RootViewModel {
  let viewModels: [ImageViewModel]
  let title: String

  init(source: ImageNameSource, fetchDataUseCase: FetchDataUseCaseProtocol) {
    self.viewModels = source.model.list
      .map { name -> ImageViewModel in
        let model = DataRequestModel(path: source.model.path, fileName: name)
        return ImageViewModel(model: model, fetchDataUseCase: fetchDataUseCase)
      }
    title = "Random Photos".localized
  }
}
