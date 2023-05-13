const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(); // Initiate Firebase Admin in index.js file

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

/* Export functions in different files */
const {
  addFlashcardSet,
  updateFlashcardSet,
  deleteFlashcardSet,
  recoverFlashcardSet,
  addFCToCategory,
} = require("./src/controllers/flashcard");

exports.addFlashcardSet = addFlashcardSet;
exports.updateFlashcardSet = updateFlashcardSet;
exports.deleteFlashcardSet = deleteFlashcardSet;
exports.recoverFlashcardSet = recoverFlashcardSet;
exports.addFCToCategory = addFCToCategory;


const {newUserSignup} = require("./src/controllers/user");
exports.newUserSignup = newUserSignup;
