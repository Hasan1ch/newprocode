// fix_quiz_code_snippets.js
// This script updates quiz questions that are missing their code snippets

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Map of quiz titles to their questions with code snippets
const quizCodeSnippets = {
  "Python Variables & Data Types": {
    "What will be the output?": {
      codeSnippet: "x = 5\ny = '5'\nprint(x == y)",
      correctAnswer: "False",
    },
    "What is the result of: 10 // 3": {
      codeSnippet: "10 // 3",
      correctAnswer: "3",
    },
    "What is the output?": {
      codeSnippet: "x = [1, 2, 3]\ny = x\ny.append(4)\nprint(x)",
      correctAnswer: "[1, 2, 3, 4]",
    },
  },
  "Python Control Flow": {
    "What will this code print?": {
      codeSnippet: "for i in range(3):\n    print(i)",
      correctAnswer: "0 1 2",
    },
    "What is the output?": [
      {
        questionText:
          "x = 5\nif x > 10:\n    print('A')\nelif x > 3:\n    print('B')\nelse:\n    print('C')",
        codeSnippet:
          "x = 5\nif x > 10:\n    print('A')\nelif x > 3:\n    print('B')\nelse:\n    print('C')",
        correctAnswer: "B",
      },
      {
        questionText: "for i in range(2, 8, 2):\n    print(i, end=' ')",
        codeSnippet: "for i in range(2, 8, 2):\n    print(i, end=' ')",
        correctAnswer: "2 4 6",
      },
    ],
    "What does this list comprehension produce?": {
      codeSnippet: "[x**2 for x in range(4) if x % 2 == 0]",
      correctAnswer: "[0, 4]",
    },
  },
  "Python Master Challenge - Week 1": {
    "What is the output of this code?": [
      {
        questionText: "x = [1, 2, 3]\ny = x[:]\ny.append(4)\nprint(x)",
        codeSnippet: "x = [1, 2, 3]\ny = x[:]\ny.append(4)\nprint(x)",
        correctAnswer: "[1, 2, 3]",
      },
      {
        questionText:
          "def func(a, b=2, c=3):\n    return a + b + c\n\nprint(func(1, c=4))",
        codeSnippet:
          "def func(a, b=2, c=3):\n    return a + b + c\n\nprint(func(1, c=4))",
        correctAnswer: "7",
      },
      {
        questionText: "a = [1, 2, 3]\nb = a\na = a + [4]\nprint(b)",
        codeSnippet: "a = [1, 2, 3]\nb = a\na = a + [4]\nprint(b)",
        correctAnswer: "[1, 2, 3]",
      },
      {
        questionText:
          "def outer():\n    x = 1\n    def inner():\n        nonlocal x\n        x = 2\n    inner()\n    return x\n\nprint(outer())",
        codeSnippet:
          "def outer():\n    x = 1\n    def inner():\n        nonlocal x\n        x = 2\n    inner()\n    return x\n\nprint(outer())",
        correctAnswer: "2",
      },
    ],
    "What is the result of: 'Python'[1:4]": {
      codeSnippet: "'Python'[1:4]",
      correctAnswer: "'yth'",
    },
  },
};

async function fixCodeSnippets() {
  console.log("🔧 Starting to fix code snippets in quiz questions...\n");

  try {
    // Get all quizzes
    const quizzesSnapshot = await db.collection("quizzes").get();
    console.log(`Found ${quizzesSnapshot.size} quizzes\n`);

    let totalFixed = 0;

    for (const quizDoc of quizzesSnapshot.docs) {
      const quizData = quizDoc.data();
      const quizTitle = quizData.title;

      if (!quizCodeSnippets[quizTitle]) {
        console.log(
          `⏭️  Skipping quiz: ${quizTitle} (no code snippets needed)`
        );
        continue;
      }

      console.log(`\n📝 Processing quiz: ${quizTitle}`);

      // Get all questions for this quiz
      const questionsSnapshot = await db
        .collection("quizzes")
        .doc(quizDoc.id)
        .collection("questions")
        .get();

      const batch = db.batch();
      let fixedInQuiz = 0;

      for (const questionDoc of questionsSnapshot.docs) {
        const questionData = questionDoc.data();
        const questionText = questionData.question;
        const snippetInfo = quizCodeSnippets[quizTitle][questionText];

        if (snippetInfo) {
          let codeSnippet = null;

          // Handle array of questions with same text
          if (Array.isArray(snippetInfo)) {
            // Find matching question by checking if the question contains the code
            const match = snippetInfo.find(
              (info) =>
                questionText.includes(info.questionText.substring(0, 20)) ||
                questionData.correctAnswer === info.correctAnswer
            );
            if (match) {
              codeSnippet = match.codeSnippet;
            }
          } else {
            codeSnippet = snippetInfo.codeSnippet;
          }

          if (
            codeSnippet &&
            (!questionData.codeSnippet || questionData.codeSnippet === "")
          ) {
            console.log(
              `  ✅ Adding code snippet to: "${questionText.substring(
                0,
                50
              )}..."`
            );

            const questionRef = db
              .collection("quizzes")
              .doc(quizDoc.id)
              .collection("questions")
              .doc(questionDoc.id);

            batch.update(questionRef, { codeSnippet: codeSnippet });
            fixedInQuiz++;
          }
        }
      }

      if (fixedInQuiz > 0) {
        await batch.commit();
        console.log(`  ✅ Fixed ${fixedInQuiz} questions in this quiz`);
        totalFixed += fixedInQuiz;
      } else {
        console.log(`  ℹ️  No questions needed fixing in this quiz`);
      }
    }

    console.log(`\n✅ Finished! Fixed ${totalFixed} questions total.`);
  } catch (error) {
    console.error("❌ Error fixing code snippets:", error);
  } finally {
    process.exit();
  }
}

// Run the fix
fixCodeSnippets();
