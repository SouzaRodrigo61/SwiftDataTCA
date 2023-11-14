//
//  SwiftDataTCAApp.swift
//  SwiftDataTCA
//
//  Created by Rodrigo Souza on 03/10/23.
//

import SwiftUI
import SwiftData
import Dependencies

@main
struct SwiftDataTCAApp: App {
    @Dependency(\.databaseService) var databaseService
    var modelContext: ModelContext {
        guard let modelContext = try? self.databaseService.context() else {
            fatalError("Could not find modelcontext")
        }
        return modelContext
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                TCAContentView(store: .init(initialState: TCAContentView.Feature.State(), reducer: {
                    TCAContentView.Feature()
                        ._printChanges()
                }))
                .tabItem {
                    Label("TCAContentView", systemImage: "1.circle")
                }
                
                QueryView(store: .init(initialState: .init(), reducer: {
                    QueryReducer()._printChanges()
                }))
                .modelContext(self.modelContext)
                .tabItem {
                    Label("QueryView", systemImage: "2.circle")
                }
            }
            
        }
    }
}
