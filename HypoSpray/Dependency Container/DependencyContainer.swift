//
//  DependencyContainer.swift
//  HypoSpray
//
//  Created by Gavin Smith on 6/5/19.
//

import Dispatch

internal final class DependencyContainer {

    // MARK: - Container Instance Creation

    /// Initializes a new instance.
    ///
    /// Should never be called outside generation of `shared`.
    private init() {}

    /// Returns the designated shared instance of `DependencyContainer`.
    ///
    /// This should be used in place of `init()`.
    static let shared = Self()

    // MARK: - Properties (Private)

    /// Holds the entries for the provided keys.
    private var entries: [EntryKey: Entry]

    private let dispatchQueue = DispatchQueue.global()
}

// MARK: - Resolving Instances

extension DependencyContainer {

    func resolveStrong<Value>(_ type: Value.Type) throws -> Value where Value: StrongDependency {
        let theKey = EntryKey(Value.self)
        guard var entry = entries[theKey] else {
            throw ResolveError.strongInstanceNeverProvided
        }
        let resolvedValue = try entry.resolve(Value.self)
        entries[theKey] = entry
        return resolvedValue
    }

    func resolveLazy<Value>(_ type: Value.Type) throws -> Value where Value: LazyDependency {
        let theKey = EntryKey(Value.self)

        var entry: Entry
        if let theEntry = entries[theKey] {
            entry = theEntry
        } else {
            entry = Entry(isMock: false, registration: .instance(Value()))
        }
        let resolvedValue = try entry.resolve(Value.self)
        entries[theKey] = entry
        return resolvedValue
    }
}

// MARK: - Providing a Builder

extension DependencyContainer {

    func provide<Value>(_ type: Value.Type, with builder: @escaping () -> Value) where Value: StrongDependency {
        let theKey = EntryKey(Value.self)

        // build the instance and store internally for later use
        if let entry = entries[theKey] {
            assert(entry.isMock, "should not have actual instances already registered")
            // let this stay as-is, it should be a mock (or can assume what is was is good enough)
        } else {
            // should store this entry as a factory
            entries[theKey] = Entry(isMock: false, registration: .factory(builder))
        }
    }
}

// MARK: - Mocking

extension DependencyContainer {

    func mock<Value>(_ mockedValue: Value) where Value: StrongDependency {
        mockInternal(mockedValue)
    }

    func mock<Value>(_ mockedValue: Value) where Value: LazyDependency {
        mockInternal(mockedValue)
    }

    private func mockInternal<Value>(_ mockedValue: Value) where Value: AnyObject {
        let theKey = EntryKey(Value.self)

        #if DEVELOP
        if let entry = entries[theKey] {
            if entry.isMock {
                assertionFailure("should not overwrite an existing mock")
            } else if case .instance = entry.registration {
                assertionFailure("mocking after instance has already been resolved is a bad idea")
            }
        }
        #endif
        entries[theKey] = Entry(isMock: true, registration: .instance(mockedValue))
    }
}

// MARK: - EntryKey Subtype Declaration (Private)

extension DependencyContainer {
    private struct EntryKey: Hashable, Equatable {
        let value: String

        init<Value>(_ type: Value.Type) {
            value = String(describing: Value.self)
        }
    }
}

// MARK: - Entry Subtype Declaration (Private)

extension DependencyContainer {
    private struct Entry {
        var isMock: Bool
        var registration: Registration
    }
}

// MARK: - Resolving Entries

extension DependencyContainer.Entry {

    mutating func resolve<Value>(_ type: Value.Type) throws -> Value {
        try registration.resolve(Value.self)
    }
}

// MARK: - Registration Subtype Declaration (Private)

extension DependencyContainer {
    private enum Registration {
        case factory(() -> AnyObject)
        case instance(AnyObject)
    }
}

// MARK: - Resolving Registrations

extension DependencyContainer.Registration {

    mutating func resolve<Value>(_ type: Value.Type) throws -> Value {
        switch self {
        case .factory(let factory):
            let newInstance = factory()
            let typedInstance = try encode(anyObject: newInstance, as: Value.self)
            self = .instance(typedInstance as AnyObject)
            return typedInstance
        case .instance(let existingInstance):
            return try encode(anyObject: existingInstance, as: Value.self)
        }
    }

    private func encode<Value>(anyObject: AnyObject, as type: Value.Type) throws -> Value {
        guard let typedObject = anyObject as? Value else {
            assertionFailure("instance \(anyObject) not of expected type \(Value.self)")
            throw ResolveError.instanceOfIncorrectType
        }
        return typedObject
    }
}

// MARK: - ResolveError Subtype Declaration

extension DependencyContainer {
    private enum ResolveError: Error {
        case instanceOfIncorrectType
        case strongInstanceNeverProvided
    }
}
