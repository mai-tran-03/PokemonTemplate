//
//  ContentView.swift
//  PokemonTemplate
//
//  Created by Mark Kinoshita on 8/13/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PokemonViewModel()
    @State private var searchText = ""
    
    var searchedPokemon: [PokemonEntry] {
        if searchText.isEmpty {
            return viewModel.pokemons
        } else {
            return viewModel.pokemons.filter { $0.name.lowercased().contains(searchText.lowercased())}
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(searchedPokemon, id: \.id) { pokemon in
                    NavigationLink(value: pokemon) {
                        let imageURL = viewModel.pokemonSprites[pokemon.url]?.front_default
                        
                        PokemonRow(pokemon: pokemon, imageURL: imageURL)
                            .onAppear {
                                viewModel.fetchPokemonSprites(for: pokemon.url)
                            }
                        }
                    .onAppear {
                        if pokemon == viewModel.pokemons.last {
                            viewModel.loadMorePokemons()
                        }
                    }
                    
                }
            }
            .navigationDestination(for: PokemonEntry.self) { selectedPokemon in
                PokemonDetailView(pokemon: viewModel.selectedPokemonDetail ?? PokemonDetailResponse(name: "", height: 0, weight: 0, abilities: [], sprites: PokemonDetailResponse.defaultSprites, types: []))
                    .onAppear {
                        viewModel.fetchPokemonDetails(for: selectedPokemon.url)
                    }
            }
            .navigationTitle("Pokémon List")

            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }
        }
        .searchable(text: $searchText, prompt: "Search for Pokémon")
    }
}

#Preview {
    ContentView()
}
