//
//  ImageViewModel.swift
//  TestTask
//
//  Created by Dmitry Kh on 11.10.22.
//

import Foundation
import Combine

enum Status {
  case initialized, loading, finished
}

final class ImageViewModel: ObservableObject {
  @Published var status: Result<Status, Error> = .success(.initialized)
  @Published var dataProgress = DataProgressEntity(data: nil, progress: Progress())
  @Published var title: String = ""

  private var fetchDataUseCase: FetchDataUseCaseProtocol
  private var model: DataRequestModel
  
  private var cancellable: AnyCancellable?

  init(model: DataRequestModel, fetchDataUseCase: FetchDataUseCaseProtocol) {
    self.model = model
    self.fetchDataUseCase = fetchDataUseCase
    title = "Download".localized + " \(model.fileName)"
  }
  
  func startLoading() {
    prepareToLoad()

    cancellable = fetchDataUseCase.fetchData(by: model.fullPath)
      .receive(on: RunLoop.main)
      .sink { [weak self] completion in
        switch completion {
        case .finished: break
        case .failure(let error):
          self?.status = .failure(error)
          return
        }
        self?.status = .success(.finished)
      } receiveValue: { [weak self] result in
        self?.dataProgress = result
      }
  }
  
  private func prepareToLoad() {
    cancellable?.cancel()
    dataProgress = DataProgressEntity(data: nil, progress: Progress())
    status = .success(.loading)
  }
}
