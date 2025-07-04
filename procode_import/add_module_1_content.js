// add_module_1_content.js
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

// Module 1 Lessons
const lessons = [
  {
    id: "python_fundamentals_m1_lesson_1",
    moduleId: "python_fundamentals_module_1",
    courseId: "python_fundamentals",
    title: "Welcome to Python Programming",
    content: `# Welcome to Python Programming

## What is Python?

Python is a **high-level**, **interpreted** programming language known for its simplicity and readability. Created by Guido van Rossum in 1991, Python has become one of the most popular programming languages in the world.

## Why Learn Python?

### 1. Easy to Learn
Python's syntax is clear and intuitive, making it perfect for beginners:

\`\`\`python
# This is how simple Python can be!
print("Hello, World!")
\`\`\`

### 2. Versatile
Python is used in:
- **Web Development** (Django, Flask)
- **Data Science** (NumPy, Pandas)
- **Machine Learning** (TensorFlow, PyTorch)
- **Automation** (Scripts, Bots)
- **Game Development** (Pygame)

### 3. Large Community
Python has a massive community of developers who:
- Create helpful libraries
- Answer questions on forums
- Share code and tutorials

## Ready to Code?

Let's begin your Python journey! 🚀`,
    videoUrl: "",
    orderIndex: 0,
    estimatedMinutes: 15,
    xpReward: 10,
    codeExamples: [
      `# Your first Python program
print("Hello, ProCode!")

# Python can do math
print(2 + 2)

# And work with text
name = "Python Programmer"
print(f"I am a {name}!")`,
    ],
    keyPoints: [
      "Python is a beginner-friendly programming language",
      "It's used in web development, data science, AI, and more",
      "Python emphasizes code readability and simplicity",
      "You'll learn by doing hands-on coding exercises",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m1_lesson_2",
    moduleId: "python_fundamentals_module_1",
    courseId: "python_fundamentals",
    title: "Setting Up Your Python Environment",
    content: `# Setting Up Your Python Environment

## Installing Python

Visit python.org and download the latest version.

### Windows:
- Run the installer
- ✅ Check "Add Python to PATH"
- Click "Install Now"

### Mac:
- Open the .pkg file
- Follow the installation wizard

### Linux:
\`\`\`bash
sudo apt update
sudo apt install python3
\`\`\`

## Verify Installation

\`\`\`bash
python --version
\`\`\`

## Choosing an Editor

### Recommended Options:
1. **VS Code** - Free, powerful, great extensions
2. **PyCharm** - Full-featured Python IDE
3. **IDLE** - Comes with Python, simple to use
4. **Jupyter Notebook** - Great for learning

## Your First Python File

1. Create a new file called \`hello.py\`
2. Add this code:
\`\`\`python
print("Python is installed correctly!")
\`\`\`
3. Run it: \`python hello.py\`

You're all set up! Let's write some Python! 🎉`,
    videoUrl: "",
    orderIndex: 1,
    estimatedMinutes: 20,
    xpReward: 10,
    codeExamples: [
      `# Check Python version
import sys
print(f"Python version: {sys.version}")

# Check if Python is working
print("If you see this, Python is working!")

# See where Python is installed
print(f"Python executable: {sys.executable}")`,
    ],
    keyPoints: [
      "Install Python 3.x from python.org",
      "Add Python to your system PATH",
      "Choose an editor like VS Code or IDLE",
      "Verify installation with python --version",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m1_lesson_3",
    moduleId: "python_fundamentals_module_1",
    courseId: "python_fundamentals",
    title: "Writing Your First Python Program",
    content: `# Writing Your First Python Program

## The Classic "Hello, World!"

Every programmer's journey begins with this simple program:

\`\`\`python
print("Hello, World!")
\`\`\`

## Understanding print()

The \`print()\` function displays output:

\`\`\`python
print("Welcome to ProCode!")
print("I'm learning Python")
print("This is fun!")
\`\`\`

## Adding Comments

Comments explain your code:

\`\`\`python
# This is a comment - Python ignores it
print("Hello")  # This is also a comment

# You can have multiple lines of comments
# to explain complex code
# Comments are for humans, not computers
\`\`\`

## Making It Interactive

Get input from users:

\`\`\`python
# Ask for the user's name
name = input("What's your name? ")

# Greet them personally
print("Hello, " + name + "!")
print(f"Nice to meet you, {name}")
\`\`\`

## Your Turn!

Try creating a program that:
1. Asks for the user's name
2. Asks for their favorite color
3. Prints a personalized message

Congratulations! You've written your first Python programs! 🎉`,
    videoUrl: "",
    orderIndex: 2,
    estimatedMinutes: 25,
    xpReward: 10,
    codeExamples: [
      `# A complete first program
# This program greets the user

print("=" * 30)
print("Welcome to My First Program!")
print("=" * 30)

# Get user information
name = input("What's your name? ")
age = input("How old are you? ")

# Display personalized message
print(f"\\nHello {name}!")
print(f"Wow, {age} is a great age to learn Python!")
print("\\nHappy coding! 🐍")`,
    ],
    keyPoints: [
      "print() displays output to the screen",
      "input() gets text from the user",
      "Comments start with # and explain code",
      "f-strings (f'') allow variable insertion",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// Module 1 Quiz
const quiz = {
  id: "python_fundamentals_m1_quiz",
  title: "Getting Started with Python Quiz",
  description: "Test your knowledge of Python basics and setup",
  courseId: "python_fundamentals",
  moduleId: "python_fundamentals_module_1",
  difficulty: "easy",
  category: "python_basics",
  timeLimit: 600,
  passingScore: 70,
  totalQuestions: 10,
  xpReward: 20,
  isActive: true,
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
};

// Module 1 Quiz Questions (all 10)
const questions = [
  {
    id: "python_fundamentals_m1_q1",
    type: "mcq",
    question: "What type of programming language is Python?",
    codeSnippet: null,
    options: [
      "Low-level compiled language",
      "High-level interpreted language",
      "Assembly language",
      "Machine code language",
    ],
    correctAnswer: "High-level interpreted language",
    explanation:
      "Python is a high-level interpreted language, meaning it's easy for humans to read and write, and code is executed line by line without compilation.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m1_q2",
    type: "code_output",
    question: "What will this code output?",
    codeSnippet: `print("Hello")
print("World")`,
    options: ["HelloWorld", "Hello World", "Hello\\nWorld", "Hello\\nWorld\\n"],
    correctAnswer: "Hello\\nWorld",
    explanation:
      "Each print() statement outputs text on a new line. The \\n represents a newline character.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m1_q3",
    type: "boolean",
    question: "Python code must be compiled before it can run.",
    codeSnippet: null,
    options: ["True", "False"],
    correctAnswer: "False",
    explanation:
      "Python is an interpreted language. Code is executed directly by the Python interpreter without a separate compilation step.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m1_q4",
    type: "fill_code",
    question: "Complete the code to print 'Welcome to ProCode'",
    codeSnippet: `___("Welcome to ProCode")`,
    options: ["print", "display", "output", "show"],
    correctAnswer: "print",
    explanation: "The print() function is used to display output in Python.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m1_q5",
    type: "mcq",
    question: "Which of these is the correct way to write a comment in Python?",
    codeSnippet: null,
    options: [
      "// This is a comment",
      "/* This is a comment */",
      "# This is a comment",
      "<!-- This is a comment -->",
    ],
    correctAnswer: "# This is a comment",
    explanation: "In Python, single-line comments start with the # symbol.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m1_q6",
    type: "mcq",
    question: "Which file extension is used for Python files?",
    codeSnippet: null,
    options: [".python", ".py", ".pyt", ".pt"],
    correctAnswer: ".py",
    explanation: "Python files use the .py extension. For example: script.py",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m1_q7",
    type: "debug",
    question: "Fix the error in this code:",
    codeSnippet: `# Trying to print a greeting
Print("Hello, Python!")`,
    options: ["print", "PRINT", "printf", "display"],
    correctAnswer: "print",
    explanation:
      "Python is case-sensitive. The print function must be lowercase: print(), not Print().",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m1_q8",
    type: "boolean",
    question:
      "You need to add a semicolon (;) at the end of every Python statement.",
    codeSnippet: null,
    options: ["True", "False"],
    correctAnswer: "False",
    explanation:
      "Unlike languages like Java or C++, Python doesn't require semicolons at the end of statements. They're optional and rarely used.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m1_q9",
    type: "code_output",
    question: "What will this code output?",
    codeSnippet: `# Getting user input
name = "ProCoder"
print("Welcome,", name)`,
    options: [
      "Welcome, ProCoder",
      "Welcome,ProCoder",
      "Welcome ProCoder",
      "WelcomeProCoder",
    ],
    correctAnswer: "Welcome, ProCoder",
    explanation:
      "When print() receives multiple arguments separated by commas, it adds a space between them automatically.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m1_q10",
    type: "mcq",
    question: "What is IDLE in the context of Python?",
    codeSnippet: null,
    options: [
      "A Python framework",
      "Python's Integrated Development and Learning Environment",
      "A Python library",
      "A Python database",
    ],
    correctAnswer: "Python's Integrated Development and Learning Environment",
    explanation:
      "IDLE is Python's built-in IDE (Integrated Development and Learning Environment) that comes with Python installation.",
    difficulty: "easy",
    points: 1,
  },
];

async function addModule1Content() {
  console.log("🚀 Adding Module 1 content...\n");

  try {
    // Add lessons
    console.log("📚 Adding lessons...");
    for (const lesson of lessons) {
      await db.collection("lessons").doc(lesson.id).set(lesson);
      console.log(`✅ Lesson added: ${lesson.title}`);
    }

    // Add quiz
    console.log("\n📝 Creating quiz...");
    await db.collection("quizzes").doc(quiz.id).set(quiz);
    console.log("✅ Quiz created");

    // Add questions
    console.log("\n❓ Adding quiz questions...");
    const quizRef = db.collection("quizzes").doc(quiz.id);
    for (const question of questions) {
      await quizRef.collection("questions").doc(question.id).set(question);
      console.log(`✅ Question ${question.id.slice(-1)} added`);
    }

    console.log("\n🎉 Module 1 content added successfully!");
    console.log("📝 Next: Run add_module_2_content.js");
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    process.exit(0);
  }
}

// Run the function
addModule1Content();
