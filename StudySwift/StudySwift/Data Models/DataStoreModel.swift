//
//  DataStoreModel.swift
//  StudySwift
//
//  Created by Anthony Liang on 5/11/23.
//

import Foundation
import Firebase
import FirebaseFunctions

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
    
    private lazy var functions = Functions.functions()
    
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
    
    func createFlashcardSet(title: String, category: String, flashcards: [Flashcard]) {
        functions.httpsCallable("addFlashcardSet")
            .call(["title": title, "category": category, "cards": flashcards]) { (result, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Successfully created flashcard set.")
                    if let data = result?.data as? [String: Any] {
                        let newFCSet = FlashcardSet(flashcardId: data["flashcardId"] as? String ?? "",
                                                    title: data["title"] as? String ?? "",
                                                    category: data["category"] as? String ?? "",
                                                    timestamp: data["timestamp"] as? Int ?? 0,
                                                    creatorId: data["creatorId"] as? String ?? "",
                                                    flashcardSet: flashcards)
                        self.flashcardSets.append(newFCSet)
                    }
                }
            }
    }
    
    func updateFlashcardSet(flashcardId: String, title: String, category: String, flashcards: [Flashcard]) {
        functions.httpsCallable("updateFlashcardSet")
            .call(["flashcardId": flashcardId, "title": title, "category": category,
                   "cards": flashcards]) { (result, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Successfully updated flashcard set.")
                    if let data = result?.data as? [String: Any] {
                        let updFCSet = FlashcardSet(flashcardId: data["flashcardId"] as? String ?? "",
                                                    title: data["title"] as? String ?? "",
                                                    category: data["category"] as? String ?? "",
                                                    timestamp: data["timestamp"] as? Int ?? 0,
                                                    creatorId: data["creatorId"] as? String ?? "",
                                                    flashcardSet: flashcards)
                        if let index = self.flashcardSets.firstIndex(where: { $0.flashcardId == flashcardId }) {
                            self.flashcardSets.remove(at: index) // Remove old entry
                        }
                        self.flashcardSets.append(updFCSet)
                    }
                }
            }
    }

    func deleteFlashcardSet(flashcardId: String) {
        functions.httpsCallable("deleteFlashcardSet").call(["flashcardId": flashcardId]) { (result, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let data = result?.data as? [String: Any] {
                        let message = data["message"] as? String ?? ""
                        print(message)
                        if message == "The flashcardset was sent to the trash." {
                            if let index = self.flashcardSets.firstIndex(where: { $0.flashcardId == flashcardId }) {
                                let trashedEntry = self.flashcardSets[index]
                                self.flashcardSets.remove(at: index)
                                self.trash.append(trashedEntry)
                            }
                        } else {
                            if let index = self.trash.firstIndex(where: { $0.flashcardId == flashcardId }) {
                                self.trash.remove(at: index)
                            }
                        }
                    }
                }
            }
    }
    
    func clearFlashcards() {
        print("Cleared flashcard sets...")
        flashcardSets.removeAll()
        trash.removeAll()
    }
    
    static let sharedInstance = DataStoreModel()
}
