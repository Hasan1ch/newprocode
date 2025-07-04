// add_module_2_content.js
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

// Module 2 Lessons: Variables and Data Types
const lessons = [
  {
    id: "python_fundamentals_m2_lesson_1",
    moduleId: "python_fundamentals_module_2",
    courseId: "python_fundamentals",
    title: "Introduction to Variables",
    content: `# Introduction to Variables

## What Are Variables?

Variables are like **containers** that store data values. Think of them as labeled boxes where you can put different types of information.

## Creating Variables

In Python, creating a variable is simple:

\`\`\`python
# Creating variables
message = "Hello, ProCode!"
age = 25
is_student = True
\`\`\`

## Variable Rules

### ✅ Valid Variable Names:
\`\`\`python
user_name = "John"
firstName = "Jane"
age2 = 30
_private = "secret"
CONSTANT = 100
\`\`\`

### ❌ Invalid Variable Names:
\`\`\`python
# These will cause errors!
2name = "Error"      # Can't start with number
my-var = "Error"     # No hyphens allowed
my var = "Error"     # No spaces allowed
class = "Error"      # Can't use keywords
\`\`\`

## Variable Naming Conventions

Python developers follow these conventions:
- **snake_case** for regular variables: \`user_age\`, \`total_score\`
- **UPPER_SNAKE_CASE** for constants: \`MAX_USERS\`, \`PI\`
- **camelCase** sometimes used but less common: \`firstName\`

## Dynamic Typing

Python is **dynamically typed**, meaning variables can change types:

\`\`\`python
x = 5           # x is an integer
x = "Hello"     # Now x is a string
x = True        # Now x is a boolean
\`\`\`

Remember: Choose descriptive variable names that explain what the data represents! 📝`,
    videoUrl: "",
    orderIndex: 0,
    estimatedMinutes: 30,
    xpReward: 10,
    codeExamples: [
      `# Creating and using variables
name = "Alice"
age = 25
height = 5.6
is_programmer = True

# Printing variables
print("Name:", name)
print("Age:", age)
print("Height:", height)
print("Is Programmer:", is_programmer)

# Variables can be reassigned
score = 100
print("Initial score:", score)
score = score + 50
print("New score:", score)`,
    ],
    keyPoints: [
      "Variables store data values in Python",
      "Variable names must start with letter or underscore",
      "Python is dynamically typed - variables can change types",
      "Use descriptive names following snake_case convention",
      "Variables can be reassigned to new values",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m2_lesson_2",
    moduleId: "python_fundamentals_module_2",
    courseId: "python_fundamentals",
    title: "Numbers: Integers and Floats",
    content: `# Numbers: Integers and Floats

## Integer (int)

Integers are whole numbers without decimal points:

\`\`\`python
age = 25
score = -100
big_number = 1_000_000  # Underscores for readability
\`\`\`

## Float (float)

Floats are numbers with decimal points:

\`\`\`python
price = 19.99
temperature = -5.2
pi = 3.14159
scientific = 1.23e-4  # Scientific notation
\`\`\`

## Basic Math Operations

\`\`\`python
# Addition
total = 10 + 5      # 15

# Subtraction  
difference = 20 - 8  # 12

# Multiplication
product = 4 * 7     # 28

# Division (always returns float)
quotient = 15 / 3   # 5.0

# Floor Division (integer division)
floor_div = 17 // 5  # 3

# Modulo (remainder)
remainder = 17 % 5   # 2

# Exponentiation (power)
power = 2 ** 3      # 8
\`\`\`

## Type Conversion

\`\`\`python
# Convert to int
x = int(3.7)        # 3 (truncates decimal)
y = int("42")       # 42 (string to int)

# Convert to float
a = float(5)        # 5.0
b = float("3.14")   # 3.14

# Check type
print(type(42))     # <class 'int'>
print(type(3.14))   # <class 'float'>
\`\`\`

## Useful Number Functions

\`\`\`python
# Absolute value
print(abs(-10))     # 10

# Rounding
print(round(3.7))   # 4
print(round(3.14159, 2))  # 3.14

# Min and Max
print(min(5, 10, 3))      # 3
print(max(5, 10, 3))      # 10
\`\`\`

Numbers are the foundation of programming - master them well! 🔢`,
    videoUrl: "",
    orderIndex: 1,
    estimatedMinutes: 35,
    xpReward: 10,
    codeExamples: [
      `# Working with numbers
# Integers
students = 30
books = 45
total_items = students + books
print(f"Total items: {total_items}")

# Floats
price = 29.99
tax_rate = 0.08
tax = price * tax_rate
total = price + tax
print(f"Price: \${price}")
print(f"Tax: \${tax:.2f}")
print(f"Total: \${total:.2f}")

# Mixed operations
average = total_items / 2
print(f"Average: {average}")  # Float result

# Type checking
print(f"Is 42 an int? {isinstance(42, int)}")
print(f"Is 3.14 a float? {isinstance(3.14, float)}")`,
    ],
    keyPoints: [
      "Integers (int) are whole numbers",
      "Floats (float) are decimal numbers",
      "Division (/) always returns a float",
      "Use // for integer division and % for remainder",
      "Convert between types with int() and float()",
      "Python supports all basic mathematical operations",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m2_lesson_3",
    moduleId: "python_fundamentals_module_2",
    courseId: "python_fundamentals",
    title: "Strings and Text Manipulation",
    content: `# Strings and Text Manipulation

## Creating Strings

Strings are sequences of characters enclosed in quotes:

\`\`\`python
# Single quotes
name = 'Alice'

# Double quotes  
message = "Hello, World!"

# Triple quotes for multiline
poem = """Roses are red,
Violets are blue,
Python is awesome,
And so are you!"""
\`\`\`

## String Concatenation

\`\`\`python
# Using + operator
first = "Pro"
last = "Code"
full = first + last  # "ProCode"

# Using f-strings (recommended!)
name = "Alice"
age = 25
intro = f"My name is {name} and I'm {age} years old"

# Using .format()
template = "Welcome to {}, {}!"
message = template.format("ProCode", name)
\`\`\`

## String Methods

\`\`\`python
text = "Hello, ProCode!"

# Case methods
print(text.upper())      # HELLO, PROCODE!
print(text.lower())      # hello, procode!
print(text.title())      # Hello, Procode!

# Searching
print(text.startswith("Hello"))  # True
print(text.endswith("!"))        # True
print("Pro" in text)             # True
print(text.find("Code"))         # 10 (index)

# Modifying
print(text.replace("Hello", "Hi"))  # Hi, ProCode!
print("  spaces  ".strip())         # "spaces"
print("a,b,c".split(","))          # ['a', 'b', 'c']
\`\`\`

## String Indexing and Slicing

\`\`\`python
word = "Python"

# Indexing (0-based)
print(word[0])    # 'P' (first character)
print(word[-1])   # 'n' (last character)

# Slicing [start:end:step]
print(word[0:3])  # 'Pyt'
print(word[2:])   # 'thon'
print(word[:4])   # 'Pyth'
print(word[::2])  # 'Pto' (every 2nd char)
\`\`\`

## Escape Characters

\`\`\`python
# Common escape sequences
print("Line 1\\nLine 2")    # New line
print("Tab\\there")         # Tab
print("Quote: \\"Hello\\"")  # Quotes
print("Backslash: \\\\")     # Backslash
\`\`\`

Master strings and you'll handle text like a pro! 📝`,
    videoUrl: "",
    orderIndex: 2,
    estimatedMinutes: 40,
    xpReward: 10,
    codeExamples: [
      `# String operations showcase
# Creating and combining strings
first_name = "John"
last_name = "Doe"
full_name = f"{first_name} {last_name}"
print(f"Full name: {full_name}")

# String methods in action
email = "  John.Doe@ProCode.com  "
clean_email = email.strip().lower()
print(f"Cleaned email: {clean_email}")

# Checking email validity
if "@" in clean_email and clean_email.endswith(".com"):
    print("Valid email format!")

# String manipulation
username = clean_email.split("@")[0]
domain = clean_email.split("@")[1]
print(f"Username: {username}")
print(f"Domain: {domain}")

# Building a message
stars = "*" * 20
message = f"""
{stars}
Welcome {first_name}!
Your username: {username}
{stars}
"""
print(message)`,
    ],
    keyPoints: [
      "Strings are created with single, double, or triple quotes",
      "f-strings (f'{}') are the best way to format strings",
      "Strings have many useful methods like upper(), lower(), strip()",
      "Access characters with indexing [0] and slicing [start:end]",
      "Strings are immutable - methods return new strings",
      "Use escape characters for special characters like \\n",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m2_lesson_4",
    moduleId: "python_fundamentals_module_2",
    courseId: "python_fundamentals",
    title: "Booleans and Type Checking",
    content: `# Booleans and Type Checking

## Boolean Values

Booleans represent truth values - either True or False:

\`\`\`python
is_active = True
is_complete = False

# Boolean from comparisons
age = 18
is_adult = age >= 18  # True
\`\`\`

## Comparison Operators

\`\`\`python
x = 10
y = 5

# Equality
print(x == y)   # False (equal to)
print(x != y)   # True  (not equal to)

# Comparison
print(x > y)    # True  (greater than)
print(x < y)    # False (less than)
print(x >= 10)  # True  (greater or equal)
print(y <= 5)   # True  (less or equal)
\`\`\`

## Logical Operators

\`\`\`python
# AND - both must be True
age = 25
has_license = True
can_drive = age >= 16 and has_license  # True

# OR - at least one must be True
is_weekend = False
is_holiday = True
day_off = is_weekend or is_holiday     # True

# NOT - inverts the value
is_raining = False
is_sunny = not is_raining              # True
\`\`\`

## Truthy and Falsy Values

In Python, some values are considered "falsy":

\`\`\`python
# Falsy values
print(bool(0))        # False
print(bool(""))       # False (empty string)
print(bool([]))       # False (empty list)
print(bool(None))     # False

# Truthy values
print(bool(42))       # True (non-zero)
print(bool("Hello"))  # True (non-empty)
print(bool([1, 2]))   # True (non-empty)
\`\`\`

## Type Checking

\`\`\`python
# Using type()
x = 42
print(type(x))        # <class 'int'>

# Using isinstance()
print(isinstance(x, int))        # True
print(isinstance(x, str))        # False

# Checking multiple types
value = 3.14
print(isinstance(value, (int, float)))  # True

# Getting type name
print(type(x).__name__)          # 'int'
\`\`\`

## Practical Examples

\`\`\`python
# User validation
username = "ProCoder"
password = "secure123"

# Check conditions
is_valid_username = len(username) >= 3
is_valid_password = len(password) >= 8
has_number = any(char.isdigit() for char in password)

is_valid = is_valid_username and is_valid_password and has_number
print(f"Registration valid: {is_valid}")
\`\`\`

Booleans are the decision-makers in your code! 🎯`,
    videoUrl: "",
    orderIndex: 3,
    estimatedMinutes: 30,
    xpReward: 10,
    codeExamples: [
      `# Boolean operations demonstration
# User input validation
username = "ProCoder123"
age = 19
email = "user@procode.com"
terms_accepted = True

# Validation checks
username_valid = len(username) >= 5 and username.isalnum()
age_valid = 13 <= age <= 120
email_valid = "@" in email and "." in email
all_valid = username_valid and age_valid and email_valid and terms_accepted

print(f"Username valid: {username_valid}")
print(f"Age valid: {age_valid}")
print(f"Email valid: {email_valid}")
print(f"All conditions met: {all_valid}")

# Type checking in practice
data = [42, "Hello", 3.14, True, None]

for item in data:
    print(f"{item} is type: {type(item).__name__}")
    
    if isinstance(item, (int, float)):
        print(f"  -> It's a number!")
    elif isinstance(item, str):
        print(f"  -> It's text!")
    elif isinstance(item, bool):
        print(f"  -> It's a boolean!")
    else:
        print(f"  -> It's something else!")`,
    ],
    keyPoints: [
      "Booleans have two values: True or False",
      "Comparison operators (==, !=, >, <, >=, <=) return booleans",
      "Logical operators: and, or, not",
      "Empty values (0, '', [], None) are falsy",
      "Use type() to check type, isinstance() for type testing",
      "Booleans control program flow in conditions and loops",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// Module 2 Quiz
const quiz = {
  id: "python_fundamentals_m2_quiz",
  title: "Variables and Data Types Quiz",
  description: "Test your knowledge of Python variables and data types",
  courseId: "python_fundamentals",
  moduleId: "python_fundamentals_module_2",
  difficulty: "easy",
  category: "python_basics",
  timeLimit: 600,
  passingScore: 70,
  totalQuestions: 10,
  xpReward: 25,
  isActive: true,
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
};

// Module 2 Quiz Questions
const questions = [
  {
    id: "python_fundamentals_m2_q1",
    type: "mcq",
    question: "Which of the following is NOT a valid variable name in Python?",
    codeSnippet: null,
    options: ["my_var", "_private", "2ndVariable", "userName"],
    correctAnswer: "2ndVariable",
    explanation:
      "Variable names cannot start with a number in Python. They must start with a letter or underscore.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m2_q2",
    type: "code_output",
    question: "What will this code print?",
    codeSnippet: `x = 5
y = 2
result = x / y
print(type(result).__name__)`,
    options: ["int", "float", "number", "decimal"],
    correctAnswer: "float",
    explanation:
      "Division (/) always returns a float in Python, even when dividing two integers.",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m2_q3",
    type: "fill_code",
    question:
      "Complete the code to create an f-string that prints 'Hello, Alice!'",
    codeSnippet: `name = "Alice"
print(___"Hello, {name}!"___)`,
    options: ["f", "F", "format", "str"],
    correctAnswer: "f",
    explanation:
      "F-strings are created by putting 'f' before the opening quote. They allow variable interpolation with {}.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m2_q4",
    type: "boolean",
    question:
      "In Python, you can change the value and type of a variable after it's been created.",
    codeSnippet: null,
    options: ["True", "False"],
    correctAnswer: "True",
    explanation:
      "Python is dynamically typed, meaning variables can be reassigned to values of different types.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m2_q5",
    type: "mcq",
    question: "What is the result of: 17 % 5?",
    codeSnippet: null,
    options: ["3.4", "3", "2", "12"],
    correctAnswer: "2",
    explanation:
      "The modulo operator (%) returns the remainder of division. 17 divided by 5 is 3 with remainder 2.",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m2_q6",
    type: "debug",
    question: "Fix this code to properly convert a string to an integer:",
    codeSnippet: `age = "25"
age_next_year = age + 1`,
    options: [
      "int(age) + 1",
      "age.int() + 1",
      "integer(age) + 1",
      "age + str(1)",
    ],
    correctAnswer: "int(age) + 1",
    explanation:
      "You need to convert the string '25' to an integer using int() before performing mathematical operations.",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m2_q7",
    type: "code_output",
    question: "What will this code output?",
    codeSnippet: `text = "PYTHON"
print(text[1:4])`,
    options: ["PYT", "YTH", "PYTH", "YTHO"],
    correctAnswer: "YTH",
    explanation:
      "String slicing [1:4] starts at index 1 ('Y') and goes up to but not including index 4, giving us 'YTH'.",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m2_q8",
    type: "mcq",
    question: "Which of these values is considered 'falsy' in Python?",
    codeSnippet: null,
    options: ["'False'", "1", "[]", "'0'"],
    correctAnswer: "[]",
    explanation:
      "An empty list [] is falsy. The strings 'False' and '0' are truthy because they're non-empty strings.",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m2_q9",
    type: "boolean",
    question: "The expression 'Python' == 'python' evaluates to True.",
    codeSnippet: null,
    options: ["True", "False"],
    correctAnswer: "False",
    explanation:
      "String comparison is case-sensitive in Python. 'Python' and 'python' are different strings.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m2_q10",
    type: "fill_code",
    question: "Complete the code to check if a variable is an integer:",
    codeSnippet: `x = 42
if ___(x, int):
    print("x is an integer")`,
    options: ["isinstance", "typeof", "istype", "checktype"],
    correctAnswer: "isinstance",
    explanation:
      "isinstance() is the recommended way to check if a variable is of a specific type in Python.",
    difficulty: "medium",
    points: 1,
  },
];

async function addModule2Content() {
  console.log("🚀 Adding Module 2 content...\n");

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

    console.log("\n🎉 Module 2 content added successfully!");
    console.log("📝 Students can now complete Modules 1 and 2!");
    console.log(
      "🚀 Create more module files as needed (add_module_3_content.js, etc.)"
    );
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    process.exit(0);
  }
}

// Run the function
addModule2Content();
