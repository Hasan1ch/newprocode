// add_module_4_content.js
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

// Module 4 Lessons
const lessons = [
  {
    id: "python_fundamentals_m4_lesson_1",
    moduleId: "python_fundamentals_module_4",
    courseId: "python_fundamentals",
    title: "Introduction to Functions",
    content: `# Introduction to Functions

## What are Functions?

Functions are **reusable blocks of code** that:
- Perform specific tasks
- Reduce code duplication
- Make programs easier to understand
- Can be called multiple times

## Creating a Function

Use the **def** keyword:

\`\`\`python
def greet():
    print("Hello from a function!")
    print("Functions are awesome!")

# Call the function
greet()
greet()  # Can call it multiple times!
\`\`\`

## Why Use Functions?

Instead of:
\`\`\`python
print("=" * 30)
print("Welcome to ProCode")
print("=" * 30)

# Later in code...
print("=" * 30)
print("Thanks for learning!")
print("=" * 30)
\`\`\`

Use a function:
\`\`\`python
def print_banner(message):
    print("=" * 30)
    print(message)
    print("=" * 30)

print_banner("Welcome to ProCode")
print_banner("Thanks for learning!")
\`\`\`

## Function Structure

\`\`\`python
def function_name():
    # Function body
    # Code goes here
    pass  # Placeholder
\`\`\`

Functions make coding efficient! 🚀`,
    videoUrl: "",
    orderIndex: 0,
    estimatedMinutes: 20,
    xpReward: 10,
    codeExamples: [
      `# Simple functions
def say_hello():
    print("Hello, ProCoder!")

def show_menu():
    print("1. Start Game")
    print("2. Options")
    print("3. Quit")

def celebrate():
    print("🎉 Congratulations! 🎉")
    print("You completed the lesson!")

# Using the functions
say_hello()
show_menu()
celebrate()`,
      `# Functions save repetition
def draw_box():
    print("+" + "-" * 20 + "+")
    print("|" + " " * 20 + "|")
    print("|" + " " * 20 + "|")
    print("+" + "-" * 20 + "+")

# Draw multiple boxes easily
print("Box 1:")
draw_box()

print("\\nBox 2:")
draw_box()`,
    ],
    keyPoints: [
      "Functions are reusable blocks of code",
      "Define functions with the def keyword",
      "Call functions by name with parentheses",
      "Functions reduce code duplication",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m4_lesson_2",
    moduleId: "python_fundamentals_module_4",
    courseId: "python_fundamentals",
    title: "Function Parameters and Arguments",
    content: `# Function Parameters and Arguments

## Parameters

Functions can accept input values:

\`\`\`python
def greet(name):  # 'name' is a parameter
    print(f"Hello, {name}!")

# Call with argument
greet("Alice")  # "Alice" is an argument
greet("Bob")
\`\`\`

## Multiple Parameters

\`\`\`python
def introduce(name, age):
    print(f"I'm {name}, {age} years old")

introduce("Sarah", 25)
introduce("Tom", 30)
\`\`\`

## Default Parameters

Provide default values:

\`\`\`python
def greet(name="friend"):
    print(f"Hello, {name}!")

greet()          # Uses default: "Hello, friend!"
greet("Carlos")  # Uses argument: "Hello, Carlos!"
\`\`\`

## Keyword Arguments

Specify arguments by name:

\`\`\`python
def create_profile(name, age, city):
    print(f"Name: {name}")
    print(f"Age: {age}")
    print(f"City: {city}")

# Using keyword arguments
create_profile(city="New York", name="Emma", age=28)
\`\`\`

## Flexible Functions

\`\`\`python
def power(base, exponent=2):
    result = base ** exponent
    print(f"{base} to the power of {exponent} = {result}")

power(5)      # Uses default exponent: 2
power(3, 4)   # Custom exponent: 4
\`\`\`

Parameters make functions powerful! 💪`,
    videoUrl: "",
    orderIndex: 1,
    estimatedMinutes: 25,
    xpReward: 10,
    codeExamples: [
      `# Calculator functions
def add(a, b):
    result = a + b
    print(f"{a} + {b} = {result}")

def multiply(x, y):
    result = x * y
    print(f"{x} × {y} = {result}")

def calculate(num1, num2, operation="add"):
    if operation == "add":
        add(num1, num2)
    elif operation == "multiply":
        multiply(num1, num2)

# Using the calculator
calculate(5, 3)              # Default: addition
calculate(4, 7, "multiply")  # Multiplication`,
      `# Flexible greeting function
def super_greet(name, greeting="Hello", punctuation="!"):
    message = f"{greeting}, {name}{punctuation}"
    print(message)

# Different ways to call it
super_greet("Alice")
super_greet("Bob", "Hi")
super_greet("Charlie", "Hey", "...")
super_greet(name="David", punctuation="?", greeting="Howdy")`,
    ],
    keyPoints: [
      "Parameters are variables in function definition",
      "Arguments are values passed when calling",
      "Default parameters provide fallback values",
      "Keyword arguments can be in any order",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m4_lesson_3",
    moduleId: "python_fundamentals_module_4",
    courseId: "python_fundamentals",
    title: "Return Values",
    content: `# Return Values

## The Return Statement

Functions can send values back:

\`\`\`python
def add(a, b):
    result = a + b
    return result

# Store the returned value
sum_value = add(5, 3)
print(f"The sum is: {sum_value}")
\`\`\`

## Why Return Values?

Instead of just printing, functions can:
- Pass data to other functions
- Store results for later use
- Enable function chaining

\`\`\`python
def square(number):
    return number ** 2

def double(number):
    return number * 2

# Chain functions
result = double(square(3))  # First: 3² = 9, Then: 9 × 2 = 18
print(result)  # 18
\`\`\`

## Multiple Return Values

Python can return multiple values:

\`\`\`python
def get_min_max(numbers):
    return min(numbers), max(numbers)

lowest, highest = get_min_max([5, 2, 8, 1, 9])
print(f"Min: {lowest}, Max: {highest}")
\`\`\`

## Early Returns

Use return to exit early:

\`\`\`python
def check_age(age):
    if age < 0:
        return "Invalid age"
    if age >= 18:
        return "Adult"
    return "Minor"

status = check_age(25)
print(status)  # "Adult"
\`\`\`

Return values unlock function power! 🔓`,
    videoUrl: "",
    orderIndex: 2,
    estimatedMinutes: 30,
    xpReward: 10,
    codeExamples: [
      `# Math functions with returns
def calculate_area(length, width):
    return length * width

def calculate_perimeter(length, width):
    return 2 * (length + width)

# Using the functions
room_length = 5
room_width = 4

area = calculate_area(room_length, room_width)
perimeter = calculate_perimeter(room_length, room_width)

print(f"Room area: {area} square meters")
print(f"Room perimeter: {perimeter} meters")`,
      `# Grade calculator
def calculate_grade(score):
    if score >= 90:
        return "A", "Excellent!"
    elif score >= 80:
        return "B", "Good job!"
    elif score >= 70:
        return "C", "Keep it up!"
    elif score >= 60:
        return "D", "Need improvement"
    else:
        return "F", "Please see teacher"

# Get grade and feedback
test_score = 85
grade, feedback = calculate_grade(test_score)
print(f"Score: {test_score}")
print(f"Grade: {grade}")
print(f"Feedback: {feedback}")`,
    ],
    keyPoints: [
      "return sends values back from functions",
      "Functions without return implicitly return None",
      "Can return multiple values as a tuple",
      "return exits the function immediately",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m4_lesson_4",
    moduleId: "python_fundamentals_module_4",
    courseId: "python_fundamentals",
    title: "Scope and Documentation",
    content: `# Scope and Documentation

## Variable Scope

Variables have different **scopes**:

\`\`\`python
global_var = "I'm global!"

def my_function():
    local_var = "I'm local!"
    print(global_var)  # Can access global
    print(local_var)   # Can access local

my_function()
# print(local_var)  # Error! Not accessible outside
\`\`\`

## Local vs Global

\`\`\`python
name = "Global Alice"

def change_name():
    name = "Local Bob"  # Creates new local variable
    print(f"Inside function: {name}")

change_name()
print(f"Outside function: {name}")  # Still "Global Alice"
\`\`\`

## The global Keyword

Modify global variables:

\`\`\`python
counter = 0

def increment():
    global counter
    counter += 1

increment()
increment()
print(counter)  # 2
\`\`\`

## Docstrings

Document your functions:

\`\`\`python
def calculate_bmi(weight, height):
    """
    Calculate Body Mass Index.
    
    Args:
        weight: Weight in kilograms
        height: Height in meters
    
    Returns:
        BMI value as a float
    """
    bmi = weight / (height ** 2)
    return round(bmi, 2)

# Access docstring
print(calculate_bmi.__doc__)
\`\`\`

Write clean, documented functions! 📚`,
    videoUrl: "",
    orderIndex: 3,
    estimatedMinutes: 35,
    xpReward: 10,
    codeExamples: [
      `# Scope demonstration
player_score = 0  # Global variable

def add_points(points):
    """Add points to player score."""
    global player_score
    player_score += points
    print(f"Added {points} points!")

def get_bonus(level):
    """Calculate bonus based on level."""
    bonus_multiplier = 10  # Local variable
    bonus = level * bonus_multiplier
    return bonus

# Play game
add_points(50)
add_points(get_bonus(3))
print(f"Total score: {player_score}")`,
      `# Well-documented function
def validate_password(password):
    """
    Check if password meets security requirements.
    
    Requirements:
    - At least 8 characters long
    - Contains at least one digit
    - Contains at least one uppercase letter
    
    Args:
        password (str): The password to validate
        
    Returns:
        tuple: (is_valid, message)
    """
    if len(password) < 8:
        return False, "Password must be at least 8 characters"
    
    if not any(char.isdigit() for char in password):
        return False, "Password must contain a digit"
    
    if not any(char.isupper() for char in password):
        return False, "Password must contain uppercase letter"
    
    return True, "Password is strong!"

# Test the function
valid, message = validate_password("Python123")
print(message)`,
    ],
    keyPoints: [
      "Local variables exist only inside functions",
      "Global variables are accessible everywhere",
      "Use 'global' keyword to modify global variables",
      "Docstrings document function purpose and usage",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// Module 4 Quiz
const quiz = {
  id: "python_fundamentals_m4_quiz",
  title: "Functions Mastery Quiz",
  description: "Test your knowledge of functions, parameters, and returns",
  courseId: "python_fundamentals",
  moduleId: "python_fundamentals_module_4",
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

// Module 4 Quiz Questions
const questions = [
  {
    id: "python_fundamentals_m4_q1",
    type: "fill_code",
    question: "Complete the code to define a function:",
    codeSnippet: `___ say_hello():
    print("Hello!")`,
    options: ["def", "func", "function", "define"],
    correctAnswer: "def",
    explanation: "In Python, functions are defined using the 'def' keyword.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m4_q2",
    type: "code_output",
    question: "What will this code output?",
    codeSnippet: `def greet(name="World"):
    print(f"Hello, {name}!")

greet()`,
    options: ["Hello, World!", "Hello, !", "Error", "Nothing"],
    correctAnswer: "Hello, World!",
    explanation:
      "When no argument is provided, the default parameter value 'World' is used.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m4_q3",
    type: "mcq",
    question: "What does a function return if it has no return statement?",
    codeSnippet: null,
    options: ["0", "False", "None", "Empty string"],
    correctAnswer: "None",
    explanation:
      "Functions without an explicit return statement return None by default.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m4_q4",
    type: "boolean",
    question: "A function can return multiple values in Python.",
    codeSnippet: null,
    options: ["True", "False"],
    correctAnswer: "True",
    explanation:
      "Python functions can return multiple values as a tuple. Example: return x, y",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m4_q5",
    type: "code_output",
    question: "What value is stored in 'result'?",
    codeSnippet: `def add(a, b):
    return a + b

result = add(3, 5)`,
    options: ["8", "35", "None", "Error"],
    correctAnswer: "8",
    explanation:
      "The function adds 3 + 5 and returns 8, which is stored in 'result'.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m4_q6",
    type: "debug",
    question: "Fix the function call error:",
    codeSnippet: `def multiply(x, y):
    return x * y

result = multiply(5)`,
    options: ["multiply(5, 1)", "multiply[5]", "multiply{5}", "multiply 5"],
    correctAnswer: "multiply(5, 1)",
    explanation:
      "The multiply function expects 2 arguments, but only 1 was provided. Add a second argument.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m4_q7",
    type: "mcq",
    question: "Which variable is accessible outside the function?",
    codeSnippet: `x = 10  # Line 1

def my_func():
    y = 20  # Line 3`,
    options: ["Only x", "Only y", "Both x and y", "Neither"],
    correctAnswer: "Only x",
    explanation:
      "x is a global variable accessible everywhere. y is local to my_func and not accessible outside.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m4_q8",
    type: "fill_code",
    question: "Complete the code to access a global variable:",
    codeSnippet: `count = 0

def increment():
    ___ count
    count += 1`,
    options: ["global", "local", "var", "def"],
    correctAnswer: "global",
    explanation:
      "Use the 'global' keyword to modify a global variable inside a function.",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m4_q9",
    type: "mcq",
    question: "What are the values passed to a function called?",
    codeSnippet: null,
    options: ["Parameters", "Arguments", "Variables", "Returns"],
    correctAnswer: "Arguments",
    explanation:
      "Arguments are the actual values passed to a function. Parameters are the variables in the function definition.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m4_q10",
    type: "code_output",
    question: "What will this function return?",
    codeSnippet: `def check_even(num):
    if num % 2 == 0:
        return True
    return False

result = check_even(7)`,
    options: ["True", "False", "7", "None"],
    correctAnswer: "False",
    explanation: "7 % 2 equals 1 (not 0), so the function returns False.",
    difficulty: "easy",
    points: 1,
  },
];

async function addModule4Content() {
  console.log("🚀 Adding Module 4 content...\n");

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

    console.log("\n🎉 Module 4 content added successfully!");
    console.log("📝 Next: Run add_module_5_content.js");
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    process.exit(0);
  }
}

// Run the function
addModule4Content();
