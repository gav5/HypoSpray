//
//  LazyDependency.swift
//  HypoSpray
//
//  Created by Gavin Smith on 6/5/19.
//

/// Describes a shared dependency that is lazily held within the internal container.
///
/// Instances will be generated using `init()` in response to the request for it.
public protocol LazyDependency: AnyObject {
    init()
}
