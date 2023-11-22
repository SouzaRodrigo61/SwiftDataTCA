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
        let titleSort: TCAContentView.Feature.State.TitleSort?
        let uuidSort: TCAContentView.Feature.State.UUIDSort?
        
        var fetchDescriptor: FetchDescriptor<Movie> {
            return .init(predicate: self.predicate, sortBy: self.sort)
        }
        private var predicate: Predicate<Movie> {
            guard !searchString.isEmpty else { return #Predicate<Movie> { _ in true } }
            
            return #Predicate {
                $0.title.localizedStandardContains(searchString)
                
            }
        }
        private var sort: [SortDescriptor<Movie>] {
            return [
                self.titleSort?.descriptor,
                self.uuidSort?.descriptor
            ].compactMap { $0 }
        }
        
        init(_ state: Feature.State) {
            self.movies = state.movies
            self.searchString = state.searchString
            self.titleSort = state.titleSort
            self.uuidSort = state.uuidSort
        }
    }
    
    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            NavigationStack {
                TCAContentDataView(fetchDescriptor: viewStore.fetchDescriptor) { movies in
                    viewStore.send(.onMoviesChange(movies), animation: .default)
                }
                
                Menu("Sort", systemImage: "arrow.up.arrow.down") {
                    Picker("Title", selection: viewStore.binding(get: \.titleSort, send: { .titleSortChanged($0) }).animation()) {
                        Text("A -> Z").tag(TCAContentView_TitleSort?.some(.forward))
                        Text("Z -> A").tag(TCAContentView_TitleSort?.some(.reverse))
                        Text("❌").tag(TCAContentView_TitleSort?.none)
                    }.pickerStyle(.menu)
                    Picker("UUID", selection: viewStore.binding(get: \.uuidSort, send: { .uuidSortChanged($0) }).animation()) {
                        Text("A -> Z").tag(TCAContentView.Feature.State.UUIDSort?.some(.forward))
                        Text("Z -> A").tag(TCAContentView.Feature.State.UUIDSort?.some(.reverse))
                        Text("❌").tag(TCAContentView.Feature.State.UUIDSort?.none)
                    }.pickerStyle(.menu)
                    if viewStore.titleSort != nil || viewStore.uuidSort != nil {
                        Button("No sorting") { viewStore.send(.clearAllSorting, animation: .default) }
                    }
                }
                Text(
                    "Title: \(self.description(viewStore.titleSort)), UUID: \(self.description(viewStore.uuidSort))"
                )
                
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
                .searchable(text: viewStore.binding(get: \.searchString,
                                            send: { .searchStringChanged($0) }
                                                   ).animation(), // the animation on this Binding is not currently working
                            prompt: "Title"
                )
                .toolbar {
                    Button("Add Sample") {
                        store.send(.add)
                    }
                }
            }
        }
    }
    
    func description(_ titleSort: TCAContentView_TitleSort?) -> String {
        switch titleSort {
            case .forward: "Forward"
            case .reverse: "Reverse"
            case .none: "None"
        }
    }
    
    func description(_ uuidSort: TCAContentView_UUIDSort?) -> String {
        switch uuidSort {
            case .forward: "Forward"
            case .reverse: "Reverse"
            case .none: "None"
        }
    }
}

typealias TCAContentView_TitleSort = TCAContentView.Feature.State.TitleSort
typealias TCAContentView_UUIDSort = TCAContentView.Feature.State.UUIDSort

struct TCAContentDataView: View {
    @Query var moviesQuery: [Movie]
    let onMoviesChange: ([Movie]) -> Void
    
    init(
        fetchDescriptor: FetchDescriptor<Movie>,
        onMoviesChange: @escaping ([Movie]) -> Void
    ) {
        _moviesQuery = Query(fetchDescriptor)
        self.onMoviesChange = onMoviesChange
    }
    
    var body: some View {
        VStack { }
            .onChange(of: moviesQuery, initial: true) { oldValue, newValue in
                onMoviesChange(newValue)
            }
    }
}

extension TCAContentView {
    struct Feature: Reducer {
        struct State: Equatable {
            var movies: [Movie] = []
            var searchString: String = ""
            var titleSort: TitleSort?
            public enum TitleSort {
                case forward, reverse
                var descriptor: SortDescriptor<Movie> {
                    switch self {
                        case .forward:
                            return .init(\.title, order: .forward)
                        case .reverse:
                            return .init(\.title, order: .reverse)
                    }
                }
            }
            var uuidSort: UUIDSort?
            enum UUIDSort {
                case forward, reverse
                var descriptor: SortDescriptor<Movie> {
                    switch self {
                        case .forward: return .init(\.id, order: .forward)
                        case .reverse: return .init(\.id, order: .reverse)
                    }
                }
            }
        }
        
        enum Action: Equatable {
            case onMoviesChange([Movie])
            
            case add
            case delete(Movie)
            case favorite(Movie)
            
            case searchStringChanged(String)
            
            case titleSortChanged(TCAContentView.Feature.State.TitleSort?)
            case uuidSortChanged(TCAContentView.Feature.State.UUIDSort?)
            case clearAllSorting
        }
        
        @Dependency(\.swiftData) var context
        
        var body: some Reducer<State, Action> {
            Reduce { state, action in
                switch action {
                case .onMoviesChange(let movies):
                    state.movies = movies
                    return .none
                case .add:
                    do {
                        let randomMovieName = ["Star Wars", "Harry Potter", "Hunger Games", "Lord of the Rings"].randomElement()!
                        try context.add(.init(title: randomMovieName, cast: ["Sam Worthington", "Zoe Saldaña", "Stephen Lang", "Michelle Rodriguez"]))
                    } catch { }
                    return .none
                case .delete(let movie):
                    do {
                        try context.delete(movie)
                    } catch {
                        
                    }
                    
                    return .none
                case .favorite(let movie):
                    movie.favorite.toggle()
                    
                    return .none
                case .searchStringChanged(let newString):
                    guard newString != state.searchString else { return .none }
                        
                    state.searchString = newString
//                    state.refetchMovies()
                        
                    // Not sure why but animation doesn't appear to work unless I .run another action
                    return .none
                case .titleSortChanged(let newSort):
                    state.titleSort = newSort
                    return .none
                case .uuidSortChanged(let newSort):
                    state.uuidSort = newSort
                    return .none
                case .clearAllSorting:
                    state.uuidSort = nil
                    state.titleSort = nil
                    return .none
                }
            }
        }
    }
}

#Preview {
    TCAContentView(
        store: .init(initialState: .init(),
                     reducer: TCAContentView.Feature.init)
    )
}
