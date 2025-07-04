// create_course.js
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

// Course data
const courseData = {
  id: "python_fundamentals",
  title: "Python Fundamentals",
  description:
    "Master Python basics with hands-on practice. Learn variables, data types, control flow, functions, and more through interactive lessons and real-world examples.",
  language: "python",
  difficulty: "beginner",
  estimatedHours: 20,
  moduleCount: 8,
  thumbnailUrl: "/images/courses/python_fundamentals.png",
  prerequisites: [],
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  icon: "🐍",
  enrolledCount: 0,
  rating: 0.0,
  xpReward: 100,
  tags: ["python", "programming", "beginner", "fundamentals"],
  isFeatured: true,
  category: "Programming Languages",
};

// Achievements data
const achievementsData = [
  {
    id: "first_steps",
    name: "First Steps",
    description: "Complete your first Python lesson",
    iconAsset: "/images/achievements/first_steps.png",
    xpReward: 25,
    category: "learning",
    rarity: "common",
    unlockedAt: null,
  },
  {
    id: "quiz_master_beginner",
    name: "Quiz Master: Beginner",
    description: "Pass 5 quizzes with a score of 80% or higher",
    iconAsset: "/images/achievements/quiz_master_bronze.png",
    xpReward: 50,
    category: "quiz",
    rarity: "rare",
    unlockedAt: null,
  },
  {
    id: "python_pioneer",
    name: "Python Pioneer",
    description: "Complete the Python Fundamentals course",
    iconAsset: "/images/achievements/python_pioneer.png",
    xpReward: 100,
    category: "learning",
    rarity: "epic",
    unlockedAt: null,
  },
  {
    id: "streak_week",
    name: "Week Warrior",
    description: "Maintain a 7-day learning streak",
    iconAsset: "/images/achievements/streak_week.png",
    xpReward: 35,
    category: "streak",
    rarity: "rare",
    unlockedAt: null,
  },
  {
    id: "night_owl",
    name: "Night Owl",
    description: "Complete 5 lessons after 10 PM",
    iconAsset: "/images/achievements/night_owl.png",
    xpReward: 30,
    category: "learning",
    rarity: "rare",
    unlockedAt: null,
  },
];

async function createCourse() {
  console.log("🚀 Creating Python Fundamentals course...\n");

  try {
    // Create course
    console.log("📚 Creating course...");
    await db.collection("courses").doc(courseData.id).set(courseData);
    console.log("✅ Course created successfully!");

    // Create achievements
    console.log("\n🏆 Creating achievements...");
    for (const achievement of achievementsData) {
      await db.collection("achievements").doc(achievement.id).set(achievement);
      console.log(`✅ Achievement created: ${achievement.name}`);
    }

    console.log("\n🎉 Course and achievements created successfully!");
    console.log("📝 Next: Run create_modules.js");
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    process.exit(0);
  }
}

// Run the function
createCourse();
