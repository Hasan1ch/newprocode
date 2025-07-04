// fix_boolean_answers.js
// This script fixes boolean question answers to ensure consistency

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function fixBooleanAnswers() {
  console.log("🔧 Fixing boolean quiz answers...\n");

  try {
    const quizzesSnapshot = await db.collection("quizzes").get();
    let totalFixed = 0;

    for (const quizDoc of quizzesSnapshot.docs) {
      const quizData = quizDoc.data();
      console.log(`\nProcessing quiz: ${quizData.title}`);

      const questionsSnapshot = await db
        .collection("quizzes")
        .doc(quizDoc.id)
        .collection("questions")
        .get();

      const batch = db.batch();
      let fixedInQuiz = 0;

      for (const questionDoc of questionsSnapshot.docs) {
        const data = questionDoc.data();
        const question = data.question;
        const type = data.type;
        const correctAnswer = data.correctAnswer;
        const options = data.options || [];

        // Check if this is a boolean question
        if (
          type === "boolean" ||
          (options.includes("True") && options.includes("False")) ||
          question.toLowerCase().includes("true or false")
        ) {
          console.log(
            `  Found boolean question: "${question.substring(0, 50)}..."`
          );
          console.log(
            `    Current correct answer: "${correctAnswer}" (type: ${typeof correctAnswer})`
          );

          let needsUpdate = false;
          let newCorrectAnswer = correctAnswer;

          // Standardize the correct answer to string format
          if (typeof correctAnswer === "boolean") {
            newCorrectAnswer = correctAnswer ? "True" : "False";
            needsUpdate = true;
          } else if (typeof correctAnswer === "string") {
            // Ensure proper capitalization
            if (correctAnswer.toLowerCase() === "true") {
              newCorrectAnswer = "True";
              needsUpdate = correctAnswer !== "True";
            } else if (correctAnswer.toLowerCase() === "false") {
              newCorrectAnswer = "False";
              needsUpdate = correctAnswer !== "False";
            }
          }

          // Also ensure options are properly formatted
          let newOptions = options;
          if (
            options.length === 2 &&
            (options.includes("true") ||
              options.includes("false") ||
              options.includes("TRUE") ||
              options.includes("FALSE"))
          ) {
            newOptions = ["True", "False"];
            needsUpdate = true;
          }

          if (needsUpdate) {
            console.log(`    ✅ Updating to: "${newCorrectAnswer}"`);

            const updateData = {
              correctAnswer: newCorrectAnswer,
              type: "boolean", // Ensure type is set
              options: newOptions,
            };

            batch.update(questionDoc.ref, updateData);
            fixedInQuiz++;
          } else {
            console.log(`    ℹ️  Already correct`);
          }
        }
      }

      if (fixedInQuiz > 0) {
        await batch.commit();
        console.log(`  Fixed ${fixedInQuiz} boolean questions`);
        totalFixed += fixedInQuiz;
      }
    }

    console.log(`\n✅ Total fixed: ${totalFixed} boolean questions`);
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    process.exit();
  }
}

// Run the fix
fixBooleanAnswers();
