// fix_firebase_structure.js
// Run this script to ensure all Firebase documents have required fields

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function fixDatabaseStructure() {
  console.log("🔧 Starting Firebase structure fixes...\n");

  // 1. Fix Courses Collection
  console.log("📚 Fixing courses collection...");
  const coursesSnapshot = await db.collection("courses").get();

  for (const doc of coursesSnapshot.docs) {
    const data = doc.data();
    const updates = {};

    // Add missing fields with defaults
    if (!data.thumbnailUrl) updates.thumbnailUrl = "";
    if (!data.rating) updates.rating = 0.0;
    if (!data.category) updates.category = "Programming Languages";
    if (!data.updatedAt)
      updates.updatedAt = admin.firestore.FieldValue.serverTimestamp();
    if (!data.icon) updates.icon = "🐍";
    if (!data.isFeatured) updates.isFeatured = false;
    if (!data.estimatedHours) updates.estimatedHours = data.moduleCount * 2;

    if (Object.keys(updates).length > 0) {
      await doc.ref.update(updates);
      console.log(`✅ Updated course: ${doc.id}`);
    }
  }

  // 2. Fix Achievements Collection
  console.log("\n🏆 Fixing achievements collection...");
  const achievementsSnapshot = await db.collection("achievements").get();

  for (const doc of achievementsSnapshot.docs) {
    const data = doc.data();
    const updates = {};

    // Rename 'icon' to 'iconAsset' if needed (or vice versa)
    if (data.icon && !data.iconAsset) {
      updates.iconAsset = data.icon;
    }

    if (Object.keys(updates).length > 0) {
      await doc.ref.update(updates);
      console.log(`✅ Updated achievement: ${doc.id}`);
    }
  }

  // 3. Fix User Stats Collection
  console.log("\n📊 Fixing user_stats collection...");
  const userStatsSnapshot = await db.collection("user_stats").get();

  for (const doc of userStatsSnapshot.docs) {
    const data = doc.data();
    const updates = {};

    // Map field names to match model expectations
    if (
      data.totalLessonsCompleted !== undefined &&
      data.lessonsCompleted === undefined
    ) {
      updates.lessonsCompleted = data.totalLessonsCompleted;
    }
    if (
      data.totalQuizzesCompleted !== undefined &&
      data.quizzesCompleted === undefined
    ) {
      updates.quizzesCompleted = data.totalQuizzesCompleted;
    }
    if (!data.challengesCompleted) updates.challengesCompleted = 0;
    if (!data.coursesCompleted) updates.coursesCompleted = 0;
    if (!data.perfectQuizzes) updates.perfectQuizzes = 0;
    if (!data.currentStreak) updates.currentStreak = 0;
    if (!data.longestStreak) updates.longestStreak = 0;
    if (!data.level) updates.level = 1;
    if (!data.xpHistory) updates.xpHistory = {};
    if (!data.dailyXP) updates.dailyXP = {};

    if (Object.keys(updates).length > 0) {
      await doc.ref.update(updates);
      console.log(`✅ Updated user stats: ${doc.id}`);
    }
  }

  // 4. Fix Lessons Collection
  console.log("\n📖 Fixing lessons collection...");
  const lessonsSnapshot = await db.collection("lessons").get();

  for (const doc of lessonsSnapshot.docs) {
    const data = doc.data();
    const updates = {};

    // Ensure all required fields exist
    if (!data.createdAt)
      updates.createdAt = admin.firestore.FieldValue.serverTimestamp();
    if (!data.updatedAt)
      updates.updatedAt = admin.firestore.FieldValue.serverTimestamp();
    if (!data.xpReward) updates.xpReward = 10;
    if (!data.videoUrl) updates.videoUrl = "";
    if (!data.keyPoints) updates.keyPoints = [];
    if (!data.codeExamples) updates.codeExamples = [];

    if (Object.keys(updates).length > 0) {
      await doc.ref.update(updates);
      console.log(`✅ Updated lesson: ${doc.id}`);
    }
  }

  // 5. Fix Progress Collection
  console.log("\n📈 Fixing progress collection...");
  const progressSnapshot = await db.collection("progress").get();

  for (const doc of progressSnapshot.docs) {
    const data = doc.data();
    const updates = {};

    // Ensure all required fields exist
    if (!data.quizScores) updates.quizScores = {};
    if (!data.currentModuleId) updates.currentModuleId = "";
    if (!data.currentLessonId) updates.currentLessonId = "";
    if (!data.lastAccessedLesson) updates.lastAccessedLesson = "";
    if (!data.lastAccessedAt)
      updates.lastAccessedAt = admin.firestore.FieldValue.serverTimestamp();
    if (!data.completionPercentage) updates.completionPercentage = 0;

    if (Object.keys(updates).length > 0) {
      await doc.ref.update(updates);
      console.log(`✅ Updated progress: ${doc.id}`);
    }
  }

  // 6. Verify Quiz Questions Structure
  console.log("\n❓ Verifying quiz questions structure...");
  const quizzesSnapshot = await db.collection("quizzes").get();

  for (const quizDoc of quizzesSnapshot.docs) {
    const questionsSnapshot = await quizDoc.ref.collection("questions").get();
    console.log(`Quiz ${quizDoc.id} has ${questionsSnapshot.size} questions`);

    // Ensure each question has required fields
    for (const questionDoc of questionsSnapshot.docs) {
      const data = questionDoc.data();
      const updates = {};

      if (!data.orderIndex && data.orderIndex !== 0) {
        updates.orderIndex = parseInt(questionDoc.id.split("_").pop()) || 0;
      }
      if (!data.points) updates.points = 1;
      if (!data.difficulty) updates.difficulty = "easy";

      if (Object.keys(updates).length > 0) {
        await questionDoc.ref.update(updates);
        console.log(`  ✅ Updated question: ${questionDoc.id}`);
      }
    }
  }

  console.log("\n✨ Database structure fixes completed!");
}

// Run the fixes
fixDatabaseStructure().catch(console.error);

// Verification script to check data integrity
async function verifyDataIntegrity() {
  console.log("\n🔍 Verifying data integrity...\n");

  const issues = [];

  // Check courses
  const courses = await db.collection("courses").get();
  courses.forEach((doc) => {
    const data = doc.data();
    const requiredFields = [
      "title",
      "description",
      "language",
      "difficulty",
      "moduleCount",
    ];

    requiredFields.forEach((field) => {
      if (!data[field]) {
        issues.push(`Course ${doc.id} missing field: ${field}`);
      }
    });
  });

  // Check modules
  const modules = await db.collection("modules").get();
  modules.forEach((doc) => {
    const data = doc.data();
    if (!data.courseId) issues.push(`Module ${doc.id} missing courseId`);
    if (!data.lessonIds || !Array.isArray(data.lessonIds)) {
      issues.push(`Module ${doc.id} missing or invalid lessonIds`);
    }
  });

  // Check lessons
  const lessons = await db.collection("lessons").get();
  lessons.forEach((doc) => {
    const data = doc.data();
    if (!data.moduleId) issues.push(`Lesson ${doc.id} missing moduleId`);
    if (!data.courseId) issues.push(`Lesson ${doc.id} missing courseId`);
  });

  if (issues.length === 0) {
    console.log("✅ No data integrity issues found!");
  } else {
    console.log("⚠️  Found the following issues:");
    issues.forEach((issue) => console.log(`  - ${issue}`));
  }
}

verifyDataIntegrity().catch(console.error);
