//
//  HypoSpray.swift
//  HypoSpray
//
//  Created by Gavin Smith on 6/3/19.
//

struct Dependency {
    private init() { /* this is a namespace and should never be initialized */ }

    static func mock<Value>(_ mockedValue: Value) where Value: StrongDependency {
        DependencyContainer.shared.mock(mockedValue)
    }

    static func mock<Value>(_ mockedValue: Value) where Value: LazyDependency {
        DependencyContainer.shared.mock(mockedValue)
    }

    static func provide<Value>(_ type: Value.Type, with builder: @escaping @autoclosure () -> Value) where Value: StrongDependency {
        DependencyContainer.shared.provide(Value.self, with: { builder() })
    }
}
