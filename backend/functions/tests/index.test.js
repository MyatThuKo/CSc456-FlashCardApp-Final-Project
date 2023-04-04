const config = require("./config");
const serviceAccount = config.FIREBASE_KEY;

const firebaseAdmin = require("firebase-admin");
firebaseAdmin.initializeApp();
const fft = require("firebase-functions-test")({
  projectId: process.env.FB_SA_PROJECT_ID,
  credentials: serviceAccount,
});

// Testing https.onRequest function
describe("test helloWorld", () => {
  let myFunctions;

  beforeAll(() => {
    myFunctions = require("../index");
  });

  afterAll(() => {
    fft.cleanup(); // Do cleanup tasks
  });

  test("recieve response on success", async () => {
    const req = {};
    const res = {
      send: (message) => {
        expect(message).toBe("Hello from Firebase!");
      },
    };
    await myFunctions.helloWorld(req, res);
  });
});
