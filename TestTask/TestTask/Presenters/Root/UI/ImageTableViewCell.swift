//
//  ImageTableViewCell.swift
//  TestTask
//
//  Created by Dmitry Kh on 13.10.22.
//

import UIKit
import Combine

protocol UpdateLayoutRequestHandler: AnyObject {
  func restartLayout()
}

final class ImageTableViewCell: UITableViewCell {
  static let identifire = "ImageTabeleViewCell"
  var viewModel: ImageViewModel? {
    didSet {
      setupBindings()
    }
  }
  weak var updateLayoutDelegate: UpdateLayoutRequestHandler?
  
  @UsesSetupProgressView
  private var progressView = UIProgressView()
  @UsesSetupLabel(alignment: .right)
  private var progressLabel = UILabel()
  @UsesSetupStackView
  private var progressStackView = UIStackView()
  @UsesSetupImageView
  private var imgView = UIImageView()
  @UsesSetupButton(title: "Download".localized)
  private var button = UIButton()
  @UsesSetupStackView
  private var contentStackView = UIStackView()
  @UsesSetupStackView
  private var containerStackView = UIStackView()
  
  private var cancellables: [AnyCancellable] = []
  
  private func setupViews() {
    backgroundColor = UIColor.orange.withAlphaComponent(0.05)

    contentStackView.addArrangedSubviews([imgView, button])
    progressStackView.addArrangedSubviews([progressView, progressLabel])
    containerStackView.addArrangedSubviews([progressStackView, contentStackView])
    contentView.addSubview(containerStackView)

    contentView.addConstraints([
      containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
      containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
      containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    ])
  }
  
  private func setupStatement(status: Status) {
    imgView.isHidden = status == .initialized
    progressStackView.isHidden = !(status == .loading)
    contentStackView.isHidden = status == .loading
  }
  
  private func setupActions() {
    let action = UIAction { [weak self] _ in
      self?.viewModel?.startLoading()
      self?.updateLayoutDelegate?.restartLayout()
    }
    button.addAction(action, for: .touchUpInside)
  }
  
  private func setupBindings() {
    cancellables.forEach { $0.cancel() }
    cancellables = []
    
    guard let viewModel = viewModel else {
      return
    }

    viewModel.$dataProgress
      .map { UIImage(data: $0.data ?? Data()) }
      .sink(receiveValue: { [weak self] image in
        self?.imgView.image = image
        self?.updateLayoutDelegate?.restartLayout()
      })
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
      .map { result -> Status in
        switch result {
        case .success(let status):
          return status
        case .failure:
          return Status.initialized
        }
      }
      .sink { [weak self] status in
        self?.setupStatement(status: status)
        self?.updateLayoutDelegate?.restartLayout()
      }
      .store(in: &cancellables)
    
    viewModel.$title
      .sink { [button] title in
        button.setTitle(title, for: .normal)
      }
      .store(in: &cancellables)
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupViews()
    setupStatement(status: .initialized)
    setupActions()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
