//
//  DataStoreModel.swift
//  StudySwift
//
//  Created by Anthony Liang on 5/11/23.
//

import Foundation
import Firebase

class DataStoreModel: ObservableObject {
    // Flashcard code to make things simplier
    struct Flashcard: Codable, Hashable {
        let question: String
        let answer: String
    }
    
    struct FlashcardSet: Codable, Hashable {
        let flashcardId: String
        let title: String
        let category: String
        let timestamp: Int
        let creatorId: String
        let flashcardSet: [Flashcard]
    }
    
    @Published var flashcardSets: [FlashcardSet] = []
    @Published var trash: [FlashcardSet] = []
    
    func fetchFlashcards() {
        let currUserId: String = Auth.auth().currentUser?.uid ?? "no-id"
        print("Fetching flashcard sets for user: (\(currUserId))...")
        
        self.flashcardSets.removeAll()
        self.trash.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("flashcards").whereField("creatorId", isEqualTo: currUserId)
        
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print("Fetch Error: \(error!.localizedDescription)")
                return
            }
            
            print("Successfully obtained snapshot")
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    
                    var fcs: [Flashcard] = []
                    for fc in data["cards"] as? [NSDictionary] ?? [] {
                        fcs.append(Flashcard(question: fc["question"] as! String,
                                             answer: fc["answer"] as! String))
                    }
                    
                    let fcSet = FlashcardSet(flashcardId: id,
                                             title: data["title"] as? String ?? "",
                                             category: data["category"] as? String ?? "",
                                             timestamp: data["timestamp"] as? Int ?? 0,
                                             creatorId: data["creatorId"] as? String ?? "",
                                             flashcardSet: fcs)
                    
                    // Add flashcard set to "trash" if "toBeDeleted" is defined & true
                    if data["toBeDeleted"] as? Bool ?? false {
                        self.trash.append(fcSet)
                    } else {
                        self.flashcardSets.append(fcSet)
                    }
                    
                    print("Id: \(id), Data: \(data)")
                }
            }
            print("Flashcard Sets:", self.flashcardSets)
            print("Trash:", self.trash)
        }
    }
    
    func createFlashcardSet() {
        
    }
    
    func updateFlashcardSet() {
        
    }

    func deleteFlashcardSet() {
        
    }
    
    func clearFlashcards() {
        print("Cleared flashcard sets...")
        flashcardSets.removeAll()
        trash.removeAll()
    }
    
    static let sharedInstance = DataStoreModel()
}
