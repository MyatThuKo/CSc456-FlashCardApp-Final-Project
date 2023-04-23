/* eslint-disable max-len */
const path = require("path");

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fft = require("firebase-functions-test")(
    {projectId: process.env.FB_SA_PROJECT_ID},
    path.resolve(__dirname, "./serviceAccountKey.json"),
);

// Testing https.onCall function

describe("Testing Flashcard Set Functions", () => {
  let myFunctions;
  let user;
  const docsToDelete = [];
  // let flashcardId;

  beforeAll(async () => {
    myFunctions = require("../index");

    // Create a test user
    user = fft.auth.exampleUserRecord();
    user.uid = "test-id-2";
    user.email = "testuser2@gmail.com";
    const newUserSignup = fft.wrap(myFunctions.newUserSignup);
    await newUserSignup(user);
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
      expect(res.title).toBe(data.title);
      expect(res.category).toBe(data.category);
      expect(res.cards.length).toBe(1);
      expect(res.creatorId).toBe(context.auth.uid);
      expect(res.timestamp).toBeTruthy();

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
  functions.logger.info("Test addFlashcardSet was succesfull");

  //* **************** Test updateFlashcardSet ******************* */
  describe("updateFlashcardSet", () => {
    test("update doc in /flascards and /users", async () => {
      const updateFlashcardSet = fft.wrap(myFunctions.updateFlashcardSet);
      const data = {
        title: "Updated Flaschard Set Title",
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

      // Validate reference to flashcard set is on "user" document

      expect(addRes.flashcardId).toBeTruthy();

      const res = await updateFlashcardSet(
          {flashcardId: addRes.flashcardId, ...data},
          context,
      );

      // Validate response from updating flashcard set
      expect(res.flashcardId).toEqual(addRes.flashcardId);
      expect(res.title).toEqual(data.title);
      expect(res.category).toEqual(data.category);
      expect(res.cards.length).toEqual(3);
      expect(res.cards[0].question).toEqual(data.cards[0].question);
      expect(res.cards[0].answer).toEqual(data.cards[0].answer);
      expect(res.cards[1].question).toEqual(data.cards[1].question);
      expect(res.cards[1].answer).toEqual(data.cards[1].answer);
      expect(res.cards[2].question).toEqual(data.cards[2].question);
      expect(res.cards[2].answer).toEqual(data.cards[2].answer);
      expect(res.creatorId).toBe(context.auth.uid);
      expect(res.timestamp).toBeTruthy();
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

    test("throws error if title & category fails pre-condition", async () => {
      const updateFlashcardSet = fft.wrap(myFunctions.updateFlashcardSet);
      const data = {
        flashcardId: "flashcardId",
        title: "Lorem ipsum dolor sit amet, con",
        category: "category",
        cards: [],
      };
      const context = {auth: {uid: user.uid}};

      await expect(updateFlashcardSet(data, context)).rejects.toEqual(
          new Error(
              "The \"title\" field must be a string between 1-30 characters.",
          ),
      );
      data.title = "title";
      data.category = "Lorem ipsum dolor sit amet, con";
      await expect(updateFlashcardSet(data, context)).rejects.toEqual(
          new Error(
              "The \"category\" field must be a string between 1-30 characters.",
          ),
      );
    });

    test("throws error if cards fail pre-condition", async () => {
      const updateFlashcardSet = fft.wrap(myFunctions.updateFlashcardSet);
      const data = {
        flashcardId: "flashcardId",
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
        await expect(updateFlashcardSet(data, context)).rejects.toEqual(
            new Error(
                "The \"cards\" field must be a non-empty array of objects with" +
                " keys \"question\" and \"answer\" with non-empty string values.",
            ),
        );
      }
    });
  });
  functions.logger.info("Test updateFlashcardSet was succesfull");

  //* **************** Test deleteFlashcardSet ******************* */
  describe("deleteFlashcardSet", () => {
    test("delete doc in /flashcards", async () => {
      const addFlashcardSet = fft.wrap(myFunctions.addFlashcardSet);
      const data = {
        title: "Test Set",
        category: "Test",
        cards: [{question: "Q1", answer: "A1"}],
      };
      const context = {auth: {uid: user.uid}};

      const res = await addFlashcardSet(data, context);
      const fcId = res.flashcardId;
      docsToDelete.push(fcId); // For cleanup

      // Validate response from adding flashcard set
      expect(fcId).toBeTruthy();
      expect(res.timestamp).toBeTruthy();
      expect(res.creatorId).toBe(context.auth.uid);
      for (const [key, value] of Object.entries(data)) {
        expect(data[key]).toBe(value);
      }

      // Delete Flashcard
      const deleteFlashcardSet = fft.wrap(myFunctions.deleteFlashcardSet);
      await deleteFlashcardSet({flashcardId: fcId}, context);

      // Valdiate flashcard set has been deleted
      const doc = await admin.firestore().collection("flashcards").doc(fcId).get();
      console.log(doc.data());
      expect(doc.exists).not.toBeTruthy();

      // Validate reference to flashcard set ISN'T on "user" document
      const snapshot = await admin
          .firestore()
          .collection("users")
          .doc(user.uid)
          .get();
      expect(snapshot.exists).toBeTruthy();
      const flashcard = snapshot.data().created_flashcards.find((obj) => {
        return obj.flashcardId === res.flashcardId;
      });
      expect(flashcard).not.toBeTruthy();
    });
  });

  test("throws error if not authenticated", async () => {
    const deleteFlashcardSet = fft.wrap(myFunctions.deleteFlashcardSet);
    await expect(deleteFlashcardSet({}, {})).rejects.toEqual(
        new Error("You must be authenticated to delete a flashcard set."),
    );
  });

  test("silently handles case of deleting unowned flashcard set", async () => {
    // Create a test flashcard set for error cases
    const data = {
      creatorId: "fake-uuid",
      title: "Unowned",
      category: "Test",
      timestamp: Date.now(),
      cards: [{question: "Q", answer: "A"}],
    };
    const docRef = await admin.firestore().collection("flashcards").add(data);
    docsToDelete.push(docRef.id); // For cleanup

    const context = {auth: {uid: user.uid}};
    // Attempt to delete flashcard set [will not be deleted]
    const deleteFlashcardSet = fft.wrap(myFunctions.deleteFlashcardSet);
    await deleteFlashcardSet({flashcardId: docRef.id}, context);

    // Validate flashcard set still exists
    const doc = await admin.firestore().collection("flashcards").doc(docRef.id).get();
    expect(doc.exists).toBeTruthy();
    for (const [key, value] of Object.entries(data)) {
      expect(data[key]).toBe(value);
    }
  });
  functions.logger.info("Test deleteFlashcardSet was succesfull");
});
