//
//  AddFlashcardViewModel.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 5/12/23.
//

import Foundation
import SwiftUI

class AddFlashcardViewModel: ObservableObject {
    struct Flashcard: Hashable {
        let question: String
        let answer: String
        let category: String
        
        init(question: String, answer: String, category: String) {
            self.question = question
            self.answer = answer
            self.category = category
        }
    }
    
    @Published var flashcards: [String: [Flashcard]] = [:]
    
    func addFlashcard(question: String, answer: String, category: String) {
        let newFlashcard = Flashcard(question: question, answer: answer, category: category)
        
        if var flashcardsForCategory = flashcards[category] {
            flashcardsForCategory.append(newFlashcard)
            flashcards[category] = flashcardsForCategory
        } else {
            flashcards[category] = [newFlashcard]
        }
    }

}
