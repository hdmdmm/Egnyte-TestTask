//
//  PropertyWrappers.swift
//  TestTask
//
//  Created by Dmitry Kh on 11.10.22.
//

import UIKit

@propertyWrapper
public struct UsesSetupTableView<T: UITableView> {
  var cellClasses: [(cellClass: AnyClass, identifier: String)]?
  public var wrappedValue: T {
    didSet {
      setup()
    }
  }

  public init(wrappedValue: T, _ registerCellClasses: [(cellClass: AnyClass, identifier: String)]? = nil) {
    self.wrappedValue = wrappedValue
    self.cellClasses = registerCellClasses
    setup()
  }

  private func setup() {
    wrappedValue.translatesAutoresizingMaskIntoConstraints = false
    wrappedValue.backgroundColor = .clear
    wrappedValue.estimatedRowHeight = 600
    wrappedValue.separatorStyle = .none
    cellClasses?.forEach {
      wrappedValue.register($0.cellClass, forCellReuseIdentifier: $0.identifier)
    }
  }
}

@propertyWrapper
public struct UsesSetupImageView<T: UIImageView> {
  public var wrappedValue: T {
    didSet {
      setup()
    }
  }
  
  public init(wrappedValue: T) {
    self.wrappedValue = wrappedValue
    setup()
  }
  private func setup() {
    wrappedValue.translatesAutoresizingMaskIntoConstraints = false
    wrappedValue.contentMode = .scaleAspectFill
  }
}

@propertyWrapper
public struct UsesSetupButton<T: UIButton> {
  let title: String
  public var wrappedValue: T {
    didSet {
      setup()
    }
  }
  public init(wrappedValue: T, title: String) {
    self.wrappedValue = wrappedValue
    self.title = title
    setup()
  }

  private func setup() {
    wrappedValue.translatesAutoresizingMaskIntoConstraints = false
    let color = UIColor(red: 59/255.0, green: 115/255.0, blue: 180.0/255.0, alpha: 1.0)
    wrappedValue.setTitle(title, for: .normal)
    wrappedValue.setTitleColor(color, for: .normal)
    wrappedValue.titleLabel?.font = UIFont(name: "Helvetica", size: 16)
    wrappedValue.layer.cornerRadius = 8.0
    wrappedValue.layer.masksToBounds = true
    wrappedValue.layer.borderWidth = 1.0
    wrappedValue.layer.borderColor = color.cgColor
    let constraint = wrappedValue.heightAnchor.constraint(greaterThanOrEqualToConstant: 48.0)
    constraint.priority = .dragThatCannotResizeScene
    constraint.isActive = true
  }
}

@propertyWrapper
public struct UsesSetupLabel<T: UILabel> {
  let textColor: UIColor
  let font: UIFont
  let alignment: NSTextAlignment
  public var wrappedValue: T {
    didSet {
      setup()
    }
  }
  public init(wrappedValue: T,
              textColor: UIColor = .black,
              font: UIFont = UIFont.systemFont(ofSize: 14.0),
              alignment: NSTextAlignment = .left
  ) {
    self.wrappedValue = wrappedValue
    self.textColor = textColor
    self.font = font
    self.alignment = alignment
    setup()
  }
  
  private func setup() {
    wrappedValue.font = font
    wrappedValue.textColor = textColor
    wrappedValue.textAlignment = alignment
  }
}

@propertyWrapper
public struct UsesSetupProgressView<T: UIProgressView> {
  public var wrappedValue: T {
    didSet {
      setup()
    }
  }

  public init(wrappedValue: T) {
    self.wrappedValue = wrappedValue
    setup()
  }

  private func setup() {
    wrappedValue.translatesAutoresizingMaskIntoConstraints = false
    wrappedValue.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
    wrappedValue.tintColor = UIColor(red: 14/255.0, green: 26/255.0, blue: 141/255.0, alpha: 1.0)
    wrappedValue.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
  }
}

@propertyWrapper
public struct UsesSetupStackView<T: UIStackView> {
  public var wrappedValue: T {
    didSet {
      setup()
    }
  }

  public init(wrappedValue: T) {
    self.wrappedValue = wrappedValue
    setup()
  }

  private func setup() {
    wrappedValue.translatesAutoresizingMaskIntoConstraints = false
    wrappedValue.alignment = .fill
    wrappedValue.axis = .vertical
    wrappedValue.distribution = .equalCentering
    wrappedValue.spacing = 2
  }
}
