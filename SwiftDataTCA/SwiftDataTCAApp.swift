//
//  SwiftDataTCAApp.swift
//  SwiftDataTCA
//
//  Created by Rodrigo Souza on 03/10/23.
//

import SwiftUI
import SwiftData

@main
struct SwiftDataTCAApp: App {
    var body: some Scene {
        WindowGroup {
            TCAContentView(store: .init(initialState: TCAContentView.Feature.State(), reducer: {
                TCAContentView.Feature()
                    ._printChanges()
            }))
        }
    }
}
