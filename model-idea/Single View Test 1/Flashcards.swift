
import UIKit


// Flashcard model
struct Flashcard {
    var text: String
    var info: String
}

// View controller for displaying flashcards
class FlashcardViewController: UIViewController {
    // Array to hold flashcards
    var flashcards = [Flashcard]()
    
    // Table view to display flashcards
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load any saved flashcards
        loadFlashcards()
    }
    
    // Add a new flashcard
    func addFlashcard(text: String, info: String) {
        let flashcard = Flashcard(text: text, info: info)
        flashcards.append(flashcard)
        saveFlashcards()
        tableView.reloadData()
    }
    
    // Edit an existing flashcard
    func editFlashcard(at index: Int, newText: String, newInfo: String) {
        flashcards[index].text = newText
        flashcards[index].info = newInfo
        saveFlashcards()
        tableView.reloadData()
    }
    
    // Delete a flashcard
    func deleteFlashcard(at index: Int) {
        flashcards.remove(at: index)
        saveFlashcards()
        tableView.reloadData()
    }
    
    // Load saved flashcards
    func loadFlashcards() {
        // Load saved flashcards from disk or use default values
        // ...
    }
    
    // Save flashcards
    func saveFlashcards() {
        // Save flashcards to disk
        // ...
    }
    
    // Handle "Add" button
    @IBAction func addFlashcardButtonPressed(_ sender: UIButton) {
        let addFlashcardVC = AddFlashcardViewController()
        addFlashcardVC.delegate = self
        present(addFlashcardVC, animated: true, completion: nil)
    }
    
    // Handle "Edit" button
    @IBAction func editFlashcardButtonPressed(_ sender: UIButton) {
        // Implement edit flashcard functionality
    }
}

// View controller for adding a new flashcard
class AddFlashcardViewController: UIViewController {
    // Text fields for entering flashcard data
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    
    // Delegate for adding new flashcards
    var delegate: FlashcardViewController?
    
    // Handle "Add" button
    @IBAction func addButtonPressed(_ sender: UIButton) {
        let text = textField1.text ?? ""
        let info = textField2.text ?? ""
        delegate?.addFlashcard(text: text, info: info)
        dismiss(animated: true, completion: nil)
    }
    
    // Handle "Cancel" button
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
