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
    var swiftData: MovieDatabase {
        get { self[MovieDatabase.self] }
        set { self[MovieDatabase.self] = newValue }
    }
}

struct MovieDatabase {
    var fetchAll: @Sendable () throws -> [Movie]
    var fetch: @Sendable (FetchDescriptor<Movie>) throws -> [Movie]
    var add: @Sendable (Movie) -> Void
    var delete: @Sendable (Movie) -> Void
    
    enum MovieError: Error {
        case add
        case delete
    }
}

extension MovieDatabase: DependencyKey {
    public static let liveValue = Self(
        fetchAll: {
            do {
                @Dependency(\.databaseService.context) var context
                let movieContext = context()
                
                let descriptor = FetchDescriptor<Movie>(sortBy: [SortDescriptor(\.title)])
                return try movieContext.fetch(descriptor)
            } catch {
                return []
            }
        },
        fetch: { descriptor in
            do {
                @Dependency(\.databaseService.context) var context
                let movieContext = context()
                return try movieContext.fetch(descriptor)
            } catch {
                return []
            }
        },
        add: { model in
            @Dependency(\.databaseService.context) var context
            let movieContext = context()
                
            movieContext.insert(model)
        },
        delete: { model in
            @Dependency(\.databaseService.context) var context
            let movieContext = context()
                
            let modelToBeDelete = model
            movieContext.delete(modelToBeDelete)
        }
    )
}

extension MovieDatabase: TestDependencyKey {
    
    public static let testValue = Self(
        fetchAll: unimplemented("\(Self.self).fetch"),
        fetch: unimplemented("\(Self.self).fetchDescriptor"),
        add: unimplemented("\(Self.self).add"),
        delete: unimplemented("\(Self.self).delete")
    )
    
}
