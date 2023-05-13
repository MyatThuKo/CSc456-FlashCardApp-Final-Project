//
//  FlashcardScreenViewModel.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 5/12/23.
//

import Foundation
import SwiftUI

class FlashcardScreenViewModel: ObservableObject {
//    @Published var flashcards: [AddFlashcardViewModel.Flashcard]
    @Published var flashcards: [DataStoreModel.Flashcard]
    @Published var currentIndex = 0
    @Published var isShowingAnswer = false
    
//    init(flashcards: [AddFlashcardViewModel.Flashcard]) {
    init(flashcards: [DataStoreModel.Flashcard]) {
        self.flashcards = flashcards
    }
    
//    var currentFlashcard: AddFlashcardViewModel.Flashcard {
    var currentFlashcard: DataStoreModel.Flashcard {
        flashcards[currentIndex]
    }
    
    var canGoToPreviousFlashcard: Bool {
        currentIndex > 0
    }
    
    var canGoToNextFlashcard: Bool {
        currentIndex < flashcards.count - 1
    }
    
    func goToPreviousFlashcard() {
        guard canGoToPreviousFlashcard else { return }
        currentIndex -= 1
        isShowingAnswer = false
    }
    
    func goToNextFlashcard() {
        guard canGoToNextFlashcard else { return }
        currentIndex += 1
        isShowingAnswer = false
    }
    
    func flipFlashcard() {
        isShowingAnswer.toggle()
    }
}


