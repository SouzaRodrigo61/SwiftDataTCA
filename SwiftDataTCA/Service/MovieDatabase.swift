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
    var fetch: @Sendable () throws -> [Movie]
    var add: @Sendable (Movie) throws -> Void
    var delete: @Sendable (Movie) throws -> Void
}

extension MovieDatabase: DependencyKey {
    public static let liveValue = Self(
        fetch: {
            do {
                @Dependency(\.databaseService.context) var context
                
                let movieContext = try context()
                
                let descriptor = FetchDescriptor<Movie>(sortBy: [SortDescriptor(\.title)])
                return try movieContext.fetch(descriptor)
            } catch {
                return []
            }
        },
        add: { model in
            do {
                
                @Dependency(\.databaseService.context) var context
                
                let movieContext = try context()
                
                movieContext.insert(model)
            } catch {
                dump("catch error")
            }
        },
        delete: { model in
            do {
                @Dependency(\.databaseService.context) var context
                
                let movieContext = try context()
                
                let modelToBeDelete = model
                movieContext.delete(modelToBeDelete)
            } catch {
                dump("catch error")
            }
        }
    )
}

extension MovieDatabase: TestDependencyKey {
    public static var previewValue = Self.noop
    
    public static let testValue = Self(
        fetch: unimplemented("\(Self.self).fetch"),
        add: unimplemented("\(Self.self).add"),
        delete: unimplemented("\(Self.self).delete")
    )
    
    static let noop = Self(
        fetch: { [] },
        add: { _ in },
        delete: { _ in }
    )
}
