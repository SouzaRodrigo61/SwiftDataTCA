//
//  TCAContentView.swift
//  SwiftDataTCA
//
//  Created by Rodrigo Souza on 03/10/23.
//

import SwiftUI
import ComposableArchitecture
import SwiftData
import Dependencies

struct TCAContentView: View {
    let store: StoreOf<Feature>
    
    var body: some View {
        WithViewStore(store, observe: \.movies) { viewStore in
            NavigationStack {
                List(viewStore.state) { movie in
                    VStack(alignment: .leading) {
                        Text(movie.title)
                            .font(.headline)
                        
                        Text(movie.cast.formatted(.list(type: .and)))
                    }
                }
                .navigationTitle("MovieDB")
                .toolbar {
                    Button("Add Sample") {
                        store.send(.add)
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

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

struct Dep {
    var fetch: @Sendable () throws -> [MovieTCA]
    var add: @Sendable (MovieTCA) throws -> Void
}

extension Dep: DependencyKey {
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

extension Dep: TestDependencyKey {
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



@Model
class MovieTCA {
    var title: String
    var cast: [String]
    
    init(title: String, cast: [String]) {
        self.title = title
        self.cast = cast
    }
}

extension TCAContentView {
    struct Feature: Reducer {
        struct State: Identifiable, Equatable {
            var id = UUID()
            var movies: [MovieTCA] = []
        }
        
        enum Action: Equatable {
            case onAppear
            case add
        }
        
        @Dependency(\.swiftData) var context
        
        var body: some Reducer<State, Action> {
            Reduce { state, action in
                switch action {
                case .onAppear:
                    do {
                        state.movies = try context.fetch()
                    } catch {
                        
                    }
                    
                    return .none
                case .add:
                    do {
                        try context.add(.init(title: "Abestiado", cast: ["Sam Worthington", "Zoe Saldaña", "Stephen Lang", "Michelle Rodriguez"]))
                    } catch {
                        
                    }
                    
                    return .run { @MainActor send in
                        send(.onAppear, animation: .default)
                    }
                }
            }
            ._printChanges()
        }
    }
}


extension DependencyValues {
    var swiftData: Dep {
        get { self[Dep.self] }
        set { self[Dep.self] = newValue }
    }
}

