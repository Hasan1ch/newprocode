// create_modules.js
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

// All modules structure
const modulesData = [
  {
    id: "python_fundamentals_module_1",
    courseId: "python_fundamentals",
    title: "Getting Started with Python",
    description: "Set up your Python environment and write your first program",
    orderIndex: 0,
    lessonIds: [
      "python_fundamentals_m1_lesson_1",
      "python_fundamentals_m1_lesson_2",
      "python_fundamentals_m1_lesson_3",
    ],
    quizId: "python_fundamentals_m1_quiz",
    estimatedMinutes: 90,
  },
  {
    id: "python_fundamentals_module_2",
    courseId: "python_fundamentals",
    title: "Variables and Data Types",
    description:
      "Learn how to store and work with different types of data in Python",
    orderIndex: 1,
    lessonIds: [
      "python_fundamentals_m2_lesson_1",
      "python_fundamentals_m2_lesson_2",
      "python_fundamentals_m2_lesson_3",
      "python_fundamentals_m2_lesson_4",
    ],
    quizId: "python_fundamentals_m2_quiz",
    estimatedMinutes: 120,
  },
  {
    id: "python_fundamentals_module_3",
    courseId: "python_fundamentals",
    title: "Control Flow",
    description: "Master if statements, loops, and program flow control",
    orderIndex: 2,
    lessonIds: [
      "python_fundamentals_m3_lesson_1",
      "python_fundamentals_m3_lesson_2",
      "python_fundamentals_m3_lesson_3",
      "python_fundamentals_m3_lesson_4",
    ],
    quizId: "python_fundamentals_m3_quiz",
    estimatedMinutes: 150,
  },
  {
    id: "python_fundamentals_module_4",
    courseId: "python_fundamentals",
    title: "Functions",
    description: "Create reusable code blocks with functions",
    orderIndex: 3,
    lessonIds: [
      "python_fundamentals_m4_lesson_1",
      "python_fundamentals_m4_lesson_2",
      "python_fundamentals_m4_lesson_3",
      "python_fundamentals_m4_lesson_4",
    ],
    quizId: "python_fundamentals_m4_quiz",
    estimatedMinutes: 140,
  },
  {
    id: "python_fundamentals_module_5",
    courseId: "python_fundamentals",
    title: "Data Structures",
    description: "Work with lists, tuples, dictionaries, and sets",
    orderIndex: 4,
    lessonIds: [
      "python_fundamentals_m5_lesson_1",
      "python_fundamentals_m5_lesson_2",
      "python_fundamentals_m5_lesson_3",
      "python_fundamentals_m5_lesson_4",
    ],
    quizId: "python_fundamentals_m5_quiz",
    estimatedMinutes: 160,
  },
  {
    id: "python_fundamentals_module_6",
    courseId: "python_fundamentals",
    title: "String Manipulation",
    description: "Master working with text in Python",
    orderIndex: 5,
    lessonIds: [
      "python_fundamentals_m6_lesson_1",
      "python_fundamentals_m6_lesson_2",
      "python_fundamentals_m6_lesson_3",
    ],
    quizId: "python_fundamentals_m6_quiz",
    estimatedMinutes: 100,
  },
  {
    id: "python_fundamentals_module_7",
    courseId: "python_fundamentals",
    title: "File Handling",
    description: "Read from and write to files",
    orderIndex: 6,
    lessonIds: [
      "python_fundamentals_m7_lesson_1",
      "python_fundamentals_m7_lesson_2",
      "python_fundamentals_m7_lesson_3",
    ],
    quizId: "python_fundamentals_m7_quiz",
    estimatedMinutes: 110,
  },
  {
    id: "python_fundamentals_module_8",
    courseId: "python_fundamentals",
    title: "Error Handling & Final Project",
    description: "Handle errors gracefully and build a complete project",
    orderIndex: 7,
    lessonIds: [
      "python_fundamentals_m8_lesson_1",
      "python_fundamentals_m8_lesson_2",
      "python_fundamentals_m8_lesson_3",
    ],
    quizId: "python_fundamentals_m8_quiz",
    estimatedMinutes: 180,
  },
];

async function createModules() {
  console.log("🚀 Creating all module structures...\n");

  try {
    for (const moduleData of modulesData) {
      await db.collection("modules").doc(moduleData.id).set(moduleData);
      console.log(
        `✅ Module ${moduleData.orderIndex + 1}: ${moduleData.title}`
      );
    }

    console.log("\n🎉 All 8 modules created successfully!");
    console.log("📝 Next: Run add_module_1_content.js");
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    process.exit(0);
  }
}

// Run the function
createModules();
