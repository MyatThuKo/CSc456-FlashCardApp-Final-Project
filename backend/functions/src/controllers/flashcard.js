/* eslint-disable max-len */
const functions = require("firebase-functions");
const admin = require("firebase-admin");

const myUtils = require("../utils.js");

// "cu" = Create & Update
const cuValidation = (data, context, withId = false) => {
  const word = withId ? "update" : "create";
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
const formatFlashcardSetData = (data, userId) => {
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
  Expecetd input:
    - "category" <string>
    - "question" <string>
    - "answer" <string>
*/
exports.addFCToCategory = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    const errMsg = `You must be authenticated to add a flashcard to a category.`;
    throw new functions.https.HttpsError("unauthenticated", errMsg);
  }
  // Make sure required fields are provided
  const requiredFields = ["category", "question", "answer"];
  requiredFields.forEach((field) => {
    if (!data[field]) {
      const errMsg = `The "${field}" field must be provided.`;
      throw new functions.https.HttpsError("invalid-argument", errMsg);
    }
  });

  try {
    const fcItem = {question: data["question"], answer: data["answer"]};
    let newFCSet = {
      category: data["category"],
      creatorId: context.auth.uid,
      cards: [fcItem],
    };
    const collRef = admin.firestore().collection("flashcards");
    const docRef = collRef
        .where("creatorId", "==", context.auth.uid)
        .where("category", "==", data["category"])
        .limit(1);
    const resRef = await docRef.get().then(async (snapshot) => {
      if (snapshot.docs.length === 0) {
        // Create a doc since it doesn't exist
        return admin.firestore().collection("flashcards").add(newFCSet);
      } else {
        // Update the doc since it exists
        const docData = snapshot.docs[0].data();
        const docId = snapshot.docs[0].id;
        newFCSet = {...newFCSet, cards: [...docData.cards, fcItem]};
        return collRef
            .doc(docId)
            .update({cards: newFCSet.cards})
            .then(() => Promise.resolve({id: docId}));
      }
    });
    // Return the flashcard set created to the client
    return {...newFCSet, flashcardId: resRef.id};
  } catch (err) {
    // Re-throwing the error as an HttpsError so the client gets the
    // error details
    throw new functions.https.HttpsError("unknown", err.message, err);
  }
});

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
  const {flashcardSetMetaData, flashcardSet} = formatFlashcardSetData(
      data, context.auth.uid,
  );
  flashcardSet.creatorId = context.auth.uid;

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
  const {flashcardSetMetaData, flashcardSet} = formatFlashcardSetData(
      data, context.auth.uid,
  );

  try {
    const flashcardId = data.flashcardId;
    // Update the flashcard set in the "flashcards" database
    const docRef = admin.firestore().collection("flashcards").doc(flashcardId);
    await docRef.get().then((doc) => {
      if (doc.data().creatorId === context.auth.uid) {
        return docRef.update(flashcardSet);
      } else {
        const errMsg = "You do not have permission to edit this flashcard set.";
        throw new functions.https.HttpsError("permission-denied", errMsg);
      }
    });

    // Update the reference to the flashcard set in the "users" database
    const user = admin.firestore().collection("users").doc(context.auth.uid);
    const userDoc = await user.get();

    let createdFlashcards = userDoc.data().created_flashcards;
    createdFlashcards = createdFlashcards.map((fc) => {
      if (fc.flashcardId !== flashcardId) return fc;
      return {...flashcardSetMetaData, flashcardId};
    });

    await user.update({created_flashcards: createdFlashcards});
    // Return the updated flashcard set to the client
    return {...flashcardSet, flashcardId};
  } catch (err) {
    // Re-throwing the error as an HttpsError so the client gets the
    // error details
    throw new functions.https.HttpsError("unknown", err.message, err);
  }
});

/**
 * cloud function to delete a flashcard set.

  Expected input:
    - "flashcardId"
*/
exports.deleteFlashcardSet = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    const errMsg = "You must be authenticated to delete a flashcard set.";
    throw new functions.https.HttpsError("unauthenticated", errMsg);
  }

  // Make sure required fields are provided
  const flashcardId = data.flashcardId;
  if (!flashcardId) {
    const errMsg = `The "flashcardId" field must be provided.`;
    throw new functions.https.HttpsError("invalid-argument", errMsg);
  }

  try {
    let action = "trash"; // "delete" or "trash"
    // Delete the flashcard set in the "flashcards" database
    const docRef = admin.firestore().collection("flashcards").doc(flashcardId);
    await docRef.get().then((doc) => {
      if (doc.data().creatorId !== context.auth.uid) {
        const errMsg =
          "You do not have permission to delete this flashcard set.";
        throw new functions.https.HttpsError("permission-denied", errMsg);
      }
      // We know the person who called this function is the owner
      if (!doc.data().toBeDeleted) {
        return docRef.update({toBeDeleted: true});
      } else {
        // Permanently delete flashcard set
        action = "delete";
        return docRef.delete();
      }
    });

    // If we're permanently deleting the flashcard set
    if (action === "delete") {
      // Remove the reference to the flashcard set in the "users" database
      const user = admin.firestore().collection("users").doc(context.auth.uid);
      const userDoc = await user.get();
      let createdFcs = userDoc.data().created_flashcards;
      createdFcs = createdFcs.filter((fc) => fc.flashcardId !== flashcardId);
      await user.update({created_flashcards: createdFcs});
    }
    // Return the id of the flashcard set that was "deleted" to the client
    // along with a message of the action taken
    const returnMsg = action === "delete" ?
      "The flashcard set was permanently deleted." :
      "The flashcard set was sent to the trash.";
    return {flashcardId, message: returnMsg};
  } catch (err) {
    // Re-throwing the error as an HttpsError so the client gets the
    // error details
    throw new functions.https.HttpsError("unknown", err.message, err);
  }
});

/**
 * cloud function to recover a flashcard set.

  Expected input:
    - "flashcardId"
*/
exports.recoverFlashcardSet = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    const errMsg = "You must be authenticated to recover a flashcard set.";
    throw new functions.https.HttpsError("unauthenticated", errMsg);
  }

  // Make sure required fields are provided
  if (!data.flashcardId) {
    const errMsg = `The "flashcardId" field must be provided.`;
    throw new functions.https.HttpsError("invalid-argument", errMsg);
  }

  try {
    // Recover the flashcard set in the "flashcards" database
    const docRef = admin.firestore().collection("flashcards").doc(data.flashcardId);
    await docRef.get().then((doc) => {
      if (doc.data().creatorId !== context.auth.uid) {
        const errMsg =
          "You do not have permission to recover this flashcard set.";
        throw new functions.https.HttpsError("permission-denied", errMsg);
      }
      return docRef.update({toBeDeleted: false});
    });
    const returnMsg = "Flashcard set has been recovered.";
    return {flashcardId: data.flashcardId, message: returnMsg};
  } catch (err) {
    // Re-throwing the error as an HttpsError so the client gets the
    // error details
    throw new functions.https.HttpsError("unknown", err.message, err);
  }
});
