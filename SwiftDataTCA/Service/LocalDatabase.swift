//
//  LocalDatabase.swift
//  SwiftDataTCA
//
//  Created by Rodrigo Souza on 05/10/23.
//

import Foundation
import SwiftData
import Dependencies

extension DependencyValues {
    var swiftData: LocalStorage {
        get { self[LocalStorage.self] }
        set { self[LocalStorage.self] = newValue }
    }
}

struct LocalStorage {
    var fetch: @Sendable () throws -> [MovieTCA]
    var add: @Sendable (MovieTCA) throws -> Void
}


extension LocalStorage: DependencyKey {
    public static let liveValue = Self(
        fetch: {
            do {
                guard let context = try DatabaseService().context else { return [] }
                
                let descriptor = FetchDescriptor<MovieTCA>(sortBy: [SortDescriptor(\.title)])
                return try context.fetch(descriptor)
            } catch {
                return []
            }
        },
        add: { model in
            guard let context = try DatabaseService().context else { return }
            
            context.insert(model)
        }
    )
}

extension LocalStorage: TestDependencyKey {
    public static var previewValue = Self.noop
    
    public static let testValue = Self(
        fetch: unimplemented("\(Self.self).fetch"),
        add: unimplemented("\(Self.self).add")
    )
    
    static let noop = Self(
        fetch: { [] },
        add: { _ in }
    )
}
