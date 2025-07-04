// add_module_6_content.js
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

// Module 6 Lessons
const lessons = [
  {
    id: "python_fundamentals_m6_lesson_1",
    moduleId: "python_fundamentals_module_6",
    courseId: "python_fundamentals",
    title: "String Basics and Methods",
    content: `# String Basics and Methods

## String Creation

Strings are sequences of characters:

\`\`\`python
# Different ways to create strings
single = 'Hello, World!'
double = "Python Programming"
multi = """This is a
multi-line string"""

# String with quotes
quote = "She said, 'Hello!'"
another = 'It\\'s a beautiful day'
\`\`\`

## String Methods

Python provides many string methods:

\`\`\`python
text = "  Python Programming  "

# Case methods
print(text.upper())      # "  PYTHON PROGRAMMING  "
print(text.lower())      # "  python programming  "
print(text.title())      # "  Python Programming  "
print(text.capitalize()) # "  python programming  "

# Whitespace methods
print(text.strip())      # "Python Programming"
print(text.lstrip())     # "Python Programming  "
print(text.rstrip())     # "  Python Programming"
\`\`\`

## Finding and Replacing

\`\`\`python
message = "Hello, Python! Python is awesome!"

# Find methods
print(message.find("Python"))    # 7 (first occurrence)
print(message.rfind("Python"))   # 15 (last occurrence)
print(message.count("Python"))   # 2

# Replace
new_message = message.replace("Python", "ProCode")
print(new_message)  # "Hello, ProCode! ProCode is awesome!"
\`\`\`

## String Checks

\`\`\`python
# Check string properties
text1 = "Python123"
text2 = "12345"
text3 = "Hello World"

print(text1.isalnum())   # True (alphanumeric)
print(text2.isdigit())   # True (all digits)
print(text3.isalpha())   # False (has space)
print("  ".isspace())    # True (all whitespace)
\`\`\`

Strings are more powerful than you think! 💪`,
    videoUrl: "",
    orderIndex: 0,
    estimatedMinutes: 25,
    xpReward: 10,
    codeExamples: [
      `# Email validator
email = "  USER@EXAMPLE.COM  "

# Clean and standardize
cleaned_email = email.strip().lower()
print(f"Original: '{email}'")
print(f"Cleaned: '{cleaned_email}'")

# Validate
if "@" in cleaned_email and "." in cleaned_email:
    username = cleaned_email.split("@")[0]
    domain = cleaned_email.split("@")[1]
    print(f"Username: {username}")
    print(f"Domain: {domain}")
else:
    print("Invalid email!")`,
      `# Text analyzer
text = "Python is amazing. Python is powerful. I love Python!"

# Analysis
word_count = len(text.split())
char_count = len(text)
python_count = text.count("Python")

print(f"Text: {text}")
print(f"Words: {word_count}")
print(f"Characters: {char_count}")
print(f"'Python' appears: {python_count} times")

# Clean version
clean_text = text.replace(".", "").replace("!", "")
words = clean_text.split()
print(f"\\nUnique words: {len(set(words))}")`,
    ],
    keyPoints: [
      "Strings are immutable sequences of characters",
      "String methods return new strings, don't modify original",
      "Common methods: upper(), lower(), strip(), replace()",
      "Use find() and count() to search within strings",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m6_lesson_2",
    moduleId: "python_fundamentals_module_6",
    courseId: "python_fundamentals",
    title: "String Formatting and F-Strings",
    content: `# String Formatting and F-Strings

## Old Style Formatting

\`\`\`python
# % formatting (older style)
name = "Alice"
age = 25
message = "Hello, %s! You are %d years old." % (name, age)
print(message)
\`\`\`

## Format Method

\`\`\`python
# .format() method
template = "Hello, {}! You are {} years old."
message = template.format(name, age)

# With positional arguments
template2 = "{1} is {0} years old"
message2 = template2.format(age, name)

# With named arguments
template3 = "{name} scored {score}%"
message3 = template3.format(name="Bob", score=85)
\`\`\`

## F-Strings (Recommended!)

The modern, readable way:

\`\`\`python
# Basic f-strings
name = "Charlie"
score = 92.5
message = f"{name} scored {score}%"
print(message)

# Expressions in f-strings
width = 10
height = 5
print(f"Area: {width * height} square units")

# Formatting numbers
price = 19.99
quantity = 3
print(f"Total: \${price * quantity:.2f}")
\`\`\`

## Advanced F-String Formatting

\`\`\`python
# Alignment and padding
name = "Python"
print(f"{name:>10}")   # Right align
print(f"{name:<10}")   # Left align
print(f"{name:^10}")   # Center align
print(f"{name:*^10}")  # Center with fill

# Number formatting
number = 1234.5678
print(f"{number:.2f}")     # 2 decimal places
print(f"{number:,.2f}")    # With thousands separator
print(f"{number:e}")       # Scientific notation

# Percentage
rate = 0.175
print(f"Interest: {rate:.1%}")  # "Interest: 17.5%"
\`\`\`

F-strings make formatting effortless! 🎯`,
    videoUrl: "",
    orderIndex: 1,
    estimatedMinutes: 30,
    xpReward: 10,
    codeExamples: [
      `# Receipt generator
items = [
    ("Coffee", 3.50, 2),
    ("Sandwich", 8.99, 1),
    ("Cookie", 2.50, 3)
]

print("=" * 40)
print(f"{'ITEM':<20}{'QTY':>5}{'PRICE':>8}{'TOTAL':>8}")
print("=" * 40)

subtotal = 0
for item, price, qty in items:
    total = price * qty
    subtotal += total
    print(f"{item:<20}{qty:>5}\${price:>7.2f}\${total:>7.2f}")

tax = subtotal * 0.08
grand_total = subtotal + tax

print("-" * 40)
print(f"{'Subtotal:':<33}\${subtotal:>7.2f}")
print(f"{'Tax (8%):':<33}\${tax:>7.2f}")
print(f"{'Total:':<33}\${grand_total:>7.2f}")
print("=" * 40)`,
      `# Progress bar generator
def show_progress(current, total, width=30):
    percent = current / total
    filled = int(width * percent)
    bar = "█" * filled + "░" * (width - filled)
    
    print(f"\\rProgress: [{bar}] {percent:6.1%} ({current}/{total})", end="")

# Simulate progress
import time
total_items = 50

for i in range(total_items + 1):
    show_progress(i, total_items)
    time.sleep(0.1)  # Simulate work

print("\\nComplete!")`,
    ],
    keyPoints: [
      "F-strings (f'') are the modern way to format",
      "Put expressions inside {} in f-strings",
      "Use : for formatting specifications",
      "F-strings are faster and more readable",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m6_lesson_3",
    moduleId: "python_fundamentals_module_6",
    courseId: "python_fundamentals",
    title: "String Splitting and Joining",
    content: `# String Splitting and Joining

## Splitting Strings

Break strings into lists:

\`\`\`python
# Basic split
sentence = "Python is awesome and fun"
words = sentence.split()
print(words)  # ['Python', 'is', 'awesome', 'and', 'fun']

# Split with delimiter
data = "apple,banana,orange,grape"
fruits = data.split(",")
print(fruits)  # ['apple', 'banana', 'orange', 'grape']

# Split with limit
text = "one-two-three-four"
parts = text.split("-", 2)  # Split only twice
print(parts)  # ['one', 'two', 'three-four']
\`\`\`

## Joining Strings

Combine lists into strings:

\`\`\`python
# Basic join
words = ['Python', 'is', 'amazing']
sentence = ' '.join(words)
print(sentence)  # "Python is amazing"

# Different separators
items = ['apple', 'banana', 'orange']
print(', '.join(items))     # "apple, banana, orange"
print(' - '.join(items))    # "apple - banana - orange"
print('\\n'.join(items))     # Each on new line
\`\`\`

## Practical Examples

\`\`\`python
# Parse CSV data
csv_line = "John,Doe,30,Engineer"
fields = csv_line.split(",")
first_name, last_name, age, job = fields
print(f"{first_name} {last_name} ({age}) - {job}")

# Clean and rebuild
messy_text = "  Python    is     awesome  "
clean_words = messy_text.split()  # Splits on any whitespace
clean_text = " ".join(clean_words)
print(f"'{clean_text}'")  # 'Python is awesome'
\`\`\`

## Splitlines for Multi-line Strings

\`\`\`python
# Handle multi-line text
text = """Line 1
Line 2
Line 3"""

lines = text.splitlines()
for i, line in enumerate(lines, 1):
    print(f"{i}: {line}")

# Process configuration
config = """
name=MyApp
version=1.0
debug=true
"""

for line in config.strip().splitlines():
    if "=" in line:
        key, value = line.split("=")
        print(f"{key}: {value}")
\`\`\`

Master splitting and joining for text processing! 🔄`,
    videoUrl: "",
    orderIndex: 2,
    estimatedMinutes: 25,
    xpReward: 10,
    codeExamples: [
      `# URL parser
url = "https://www.example.com/products/item?id=123&color=blue"

# Split into components
protocol, rest = url.split("://")
domain_path = rest.split("?")[0]
params = rest.split("?")[1] if "?" in rest else ""

print(f"Protocol: {protocol}")
print(f"Domain/Path: {domain_path}")

# Parse parameters
if params:
    param_list = params.split("&")
    print("Parameters:")
    for param in param_list:
        key, value = param.split("=")
        print(f"  {key}: {value}")`,
      `# Log file analyzer
log_entries = """
2024-01-15 10:30:45 INFO User login successful
2024-01-15 10:31:02 ERROR Failed to connect to database
2024-01-15 10:31:15 INFO Retrying connection
2024-01-15 10:31:18 INFO Connection established
"""

# Process log entries
entries = log_entries.strip().splitlines()
error_count = 0
info_count = 0

for entry in entries:
    parts = entry.split()
    if len(parts) >= 4:
        date = parts[0]
        time = parts[1]
        level = parts[2]
        message = " ".join(parts[3:])
        
        if level == "ERROR":
            error_count += 1
            print(f"❌ {time}: {message}")
        elif level == "INFO":
            info_count += 1

print(f"\\nSummary: {info_count} INFO, {error_count} ERROR")`,
    ],
    keyPoints: [
      "split() breaks strings into lists",
      "join() combines lists into strings",
      "Split without arguments splits on any whitespace",
      "splitlines() is perfect for multi-line text",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// Module 6 Quiz
const quiz = {
  id: "python_fundamentals_m6_quiz",
  title: "String Manipulation Mastery",
  description: "Test your knowledge of string methods and formatting",
  courseId: "python_fundamentals",
  moduleId: "python_fundamentals_module_6",
  difficulty: "medium",
  category: "python_basics",
  timeLimit: 600,
  passingScore: 70,
  totalQuestions: 10,
  xpReward: 35,
  isActive: true,
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
};

// Module 6 Quiz Questions
const questions = [
  {
    id: "python_fundamentals_m6_q1",
    type: "code_output",
    question: "What will this code output?",
    codeSnippet: `text = "Python"
print(text.upper())`,
    options: ["python", "PYTHON", "Python", "pYTHON"],
    correctAnswer: "PYTHON",
    explanation: "The upper() method converts all characters to uppercase.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m6_q2",
    type: "fill_code",
    question: "Complete the code to remove whitespace from both ends:",
    codeSnippet: `text = "  Hello  "
clean = text.___()`,
    options: ["strip", "trim", "clean", "remove"],
    correctAnswer: "strip",
    explanation:
      "The strip() method removes whitespace from both ends of a string.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m6_q3",
    type: "code_output",
    question: "What will this f-string print?",
    codeSnippet: `name = "Alice"
age = 30
print(f"{name} is {age} years old")`,
    options: [
      "Alice is 30 years old",
      "{name} is {age} years old",
      "name is age years old",
      "Error",
    ],
    correctAnswer: "Alice is 30 years old",
    explanation:
      "F-strings evaluate expressions inside {} and replace them with values.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m6_q4",
    type: "mcq",
    question: "Which method splits a string into a list?",
    codeSnippet: null,
    options: ["split()", "join()", "break()", "divide()"],
    correctAnswer: "split()",
    explanation:
      "The split() method breaks a string into a list of substrings.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m6_q5",
    type: "code_output",
    question: "How many times does 'a' appear?",
    codeSnippet: `text = "banana"
count = text.count("a")
print(count)`,
    options: ["1", "2", "3", "0"],
    correctAnswer: "3",
    explanation:
      "The count() method returns the number of occurrences. 'banana' has 3 'a's.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m6_q6",
    type: "debug",
    question: "Fix the f-string syntax:",
    codeSnippet: `price = 19.99
print(f"Price: {price.2f}")`,
    options: [
      `f"Price: {price:.2f}"`,
      `f"Price: {price:2f}"`,
      `f"Price: {price}.2f"`,
      `f"Price: {price[.2f]}"`,
    ],
    correctAnswer: `f"Price: {price:.2f}"`,
    explanation:
      "Format specifications in f-strings use a colon: {value:format}",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m6_q7",
    type: "code_output",
    question: "What list will this create?",
    codeSnippet: `data = "apple,banana,orange"
fruits = data.split(",")
print(len(fruits))`,
    options: ["1", "2", "3", "4"],
    correctAnswer: "3",
    explanation:
      "split(',') creates a list with 3 elements: ['apple', 'banana', 'orange']",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m6_q8",
    type: "boolean",
    question: "Strings in Python are mutable (can be changed).",
    codeSnippet: null,
    options: ["True", "False"],
    correctAnswer: "False",
    explanation:
      "Strings are immutable in Python. String methods return new strings.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m6_q9",
    type: "code_output",
    question: "What will this join operation produce?",
    codeSnippet: `words = ["Hello", "World"]
result = "-".join(words)
print(result)`,
    options: ["Hello-World", "Hello World", "HelloWorld", "['Hello', 'World']"],
    correctAnswer: "Hello-World",
    explanation:
      "join() combines list elements with the specified separator between them.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m6_q10",
    type: "mcq",
    question:
      "Which method would you use to check if a string contains only digits?",
    codeSnippet: null,
    options: ["isdigit()", "isnumeric()", "isint()", "checkdigit()"],
    correctAnswer: "isdigit()",
    explanation:
      "The isdigit() method returns True if all characters in the string are digits.",
    difficulty: "medium",
    points: 1,
  },
];

async function addModule6Content() {
  console.log("🚀 Adding Module 6 content...\n");

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

    console.log("\n🎉 Module 6 content added successfully!");
    console.log("📝 Next: Run add_module_7_content.js");
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    process.exit(0);
  }
}

// Run the function
addModule6Content();
