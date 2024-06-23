//
//  Database.swift
//  SwiftDataTCA
//
//  Created by Rodrigo Souza on 05/10/23.
//

import Foundation
import SwiftData
import Dependencies

extension DependencyValues {
    var databaseService: Database {
        get { self[Database.self] }
        set { self[Database.self] = newValue }
    }
}

fileprivate let liveContext: ModelContext = {
    ModelContext(liveContainer)
}()

fileprivate let previewContext: ModelContext = {
    ModelContext(previewContainer)
}()

fileprivate let liveContainer: ModelContainer = {
    do {
        let url = URL.applicationSupportDirectory.appending(path: "Model.sqlite")
        let config = ModelConfiguration(url: url)
        
        return try ModelContainer(for: Movie.self, migrationPlan: MovieMigrationPlan.self, configurations: config)
    } catch {
        fatalError("Failed to create live container.")
    }
}()

fileprivate let previewContainer: ModelContainer = {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: Movie.self, migrationPlan: MovieMigrationPlan.self, configurations: config)
    } catch {
        fatalError("Failed to create preview container.")
    }
}()

struct Database {
    var context: @Sendable () -> ModelContext
    var container: @Sendable () -> ModelContainer
}

extension Database: DependencyKey {
    public static let liveValue = Self(
        context: { liveContext },
        container: { liveContainer }
    )
}

extension Database: TestDependencyKey {
    public static var previewValue = Self.inMemory
    
    public static let testValue = Self.inMemory
    
    private static let inMemory = Self(
        context: { previewContext },
        container: { previewContainer }
    )
}
