//
//  ModelMigration.swift
//  SwiftDataTCA
//
//  Created by Rodrigo Souza on 07/10/23.
//

import Foundation
import SwiftData

enum MovieSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Movie.self]
    }

    @Model
    class Movie: Identifiable {
        var id: UUID
        var title: String
        var cast: [String]
        
        init(title: String, cast: [String]) {
            self.id = UUID()
            self.title = title
            self.cast = cast
        }
    }
}

enum MovieSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Movie.self]
    }

    @Model
    class Movie: Identifiable {
        var id: UUID
        var title: String
        var cast: [String]
        var favorite: Bool = false
        
        init(title: String, cast: [String], favorite: Bool = false) {
            self.id = UUID()
            self.title = title
            self.cast = cast
            self.favorite = favorite
        }
    }
}

typealias Movie = MovieSchemaV2.Movie

enum MovieMigrationPlan: SchemaMigrationPlan {
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static var schemas: [any VersionedSchema.Type] {
        [MovieSchemaV1.self, MovieSchemaV2.self]
    }
    
    
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: MovieSchemaV1.self,
        toVersion: MovieSchemaV2.self
    )
}
