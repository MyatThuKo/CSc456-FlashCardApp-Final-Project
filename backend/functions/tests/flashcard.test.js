/* eslint-disable max-len */
const path = require("path");

const admin = require("firebase-admin");
const fft = require("firebase-functions-test")(
    {projectId: process.env.FB_SA_PROJECT_ID},
    path.resolve(__dirname, "./serviceAccountKey.json"),
);

// Testing https.onCall function
describe("Testing Flashcard Set Functions", () => {
  let myFunctions;
  let user;
  const unownedFCSetData = {
    creatorId: "fake-uuid",
    title: "Unowned",
    category: "Test",
    timestamp: Date.now(),
    cards: [{question: "Q", answer: "A"}],
  };
  let unownedFCSetId;
  const docsToDelete = [];

  // Loops through the keys of object 1 and makes sure it exists & is equal
  // to the value in the 2nd object
  const matchObject =(refObj, obj2) => {
    for (const [key, value] of Object.entries(refObj)) {
      expect(obj2[key]).toEqual(value);
    }
  };

  beforeAll(async () => {
    myFunctions = require("../index");

    // Create a test user
    user = fft.auth.exampleUserRecord();
    user.uid = "test-id-2";
    user.email = "testuser2@gmail.com";
    const newUserSignup = fft.wrap(myFunctions.newUserSignup);
    await newUserSignup(user);

    // Create a test flashcard set for error cases
    const docRef = await admin.firestore().collection("flashcards").add(unownedFCSetData);
    unownedFCSetId = docRef.id;
    docsToDelete.push(unownedFCSetId); // For cleanup
  });

  afterAll(async () => {
    await admin.firestore().collection("users").doc(user.uid).delete();
    const deletePromises = docsToDelete.map((docId) =>
      admin.firestore().collection("flashcards").doc(docId).delete(),
    );
    await Promise.all(deletePromises);
    fft.cleanup(); // Do cleanup tasks
  });

  //* **************** Test addFlashcardSet ******************* */
  describe("addFlashcardSet", () => {
    test("write doc to /flashcards & update doc in /users", async () => {
      const addFlashcardSet = fft.wrap(myFunctions.addFlashcardSet);

      const data = {
        title: "Presidents",
        category: "History",
        cards: [
          {question: "1st president of the US", answer: "George Washington"},
        ],
      };
      const context = {auth: {uid: user.uid}};

      const res = await addFlashcardSet(data, context);
      docsToDelete.push(res.flashcardId); // For cleanup

      // Validate response from adding flashcard set
      expect(res.flashcardId).toBeTruthy();
      expect(res.timestamp).toBeTruthy();
      expect(res.creatorId).toBe(context.auth.uid);
      matchObject(data, res);

      // Validate reference to flashcard set is on "user" document
      const snapshot = await admin
          .firestore()
          .collection("users")
          .doc(user.uid)
          .get();
      expect(snapshot.exists).toBeTruthy();

      const createdFlashcard = snapshot.data().created_flashcards.find((obj) => {
        return obj.flashcardId === res.flashcardId;
      });
      expect(createdFlashcard).toBeTruthy();
      expect(createdFlashcard.title).toEqual(data.title);
      expect(createdFlashcard.category).toEqual(data.category);
    });

    test("throws error if not authenticated", async () => {
      const addFlashcardSet = fft.wrap(myFunctions.addFlashcardSet);
      await expect(addFlashcardSet({}, {})).rejects.toEqual(
          new Error("You must be authenticated to create a flashcard set."),
      );
    });

    test("throws error if missing fields", async () => {
      const addFlashcardSet = fft.wrap(myFunctions.addFlashcardSet);
      const context = {auth: {uid: user.uid}};
      const cases = [
        ["title", {}],
        ["category", {title: "title"}],
        ["cards", {title: "title", category: "category"}],
      ];

      for (const testVal of cases) {
        await expect(addFlashcardSet(testVal[1], context)).rejects.toEqual(
            new Error(`The "${testVal[0]}" field must be provided.`),
        );
      }
    });

    test("throws error if title & category fails pre-condition", async () => {
      const addFlashcardSet = fft.wrap(myFunctions.addFlashcardSet);
      const data = {
        title: "Lorem ipsum dolor sit amet, con",
        category: "category",
        cards: [],
      };
      const context = {auth: {uid: user.uid}};

      await expect(addFlashcardSet(data, context)).rejects.toEqual(
          new Error(
              "The \"title\" field must be a string between 1-30 characters.",
          ),
      );
      data.title = "title";
      data.category = "Lorem ipsum dolor sit amet, con";
      await expect(addFlashcardSet(data, context)).rejects.toEqual(
          new Error(
              "The \"category\" field must be a string between 1-30 characters.",
          ),
      );
    });

    test("throws error if cards fail pre-condition", async () => {
      const addFlashcardSet = fft.wrap(myFunctions.addFlashcardSet);
      const data = {
        title: "title",
        category: "category",
        cards: [{}],
      };
      const context = {auth: {uid: user.uid}};
      const cases = [
        [],
        [{}],
        [{question: ""}],
        [{question: "", answer: ""}],
        [{question: "question", answer: ""}],
        [{question: "", answer: "answer"}],
      ];

      for (const testVal of cases) {
        data.cards = testVal;
        await expect(addFlashcardSet(data, context)).rejects.toEqual(
            new Error(
                "The \"cards\" field must be a non-empty array of objects with" +
                " keys \"question\" and \"answer\" with non-empty string values.",
            ),
        );
      }
    });
  });


  //* **************** Test updateFlashcardSet ******************* */
  describe("updateFlashcardSet", () => {
    test("update doc in /flashcards and /users", async () => {
      const updateFlashcardSet = fft.wrap(myFunctions.updateFlashcardSet);
      const data = {
        title: "Updated Flashcard Set Title",
        category: "Updated category",
        cards: [
          {question: "Updated Question 1", answer: "Updated Answer 1"},
          {question: "Updated Question 2", answer: "Updated Answer 2"},
          {question: "New Question", answer: "New Answer"},
        ],
      };

      // Create a test flashcard set
      const addFlashcardSet = fft.wrap(myFunctions.addFlashcardSet);
      const addData = {
        title: "Test Flashcard Set",
        category: "Test Category",
        cards: [
          {question: "Test Question 1", answer: "Test Answer 1"},
          {question: "Test Question 2", answer: "Test Answer 2"},
        ],
      };

      const context = {auth: {uid: user.uid}};

      const addRes = await addFlashcardSet(addData, context);
      docsToDelete.push(addRes.flashcardId);

      const res = await updateFlashcardSet(
          {flashcardId: addRes.flashcardId, ...data},
          context,
      );

      // Validate response from updating flashcard set
      expect(res.flashcardId).toEqual(addRes.flashcardId);
      expect(res.timestamp).toBeTruthy();
      matchObject(data, res);
    });

    test("throws error if not authenticated", async () => {
      const updateFlashcardSet = fft.wrap(myFunctions.updateFlashcardSet);
      await expect(updateFlashcardSet({}, {})).rejects.toEqual(
          new Error("You must be authenticated to update a flashcard set."),
      );
    });

    test("throws error if missing fields", async () => {
      const updateFlashcardSet = fft.wrap(myFunctions.updateFlashcardSet);
      const context = {auth: {uid: user.uid}};
      const cases = [
        ["flashcardId", {}],
        ["title", {flashcardId: "flashcardId"}],
        ["category", {flashcardId: "flashcardId", title: "title"}],
        ["cards", {flashcardId: "flashcardId", title: "title", category: "category"}],
      ];

      for (const testVal of cases) {
        await expect(updateFlashcardSet(testVal[1], context)).rejects.toEqual(
            new Error(`The "${testVal[0]}" field must be provided.`),
        );
      }
    });

    test("throws error updating flashcard set we don't own", async () => {
      const context = {auth: {uid: user.uid}};
      // Attempt to update flashcard set
      const updateFlashcardSet = fft.wrap(myFunctions.updateFlashcardSet);
      await expect(updateFlashcardSet({flashcardId: unownedFCSetId, ...unownedFCSetData}, context)).rejects.toEqual(
          new Error("You do not have permission to edit this flashcard set."),
      );

      // Validate flashcard set still exists
      const doc = await admin.firestore().collection("flashcards").doc(unownedFCSetId).get();
      expect(doc.exists).toBeTruthy();
    });
  });

  //* **************** Test deleteFlashcardSet ******************* */
  describe("deleteFlashcardSet", () => {
    let delDocId;

    beforeAll(async () => {
      const data = {
        creatorId: user.uid,
        title: "Doc to delete",
        category: "Test",
        timestamp: Date.now(),
        cards: [{question: "Q", answer: "A"}],
      };
      const docRef = await admin.firestore().collection("flashcards").add(data);
      delDocId = docRef.id;
      docsToDelete.push(delDocId); // For cleanup
    });

    test(`"trash" doc in /flashcards`, async () => {
      const context = {auth: {uid: user.uid}};
      // "Trash" Flashcard
      const deleteFlashcardSet = fft.wrap(myFunctions.deleteFlashcardSet);
      const res = await deleteFlashcardSet({flashcardId: delDocId}, context);
      expect(res.message).toEqual("The flashcard set was sent to the trash.");

      // Valdiate flashcard set still exists, but with "toBeDeleted = true"
      const doc = await admin.firestore().collection("flashcards").doc(delDocId).get();
      expect(doc.exists).toBeTruthy();
      expect(doc.data().toBeDeleted).toBe(true);
    });


    test(`permanently delete doc in /flashcards`, async () => {
      const context = {auth: {uid: user.uid}};
      // Permanently Delete Flashcard
      const deleteFlashcardSet = fft.wrap(myFunctions.deleteFlashcardSet);
      const res = await deleteFlashcardSet({flashcardId: delDocId}, context);
      expect(res.message).toEqual("The flashcard set was permanently deleted.");

      // Valdiate flashcard set has been deleted
      const doc = await admin.firestore().collection("flashcards").doc(delDocId).get();
      expect(doc.exists).not.toBeTruthy();

      // Validate reference to flashcard set ISN'T on "user" document
      const snapshot = await admin
          .firestore()
          .collection("users")
          .doc(user.uid)
          .get();
      expect(snapshot.exists).toBeTruthy();
      const flashcard = snapshot.data().created_flashcards.find((obj) => {
        return obj.flashcardId === delDocId;
      });
      expect(flashcard).not.toBeTruthy();
    });

    test("throws error if not authenticated", async () => {
      const deleteFlashcardSet = fft.wrap(myFunctions.deleteFlashcardSet);
      await expect(deleteFlashcardSet({}, {})).rejects.toEqual(
          new Error("You must be authenticated to delete a flashcard set."),
      );
    });

    test("throws error deleting flashcard set we don't own", async () => {
      const context = {auth: {uid: user.uid}};
      // Attempt to delete flashcard set
      const deleteFlashcardSet = fft.wrap(myFunctions.deleteFlashcardSet);
      await expect(deleteFlashcardSet({flashcardId: unownedFCSetId}, context)).rejects.toEqual(
          new Error("You do not have permission to delete this flashcard set."),
      );

      // Validate flashcard set still exists
      const doc = await admin.firestore().collection("flashcards").doc(unownedFCSetId).get();
      expect(doc.exists).toBeTruthy();
    });
  });

  //* **************** Test recoverFlashcardSet ******************* */
  describe("recoverFlashcardSet", () => {
    test(`recover doc in /flashcards`, async () => {
      const data = {
        creatorId: user.uid,
        title: "Doc to delete",
        category: "Test",
        timestamp: Date.now(),
        cards: [{question: "Q", answer: "A"}],
      };
      const docRef = await admin.firestore().collection("flashcards").add(data);
      const fcId = docRef.id;
      docsToDelete.push(fcId); // For cleanup

      const context = {auth: {uid: user.uid}};
      // Recover Flashcard
      const recoverFlashcardSet = fft.wrap(myFunctions.recoverFlashcardSet);
      const res = await recoverFlashcardSet({flashcardId: fcId}, context);
      expect(res.message).toEqual("Flashcard set has been recovered.");

      // Valdiate flashcard set has "toBeDeleted = false"
      const doc = await admin.firestore().collection("flashcards").doc(fcId).get();
      expect(doc.exists).toBeTruthy();
      expect(doc.data().toBeDeleted).toBe(false);
    });

    test("throws error if not authenticated", async () => {
      const recoverFlashcardSet = fft.wrap(myFunctions.recoverFlashcardSet);
      await expect(recoverFlashcardSet({}, {})).rejects.toEqual(
          new Error("You must be authenticated to recover a flashcard set."),
      );
    });

    test("throws error recovering flashcard set we don't own", async () => {
      const context = {auth: {uid: user.uid}};
      // Attempt to recover flashcard set
      const recoverFlashcardSet = fft.wrap(myFunctions.recoverFlashcardSet);
      await expect(recoverFlashcardSet({flashcardId: unownedFCSetId}, context)).rejects.toEqual(
          new Error("You do not have permission to recover this flashcard set."),
      );
    });
  });
});
