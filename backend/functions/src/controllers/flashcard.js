const functions = require("firebase-functions");
const admin = require("firebase-admin");

const myUtils = require("../utils.js");


// "cu" = Create & Update
const cuValidation = (data, context, withId = false) => {
  const word = withId? "update" : "create";
  if (!context.auth) {
    const errMsg = `You must be authenticated to ${word} a flashcard set.`;
    throw new functions.https.HttpsError("unauthenticated", errMsg);
  }
  // Make sure required fields are provided
  const requiredFields = withId ?
                        ["flashcardId", "title", "category", "cards"] :
                        ["title", "category", "cards"];

  requiredFields.forEach((field) => {
    if (!data[field]) {
      const errMsg = `The "${field}" field must be provided.`;
      throw new functions.https.HttpsError("invalid-argument", errMsg);
    }
  });

  // Valdiate each field
  if (!myUtils.isStrBetween(data.title, 1, 30)) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "The \"title\" field must be a string between 1-30 characters.",
    );
  }
  if (!myUtils.isStrBetween(data.category, 1, 30)) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "The \"category\" field must be a string between 1-30 characters.",
    );
  }
  if (
    !Array.isArray(data.cards) ||
      data.cards.length === 0 ||
      !myUtils.arrayOfObjContainKeys(data.cards, ["question", "answer"])
  ) {
    const errMsg =
        "The \"cards\" field must be a non-empty array of objects with keys" +
        " \"question\" and \"answer\" with non-empty string values.";
    throw new functions.https.HttpsError("invalid-argument", errMsg);
  }
};

// helper function to format data to be added/updated in the database
const formatFlashcardSetData = (userId, data) => {
  const flashcardSetMetaData = {
    title: data.title.trim(),
    category: data.category.trim(),
    timestamp: Date.now(),
  };
  return {
    flashcardSetMetaData,
    flashcardSet: {
      cards: data.cards.map((obj) => ({
        question: obj.question.trim(),
        answer: obj.answer.trim(),
      })),
      ...flashcardSetMetaData,
    },
  };
};

/*
  Cloud Function to create a flashcard set as an authenticated user.

  Expected input:
    - "title" <string (1-30 characters)>
    - "category" <string (1-30 characters)>
    - "cards" []
      - "question" <string (1+ characters)>
      - "answer" <string (1+ characters)>
*/
exports.addFlashcardSet = functions.https.onCall(async (data, context) => {
  const withId = false;
  cuValidation(data, context, withId);

  // Format data to be added into database
  const {
    flashcardSetMetaData,
    flashcardSet,
  } = formatFlashcardSetData(context.auth.uid, data);

  try {
    // Add document to "flashcard" database
    const docRef = await admin
        .firestore()
        .collection("flashcards")
        .add(flashcardSet);
    // Add reference to flashcard set to creator in "users" database
    const user = admin.firestore().collection("users").doc(context.auth.uid);
    const userDoc = await user.get();
    await user.update({
      created_flashcards: [
        ...userDoc.data().created_flashcards,
        {...flashcardSetMetaData, flashcardId: docRef.id},
      ],
    });
    // Return the flashcard set created to the client
    return {...flashcardSet, flashcardId: docRef.id};
  } catch (err) {
    // Re-throwing the error as an HttpsError so the client gets the
    // error details
    throw new functions.https.HttpsError("unknown", err.message, err);
  }
});

/**
 * cloud function to update a flashcard set.

  Expected input:
    - "flashcardId"
    - "title" <string (1-30 characters)>
    - "category" <string (1-30 characters)>
      - "cards" []
      - "question" <string (1+ characters)>
      - "answer" <string (1+ characters)>
 */
exports.updateFlashcardSet = functions.https.onCall(async (data, context) => {
  const withId = true;
  cuValidation(data, context, withId);

  // Format data to be updated in the database
  const {
    flashcardSetMetaData,
    flashcardSet,
  } = formatFlashcardSetData(context.auth.uid, data);

  try {
    // Update the reference to the flashcard set in the "users" database
    const user = admin.firestore().collection("users").doc(context.auth.uid);
    const userDoc = await user.get();

    let createdFlashcards = userDoc.data().created_flashcards;
    createdFlashcards = createdFlashcards.map((fc) => {
      if (fc.flashcardId !== data.flashcardId) return fc;
      return {...flashcardSetMetaData, flashcardId: data.flashcardId};
    });

    await user.update({created_flashcards: createdFlashcards});
    // Return the updated flashcard set to the client
    return {...flashcardSet, flashcardId: data.flashcardId};
  } catch (err) {
    // Re-throwing the error as an HttpsError so the client gets the
    // error details
    throw new functions.https.HttpsError("unknown", err.message, err);
  }
});
