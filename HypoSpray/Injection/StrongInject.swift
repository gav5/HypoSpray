//
//  StrongInject.swift
//  HypoSpray
//
//  Created by Gavin Smith on 6/5/19.
//

import Foundation

@propertyDelegate struct StrongInject<Value> where Value: StrongDependency {
    let value: Value

    init() {
        value = try! DependencyContainer.shared.resolveStrong(Value.self)
    }
}
