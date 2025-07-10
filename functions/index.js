/**
 * Cloud Functions for ProCode Learning App
 */

const {setGlobalOptions} = require("firebase-functions");

// Set global options for all functions
setGlobalOptions({maxInstances: 10});

// Add your Cloud Functions here when needed
// Example:
// exports.processQuizResult = require("./quiz/processResult");
// exports.updateLeaderboard = require("./leaderboard/update");
