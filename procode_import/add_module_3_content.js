// add_module_3_content.js
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

// Module 3 Lessons
const lessons = [
  {
    id: "python_fundamentals_m3_lesson_1",
    moduleId: "python_fundamentals_module_3",
    courseId: "python_fundamentals",
    title: "Making Decisions with If Statements",
    content: `# Making Decisions with If Statements

## Why Control Flow?

Programs need to make decisions! Control flow lets your code:
- React to different situations
- Choose between options
- Create dynamic behavior

## The If Statement

The basic structure:

\`\`\`python
if condition:
    # Code runs if condition is True
    print("This runs when condition is True")
\`\`\`

## Real Example

\`\`\`python
age = 18

if age >= 18:
    print("You can vote!")
    print("You're an adult")
\`\`\`

## Comparison Operators

Python uses these to compare values:
- **==** Equal to
- **!=** Not equal to
- **>** Greater than
- **<** Less than
- **>=** Greater than or equal
- **<=** Less than or equal

## Practice Time!

\`\`\`python
temperature = 25

if temperature > 30:
    print("It's hot outside!")

if temperature < 10:
    print("It's cold, wear a jacket!")
\`\`\`

Remember: Indentation matters in Python! 🎯`,
    videoUrl: "",
    orderIndex: 0,
    estimatedMinutes: 20,
    xpReward: 10,
    codeExamples: [
      `# Check if a number is positive
number = 42

if number > 0:
    print(f"{number} is positive!")

# Check password length
password = "secretpass123"

if len(password) >= 8:
    print("Password is long enough")`,
      `# Multiple conditions
score = 85
attendance = 90

if score >= 80:
    if attendance >= 75:
        print("Great job! You passed with good attendance!")`,
    ],
    keyPoints: [
      "If statements let programs make decisions",
      "Conditions evaluate to True or False",
      "Indentation defines code blocks in Python",
      "Comparison operators compare values",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m3_lesson_2",
    moduleId: "python_fundamentals_module_3",
    courseId: "python_fundamentals",
    title: "If-Else and Elif Statements",
    content: `# If-Else and Elif Statements

## The Else Statement

What if the condition is False? Use **else**:

\`\`\`python
age = 16

if age >= 18:
    print("You can vote!")
else:
    print("Too young to vote")
    print(f"Wait {18 - age} more years")
\`\`\`

## Multiple Choices with Elif

**elif** (else if) checks multiple conditions:

\`\`\`python
score = 85

if score >= 90:
    grade = "A"
elif score >= 80:
    grade = "B"
elif score >= 70:
    grade = "C"
elif score >= 60:
    grade = "D"
else:
    grade = "F"

print(f"Your grade is: {grade}")
\`\`\`

## Logical Operators

Combine conditions with:
- **and** - Both must be True
- **or** - At least one must be True
- **not** - Reverses True/False

\`\`\`python
age = 25
has_license = True

if age >= 18 and has_license:
    print("You can drive!")

weekend = True
holiday = False

if weekend or holiday:
    print("No work today!")
\`\`\`

Let's build smarter programs! 🧠`,
    videoUrl: "",
    orderIndex: 1,
    estimatedMinutes: 25,
    xpReward: 10,
    codeExamples: [
      `# Weather advice system
temperature = 22
is_raining = False

if temperature < 0:
    print("It's freezing! Bundle up!")
elif temperature < 10:
    print("It's cold, wear a warm coat")
elif temperature < 20:
    print("It's cool, a light jacket will do")
elif temperature < 30:
    if is_raining:
        print("Nice temperature but take an umbrella!")
    else:
        print("Perfect weather!")
else:
    print("It's hot! Stay hydrated!")`,
      `# Login system
username = "pythonista"
password = "code123"

correct_username = "pythonista"
correct_password = "code123"

if username == correct_username and password == correct_password:
    print("Welcome back!")
    print("Login successful ✅")
else:
    print("Invalid credentials ❌")
    if username != correct_username:
        print("Username not found")`,
    ],
    keyPoints: [
      "else provides alternative when if is False",
      "elif checks multiple conditions in order",
      "Logical operators (and, or, not) combine conditions",
      "Only one block executes in if-elif-else chain",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m3_lesson_3",
    moduleId: "python_fundamentals_module_3",
    courseId: "python_fundamentals",
    title: "Loops - While and For",
    content: `# Loops - While and For

## Why Use Loops?

Loops repeat code automatically! Instead of:
\`\`\`python
print("Hello!")
print("Hello!")
print("Hello!")
\`\`\`

We can write:
\`\`\`python
for i in range(3):
    print("Hello!")
\`\`\`

## The While Loop

Repeats **while** a condition is True:

\`\`\`python
count = 0
while count < 5:
    print(f"Count is: {count}")
    count += 1  # Same as count = count + 1

print("Loop finished!")
\`\`\`

## The For Loop

Iterates over sequences:

\`\`\`python
# Loop through a range
for number in range(5):
    print(f"Number: {number}")

# Loop through a list
fruits = ["apple", "banana", "orange"]
for fruit in fruits:
    print(f"I like {fruit}")

# Loop through a string
for letter in "Python":
    print(letter)
\`\`\`

## Range Function

\`\`\`python
range(5)        # 0, 1, 2, 3, 4
range(1, 6)     # 1, 2, 3, 4, 5
range(0, 10, 2) # 0, 2, 4, 6, 8
\`\`\`

Master loops to automate everything! 🔄`,
    videoUrl: "",
    orderIndex: 2,
    estimatedMinutes: 30,
    xpReward: 10,
    codeExamples: [
      `# Countdown timer
countdown = 10
print("🚀 Launching in...")

while countdown > 0:
    print(f"{countdown}...")
    countdown -= 1

print("BLAST OFF! 🚀")

# Sum calculator
total = 0
for num in range(1, 11):
    total += num
    print(f"Adding {num}, total is now: {total}")

print(f"\\nSum of 1 to 10 is: {total}")`,
      `# Password validator with attempts
correct_password = "python123"
attempts = 3

while attempts > 0:
    password = input("Enter password: ")
    
    if password == correct_password:
        print("Access granted! ✅")
        break  # Exit the loop
    else:
        attempts -= 1
        if attempts > 0:
            print(f"Wrong password. {attempts} attempts left")
        else:
            print("Account locked! 🔒")`,
    ],
    keyPoints: [
      "While loops repeat while condition is True",
      "For loops iterate over sequences",
      "range() generates number sequences",
      "break exits a loop early",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m3_lesson_4",
    moduleId: "python_fundamentals_module_3",
    courseId: "python_fundamentals",
    title: "Loop Control - Break, Continue, and Nested Loops",
    content: `# Loop Control - Break, Continue, and Nested Loops

## Break Statement

**break** exits the loop immediately:

\`\`\`python
# Find first even number
for num in range(1, 10):
    if num % 2 == 0:
        print(f"First even number: {num}")
        break
\`\`\`

## Continue Statement

**continue** skips to next iteration:

\`\`\`python
# Print only odd numbers
for num in range(10):
    if num % 2 == 0:
        continue  # Skip even numbers
    print(f"Odd: {num}")
\`\`\`

## Nested Loops

Loops inside loops:

\`\`\`python
# Multiplication table
for i in range(1, 4):
    for j in range(1, 4):
        result = i * j
        print(f"{i} × {j} = {result}")
    print()  # Empty line between tables
\`\`\`

## Else with Loops

Runs when loop completes normally:

\`\`\`python
for num in range(2, 10):
    if num > 5:
        break
else:
    print("Loop completed without break")
\`\`\`

## Practical Examples

\`\`\`python
# Menu system
while True:
    print("\\n1. Play")
    print("2. Settings")
    print("3. Quit")
    
    choice = input("Choose: ")
    
    if choice == "3":
        print("Goodbye!")
        break
    elif choice == "1":
        print("Starting game...")
    elif choice == "2":
        print("Opening settings...")
\`\`\`

You're now a loop master! 🎓`,
    videoUrl: "",
    orderIndex: 3,
    estimatedMinutes: 35,
    xpReward: 10,
    codeExamples: [
      `# Pattern printer
rows = 5
for i in range(1, rows + 1):
    for j in range(i):
        print("*", end=" ")
    print()  # New line

# Output:
# *
# * *
# * * *
# * * * *
# * * * * *`,
      `# Prime number checker
number = 17
is_prime = True

if number < 2:
    is_prime = False
else:
    for divisor in range(2, number):
        if number % divisor == 0:
            is_prime = False
            break

if is_prime:
    print(f"{number} is prime! 🌟")
else:
    print(f"{number} is not prime")`,
    ],
    keyPoints: [
      "break exits the loop completely",
      "continue skips to next iteration",
      "Nested loops create powerful patterns",
      "else with loops runs if no break occurred",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// Module 3 Quiz
const quiz = {
  id: "python_fundamentals_m3_quiz",
  title: "Control Flow Mastery Quiz",
  description: "Test your knowledge of if statements, loops, and program flow",
  courseId: "python_fundamentals",
  moduleId: "python_fundamentals_module_3",
  difficulty: "easy",
  category: "python_basics",
  timeLimit: 600,
  passingScore: 70,
  totalQuestions: 10,
  xpReward: 30,
  isActive: true,
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
};

// Module 3 Quiz Questions
const questions = [
  {
    id: "python_fundamentals_m3_q1",
    type: "code_output",
    question: "What will this code output?",
    codeSnippet: `x = 10
if x > 5:
    print("Big")
else:
    print("Small")`,
    options: ["Big", "Small", "10", "Error"],
    correctAnswer: "Big",
    explanation:
      "Since 10 > 5 is True, the if block executes and prints 'Big'.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m3_q2",
    type: "mcq",
    question: "Which operator checks if two values are NOT equal?",
    codeSnippet: null,
    options: ["==", "!=", "<>", "=/="],
    correctAnswer: "!=",
    explanation:
      "The != operator checks if two values are not equal. For example: 5 != 3 is True.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m3_q3",
    type: "fill_code",
    question: "Complete the code to check if age is 18 or older:",
    codeSnippet: `age = 20
if age ___ 18:
    print("Adult")`,
    options: [">=", ">", "==", "<="],
    correctAnswer: ">=",
    explanation: "Use >= to check if age is greater than or equal to 18.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m3_q4",
    type: "code_output",
    question: "What will this loop print?",
    codeSnippet: `for i in range(3):
    print(i)`,
    options: ["0\\n1\\n2", "1\\n2\\n3", "0\\n1\\n2\\n3", "Error"],
    correctAnswer: "0\\n1\\n2",
    explanation:
      "range(3) generates numbers 0, 1, 2. The loop prints each on a new line.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m3_q5",
    type: "boolean",
    question:
      "The 'break' statement exits only the current iteration of a loop.",
    codeSnippet: null,
    options: ["True", "False"],
    correctAnswer: "False",
    explanation:
      "The 'break' statement exits the entire loop, not just the current iteration. 'continue' skips only the current iteration.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m3_q6",
    type: "mcq",
    question: "What does 'elif' stand for in Python?",
    codeSnippet: null,
    options: ["else if", "equal if", "end if", "exit if"],
    correctAnswer: "else if",
    explanation:
      "'elif' is short for 'else if' and is used to check multiple conditions in sequence.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m3_q7",
    type: "debug",
    question: "Fix the indentation error:",
    codeSnippet: `x = 5
if x > 0:
print("Positive")`,
    options: [
      "Add 4 spaces before print",
      "Remove if statement",
      "Add colon after print",
      "Change x to 0",
    ],
    correctAnswer: "Add 4 spaces before print",
    explanation:
      "Python requires proper indentation. Code inside an if block must be indented.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m3_q8",
    type: "code_output",
    question: "How many times will this loop run?",
    codeSnippet: `count = 0
while count < 3:
    count += 1`,
    options: ["2 times", "3 times", "4 times", "Forever"],
    correctAnswer: "3 times",
    explanation:
      "The loop runs when count is 0, 1, and 2. When count becomes 3, the condition count < 3 is False.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m3_q9",
    type: "mcq",
    question:
      "Which logical operator returns True if BOTH conditions are True?",
    codeSnippet: null,
    options: ["and", "or", "not", "both"],
    correctAnswer: "and",
    explanation:
      "The 'and' operator returns True only when both conditions are True. For example: (5 > 3 and 2 < 4) is True.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m3_q10",
    type: "code_output",
    question: "What will this nested loop output?",
    codeSnippet: `for i in range(2):
    for j in range(2):
        print(i, j)`,
    options: [
      "0 0\\n0 1\\n1 0\\n1 1",
      "0 1\\n1 0",
      "0 0\\n1 1",
      "0\\n1\\n0\\n1",
    ],
    correctAnswer: "0 0\\n0 1\\n1 0\\n1 1",
    explanation:
      "The outer loop runs twice (i=0,1) and for each i, the inner loop runs twice (j=0,1), printing all combinations.",
    difficulty: "medium",
    points: 1,
  },
];

async function addModule3Content() {
  console.log("🚀 Adding Module 3 content...\n");

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

    console.log("\n🎉 Module 3 content added successfully!");
    console.log("📝 Next: Run add_module_4_content.js");
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    process.exit(0);
  }
}

// Run the function
addModule3Content();
