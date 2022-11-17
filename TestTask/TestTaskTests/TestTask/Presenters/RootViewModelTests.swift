//
//  RootViewModelTests.swift
//  TestTaskTests
//
//  Created by Dmitry Kh on 19.10.22.
//

import XCTest
import Combine
@testable import TestTask

class RootViewModelTests: XCTestCase {

  func testRootViewModel_Initialization() throws {
    // Given
    let nameSource = try ImageNameSource(fileName: "images")
    
    // When
    let rootViewModel = RootViewModel(source: nameSource, fetchDataUseCase: MockFetchDataUseCase())
    
    // Then
    XCTAssertEqual(rootViewModel.viewModels.count, 9)
    XCTAssertFalse(rootViewModel.title.isEmpty)

    for viewModel in rootViewModel.viewModels {
      let status = try viewModel.status.get()
      XCTAssertEqual(status, .initialized)

      let dataProgress = viewModel.dataProgress
      XCTAssertEqual(dataProgress.progress.fractionCompleted, 0.0)
      XCTAssertNil(dataProgress.data)

      XCTAssertFalse(viewModel.title.isEmpty)
    }
  }
}

class MockFetchDataUseCase: FetchDataUseCaseProtocol {
  var dataProgressEntity: DataProgressEntity?
  var error: Error?

  func fetchData(by resourceName: String) -> AnyPublisher<DataProgressEntity, Error> {

    guard let error = error else {
      return Just( dataProgressEntity ?? DataProgressEntity(data: nil, progress: Progress()) )
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }

    return Fail(error: error).eraseToAnyPublisher()
  }
}
