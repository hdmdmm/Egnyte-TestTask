//
//  RootViewController.swift
//  TestTask
//
//  Created by Dmitry Kh on 13.10.22.
//

import Foundation
import UIKit

final class RootViewController: UIViewController {
  private var viewModel: RootViewModel
  
  @UsesSetupTableView([(cellClass: ImageTableViewCell.self, identifier: ImageTableViewCell.identifire)])
  private var tableView = UITableView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = viewModel.title
    setupLayout()
    setupStyles()
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.reloadData()
  }
  
  private func setupLayout() {
    view.addSubview(tableView)

    view.addConstraints([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0)
    ])
  }
  
  private func setupStyles() {
    view.backgroundColor = UIColor.white
  }
  
  init (viewModel: RootViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension RootViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.viewModels.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellID = ImageTableViewCell.identifire
    let cellViewModel = viewModel.viewModels[safeIndex: indexPath.row]

    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ImageTableViewCell
    else {
      let cell = ImageTableViewCell(style: .default, reuseIdentifier: cellID)
      cell.viewModel = cellViewModel
      cell.updateLayoutDelegate = self
      return cell
    }

    cell.viewModel = cellViewModel
    cell.updateLayoutDelegate = self
    return cell
  }
}

extension RootViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension RootViewController: UpdateLayoutRequestHandler {
  func restartLayout() {
    tableView.beginUpdates()
    tableView.setNeedsDisplay()
    tableView.endUpdates()
  }
}
