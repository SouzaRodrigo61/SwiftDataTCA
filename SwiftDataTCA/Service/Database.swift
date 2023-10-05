//
//  Database.swift
//  SwiftDataTCA
//
//  Created by Rodrigo Souza on 05/10/23.
//

import Foundation
import SwiftData

struct DatabaseService{
    var container: ModelContainer?
    var context: ModelContext?
    
    init() throws {
        do {
            container = try ModelContainer(for: MovieTCA.self)
            
            if let container {
                context = ModelContext(container)
            }
        }
        catch {
            throw DatabaseServiceError.contextMovie
        }
    }
    
    enum DatabaseServiceError: Error {
        case contextMovie
    }
}
