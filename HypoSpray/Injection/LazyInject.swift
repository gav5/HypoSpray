//
//  LazyInject.swift
//  HypoSpray
//
//  Created by Gavin Smith on 6/5/19.
//

@propertyDelegate struct LazyInject<Value> where Value: LazyDependency {
    let value: Value

    init() {
        value = try! DependencyContainer.shared.resolveLazy(Value.self)
    }
}
