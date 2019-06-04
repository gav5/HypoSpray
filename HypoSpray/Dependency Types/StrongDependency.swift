//
//  StrongDependency.swift
//  HypoSpray
//
//  Created by Gavin Smith on 6/5/19.
//

/// Describes a shared dependency that is strongly held within the internal container.
///
/// Instances will be expected to be provided upfront.
public protocol StrongDependency: AnyObject {}
