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
                .modelContainer(databaseService.container())
                .tabItem {
                    Label("QueryView", systemImage: "2.circle")
                }
            }
            
        }
    }
}
