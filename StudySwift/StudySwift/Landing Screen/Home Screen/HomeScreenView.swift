//
//  HomeScreenView.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 5/1/23.
//

import SwiftUI

struct HomeScreenView: View {
    @EnvironmentObject var dataStoreModel: DataStoreModel
    
    @StateObject var viewModel = AddFlashcardViewModel()
    @State private var isShowingAddFlashcardSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                Image("mainLogo")
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
//                        ForEach(Array(viewModel.flashcards.keys).sorted(), id: \.self) { category in
//                            if let flashcards = viewModel.flashcards[category], !flashcards.isEmpty {
//                                NavigationLink(destination: FlashcardScreenView(viewModel: FlashcardScreenViewModel(flashcards: flashcards))) {
//                                    FlashcardCardView(title: category)
//                                }
//                            }
//                        }
                        ForEach(Array(dataStoreModel.flashcardSets.keys).sorted(), id: \.self) { category in
                            if let flashcards = dataStoreModel.flashcardSets[category], !flashcards.cards.isEmpty {
                                NavigationLink(destination: FlashcardScreenView(viewModel: FlashcardScreenViewModel(flashcards: flashcards.cards))) {
                                    FlashcardCardView(title: category)
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                Button(action: {
                    isShowingAddFlashcardSheet = true
                }) {
                    RoundedButtonView(title: "Add Flashcard")
                }
                .sheet(isPresented: $isShowingAddFlashcardSheet) {
                    AddFlashcardScreenView(viewModel: viewModel)
                }
            }
            .background(Color("inAppBGColor"))
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}
