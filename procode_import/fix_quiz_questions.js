// fix_quiz_questions.js
// This script adds orderIndex to all quiz questions that don't have it

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function fixQuizQuestions() {
  try {
    console.log("Starting to fix quiz questions...");

    // Get all quizzes
    const quizzesSnapshot = await db.collection("quizzes").get();
    console.log(`Found ${quizzesSnapshot.size} quizzes`);

    for (const quizDoc of quizzesSnapshot.docs) {
      const quizId = quizDoc.id;
      const quizData = quizDoc.data();
      console.log(`\nProcessing quiz: ${quizId} - ${quizData.title}`);

      // Get all questions for this quiz
      const questionsSnapshot = await db
        .collection("quizzes")
        .doc(quizId)
        .collection("questions")
        .get();

      console.log(`  Found ${questionsSnapshot.size} questions`);

      // Update each question with orderIndex if missing
      let orderIndex = 0;
      const batch = db.batch();
      let needsUpdate = false;

      // Sort questions by ID to ensure consistent ordering
      const sortedQuestions = questionsSnapshot.docs.sort((a, b) =>
        a.id.localeCompare(b.id)
      );

      for (const questionDoc of sortedQuestions) {
        const questionData = questionDoc.data();
        const questionRef = db
          .collection("quizzes")
          .doc(quizId)
          .collection("questions")
          .doc(questionDoc.id);

        // Check if orderIndex is missing or if we need to reorder
        if (
          questionData.orderIndex === undefined ||
          questionData.orderIndex === null
        ) {
          console.log(
            `  Adding orderIndex ${orderIndex} to question: ${questionDoc.id}`
          );
          batch.update(questionRef, { orderIndex: orderIndex });
          needsUpdate = true;
        }

        orderIndex++;
      }

      if (needsUpdate) {
        await batch.commit();
        console.log(`  ✓ Updated questions for quiz: ${quizId}`);
      } else {
        console.log(`  ✓ All questions already have orderIndex`);
      }
    }

    console.log("\n✅ Finished fixing quiz questions!");
  } catch (error) {
    console.error("❌ Error fixing quiz questions:", error);
  } finally {
    // Exit the process
    process.exit();
  }
}

// Run the fix
fixQuizQuestions();
