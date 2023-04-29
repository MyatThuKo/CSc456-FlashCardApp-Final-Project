import SwiftUI
import Firebase

@MainActor
class FirebaseStore: ObservableObject {

  struct Flashcard: Identifiable {
    let question: String
    let answer: String
  }

  struct FlashcardSet: Identifiable {
    let title: String
    let category: String
    let timestamp: Date
    let creatorId: String
    let flashcardSet: [Flashcard]
  }

  private var currUserId: String = ""
  @Published var isAuthenticated: Bool = false
  @Published var flashcardSets: [FlashcardSet] = []

  func fetchFlashcardSets() async throws {
  }

  func signup(email: String, password: String) async throws {
    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
      if error != nil {
        print(error?.localizedDescription ?? "")
      } else {
        self.currUserId = user.uid
        isAuthenticated = true
        try await fetchFlashcardSets()
      }
    }
  }

  func login(email: String, password: String) async throws {
    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
      if error != nil {
        print(error?.localizedDescription ?? "")
      } else {
        self.currUserId = user.uid
        isAuthenticated = true
        try await fetchFlashcardSets()
      }
    }
  }

  func logout() async throws {
    do {
      try Auth.auth().signOut()
      self.currUserId = ""
      isAuthenticated = false
      flashcardSets = []
    } catch let signOutError as NSError {
      print("Error signing out: %@", signOutError)
    }
  }

  func createFlashcardSet() async throws {
  }

  func updateFlashcardSet() async throws {
  }

  func deleteFlashcardSet() async throws {
  }
}