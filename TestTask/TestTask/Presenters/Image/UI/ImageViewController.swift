//
//  ImageViewController.swift
//  TestTask
//
//  Created by Dmitry Kh on 11.10.22.
//

import UIKit
import SwiftUI
import Combine

class ImageViewController : UIViewController {
  @ObservedObject
  var viewModel: ImageViewModel
  private var cancellables: [AnyCancellable] = []
  
  @UsesSetupImageView
  private var imageView = UIImageView()
  @UsesSetupButton(title: "Download".localized)
  private var button = UIButton()
  @UsesSetupProgressView
  private var progressView = UIProgressView()
  @UsesSetupLabel(alignment: .right)
  private var progressLabel = UILabel()
  @UsesSetupStackView
  private var progressStackView = UIStackView()
  @UsesSetupStackView
  private var stackView = UIStackView()

  override func viewDidLoad() {
    super.viewDidLoad()
  
    setupViews()
    setupLayout()
    setupStyles()
    setupStatements(isLoading: false)
    setupHandlers()
    setupBindings()
  }

  private func setupViews() {
    progressStackView.addArrangedSubviews([progressView, progressLabel])
    stackView.addArrangedSubviews([button, progressStackView])
    
    view.addSubview(imageView)
    view.addSubview(stackView)
  }

  private func setupLayout() {
    view.addConstraints([
      imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 4.0),
      imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -4.0),
      
      stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16.0),
      stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16.0),
      stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16.0),
      stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }

  private func setupStyles() {
    view.backgroundColor = UIColor.white
    imageView.backgroundColor = UIColor.orange.withAlphaComponent(0.05)
  }
  
  private func setupBindings() {
    viewModel.$dataProgress
      .map { UIImage(data: $0.data ?? Data()) }
      .assign(to: \.image, on: imageView)
      .store(in: &cancellables)
    
    let progressPublisher = viewModel.$dataProgress
      .map { Float($0.progress.fractionCompleted) }
    
    progressPublisher
      .assign(to: \.progress, on: progressView)
      .store(in: &cancellables)
    
    progressPublisher
      .map{ "\(Int($0 * 100))%" }
      .assign(to: \.text, on: progressLabel)
      .store(in: &cancellables)
    
    viewModel.$status
      .map { result -> Bool in
        switch result {
        case .success(let status):
          return status == .loading
        default:
          return false
        }
      }
      .sink(receiveValue: setupStatements(isLoading:))
      .store(in: &cancellables)
    
    viewModel.$status
      .map { result -> Error? in
        switch result {
        case .failure(let error): return error
        default: return nil
        }
      }
      .compactMap { $0 }
      .map { $0.localizedDescription }
      .sink(receiveValue: { [weak self] message in
        self?.alert(message: message)
      })
      .store(in: &cancellables)
  }

  private func setupStatements(isLoading: Bool) {
    progressStackView.isHidden = !isLoading
    button.isHidden = isLoading
  }

  private func setupHandlers() {
    let downloadAction = UIAction(handler: { [weak self] _ in
      self?.viewModel.startLoading()
    })

    button.addAction(downloadAction, for: .touchUpInside)
  }
  
  
  init(viewModel: ImageViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ImageViewController: Alertable {}

