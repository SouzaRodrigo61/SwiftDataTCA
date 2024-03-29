//
//  QueryView.swift
//  SwiftDataTCA
//
//  Created by Daniel Lyons on 11/8/23.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import SwiftData
import Dependencies

struct QueryView: View {
    let store: StoreOf<QueryReducer>
    
    
    @Query(FetchDescriptor<Movie>()) var moviesQuery: [Movie] {
        didSet {
            store.send(.queryChangedMovies(self.allMovies))
        }
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    ForEach(self.moviesQuery) { movie in
                        VStack {
                            Text("\(movie.title)").font(.title)
                            Text("\(movie.id)")
                        }
                        .background(movie.favorite ? .blue : .clear)
                        .swipeActions {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                viewStore.send(.delete(movie), animation: .snappy)
                            }
                            Button("Toggle Favorite", systemImage: "star") {
                                viewStore.send(.favorite(movie), animation: .snappy)
                            }
                        }
                    }
                }
                .navigationTitle("Movies Query")
                .toolbar {
                    Button("Add sample", systemImage: "plus") {
                        viewStore.send(.addMovie, animation: .snappy)
                    }
                }
            }
        }
    }
}

struct QueryReducer: Reducer {
    struct State: Equatable {
        var movies: [Movie] = []
    }
    
    enum Action: Equatable {
        case queryChangedMovies([Movie])
        case addMovie
        case delete(Movie)
        case favorite(Movie)
    }
    
    @Dependency(\.swiftData) var database
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .queryChangedMovies(let newMovies):
                    state.movies = newMovies
                    return .none
                case .addMovie:
                let randomMovieName = ["Star Wars", "Harry Potter", "Hunger Games", "Lord of the Rings"].randomElement()!
                database.add(.init(title: randomMovieName, cast: ["Sam Worthington", "Zoe Saldaña", "Stephen Lang", "Michelle Rodriguez"]))
                return .none
                case .delete(let movieToDelete):
                database.delete(movieToDelete)
                return .none
                case .favorite(let movieToFavorite):
                movieToFavorite.favorite.toggle()
                return .none
            }
        }
    }
}
