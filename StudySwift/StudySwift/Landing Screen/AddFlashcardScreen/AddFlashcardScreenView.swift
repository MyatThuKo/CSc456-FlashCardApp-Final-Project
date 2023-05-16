//
//  AddFlashcardScreenView.swift
//  StudySwift
//
//  Created by Myat Thu Ko on 5/12/23.
//

import SwiftUI

struct AddFlashcardScreenView: View {
    @EnvironmentObject var dataStoreModel: DataStoreModel
    @ObservedObject var viewModel: AddFlashcardViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var question: String = ""
    @State private var answer: String = ""
    @State private var category: String = ""
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            Color("inAppBGColor")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 25) {
                TextField("Question", text: $question)
                    .textFieldStyle(RoundedTextFieldStyle())
                    .textInputAutocapitalization(.none)
                
                TextField("Answer", text: $answer)
                    .textFieldStyle(RoundedTextFieldStyle())
                
                TextField("Category", text: $category)
                    .textFieldStyle(RoundedTextFieldStyle())
                
                Button {
                    if !question.isEmpty && !answer.isEmpty && !category.isEmpty {
                        dataStoreModel.addFlashcardToCategory(category: category, question: question, answer: answer)
                        question = ""
                        answer = ""
                        category = ""
                        presentationMode.wrappedValue.dismiss()
                        print("Flashcards: \(dataStoreModel.flashcardSets.count)")
                        print("FLashcard: \(dataStoreModel.flashcardSets.values.count)")
                    } else {
                        showAlert = true
                    }
                } label: {
                    RoundedButtonView(title: "Add Flashcard")
                }
            }
            .padding(.horizontal, 16)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Validation Error"), message: Text("Please fill in all fields"), dismissButton: .default(Text("OK")))
        }
    }
}




struct AddFlashcardScreenView_Previews: PreviewProvider {
    static var previews: some View {
        AddFlashcardScreenView(viewModel: AddFlashcardViewModel())
    }
}
