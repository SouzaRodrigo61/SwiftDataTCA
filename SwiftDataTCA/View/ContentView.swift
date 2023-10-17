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
    
    struct ViewState: Equatable {
        let movies: [Movie]
        let searchString: String
        
        init(_ state: Feature.State) {
            self.movies = state.movies
            self.searchString = state.searchString
        }
    }
    
    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            NavigationStack {
                List(viewStore.movies) { movie in
                    VStack(alignment: .leading) {
                        Text(movie.id.uuidString)
                        
                        Text(movie.title)
                            .font(.headline)
                        
                        Text(movie.cast.formatted(.list(type: .and)))
                    }
                    .background(movie.favorite ? .blue : .clear)
                    .swipeActions {
                        Button(role: .destructive) {
                            store.send(.delete(movie), animation: .snappy)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            store.send(.favorite(movie), animation: .bouncy)
                        } label: {
                            Label(
                                movie.favorite ? "Unfavorite" : "Favorite",
                                systemImage: "star"
                            ).foregroundStyle(.blue)
                        }
                    }
                }
                .navigationTitle("SwiftData")
                .searchable(
                    text: viewStore.binding(get: \.searchString,
                                            send: {
                                                .searchStringChanged($0)
                                            }),
                    prompt: "Title"
                )
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

extension TCAContentView {
    struct Feature: Reducer {
        struct State: Equatable {
            var movies: [Movie] = []
            var searchString: String = ""
            var predicate: Predicate<Movie> {
                guard !searchString.isEmpty else { return #Predicate<Movie> { _ in true } }
                
                return #Predicate {
                    $0.title.localizedStandardContains(searchString)
                }
            } 
        }
        
        enum Action: Equatable {
            case onAppear
            
            case add
            case delete(Movie)
            case favorite(Movie)
            
            case searchStringChanged(String)
        }
        
        @Dependency(\.swiftData) var context
        
        var body: some Reducer<State, Action> {
            Reduce { state, action in
                switch action {
                case .onAppear:
                    do {
                        state.movies = try context.fetchAll()
                    } catch {
                        
                    }
                    
                    return .none
                case .add:
                    do {
                        let randomMovieName = ["Star Wars", "Harry Potter", "Hunger Games", "Lord of the Rings"].randomElement()!
                        try context.add(.init(title: randomMovieName, cast: ["Sam Worthington", "Zoe Saldaña", "Stephen Lang", "Michelle Rodriguez"]))
                    } catch {
                        
                    }
                    
                    return .run { @MainActor send in
                        send(.onAppear, animation: .default)
                    }
                case .delete(let movie):
                    do {
                        try context.delete(movie)
                    } catch {
                        
                    }
                    
                    return .run { @MainActor send in
                        send(.onAppear, animation: .default)
                    }
                case .favorite(let movie):
                    movie.favorite.toggle()
                    
                    return .none
                case .searchStringChanged(let newString):
                    guard newString != state.searchString else { return .none }
                        
                    state.searchString = newString
                    do {
                        let descriptor = FetchDescriptor(predicate: state.predicate)
                        state.movies = try context.fetch(descriptor)
                    } catch {
                        
                    }
                        
                    return .none
                }
            }
        }
    }
}
