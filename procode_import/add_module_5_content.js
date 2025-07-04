// add_module_5_content.js
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

// Module 5 Lessons
const lessons = [
  {
    id: "python_fundamentals_m5_lesson_1",
    moduleId: "python_fundamentals_module_5",
    courseId: "python_fundamentals",
    title: "Lists - Your First Data Structure",
    content: `# Lists - Your First Data Structure

## What are Lists?

Lists are **ordered collections** that can store multiple items:
- Numbers, strings, or mixed types
- Can be modified (mutable)
- Use square brackets []

\`\`\`python
# Creating lists
fruits = ["apple", "banana", "orange"]
numbers = [1, 2, 3, 4, 5]
mixed = ["hello", 42, True, 3.14]
empty_list = []
\`\`\`

## Accessing List Items

Use **index** positions (starting at 0):

\`\`\`python
fruits = ["apple", "banana", "orange"]

print(fruits[0])   # First item: "apple"
print(fruits[1])   # Second item: "banana"
print(fruits[-1])  # Last item: "orange"
\`\`\`

## Modifying Lists

Lists are mutable - you can change them:

\`\`\`python
# Change an item
fruits[0] = "mango"

# Add items
fruits.append("grape")      # Add to end
fruits.insert(1, "kiwi")   # Insert at position

# Remove items
fruits.remove("banana")     # Remove by value
popped = fruits.pop()      # Remove and return last
\`\`\`

## List Operations

\`\`\`python
numbers = [3, 1, 4, 1, 5]

# Common operations
print(len(numbers))      # Length: 5
print(sum(numbers))      # Sum: 14
print(max(numbers))      # Maximum: 5
print(min(numbers))      # Minimum: 1
print(numbers.count(1))  # Count of 1s: 2
\`\`\`

Lists are Python's Swiss Army knife! 🔪`,
    videoUrl: "",
    orderIndex: 0,
    estimatedMinutes: 25,
    xpReward: 10,
    codeExamples: [
      `# Shopping list manager
shopping_list = ["milk", "eggs", "bread"]
print("Initial list:", shopping_list)

# Add items
shopping_list.append("cheese")
shopping_list.insert(0, "coffee")
print("After adding:", shopping_list)

# Remove items
shopping_list.remove("eggs")
print("After removing eggs:", shopping_list)

# Check if item exists
if "milk" in shopping_list:
    print("Don't forget the milk!")

# List length
print(f"Total items: {len(shopping_list)}")`,
      `# Grade tracker
grades = [85, 92, 78, 95, 88]

# Calculate statistics
average = sum(grades) / len(grades)
highest = max(grades)
lowest = min(grades)

print(f"Grades: {grades}")
print(f"Average: {average:.1f}")
print(f"Highest: {highest}")
print(f"Lowest: {lowest}")

# Add new grade
grades.append(91)
print(f"Updated grades: {grades}")`,
    ],
    keyPoints: [
      "Lists store ordered collections of items",
      "Access items using index (starting at 0)",
      "Lists are mutable - can be modified",
      "Common methods: append(), insert(), remove(), pop()",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m5_lesson_2",
    moduleId: "python_fundamentals_module_5",
    courseId: "python_fundamentals",
    title: "List Methods and Slicing",
    content: `# List Methods and Slicing

## More List Methods

\`\`\`python
numbers = [3, 1, 4, 1, 5, 9]

# Sorting
numbers.sort()           # Sort in place
print(numbers)          # [1, 1, 3, 4, 5, 9]

numbers.reverse()       # Reverse order
print(numbers)          # [9, 5, 4, 3, 1, 1]

# Finding items
index = numbers.index(4)  # Find position of 4
print(f"4 is at index: {index}")
\`\`\`

## List Slicing

Extract parts of lists:

\`\`\`python
fruits = ["apple", "banana", "orange", "grape", "kiwi"]

# Slicing syntax: list[start:end:step]
print(fruits[1:4])    # ["banana", "orange", "grape"]
print(fruits[:3])     # First 3: ["apple", "banana", "orange"]
print(fruits[2:])     # From index 2: ["orange", "grape", "kiwi"]
print(fruits[::2])    # Every 2nd: ["apple", "orange", "kiwi"]
print(fruits[::-1])   # Reversed: ["kiwi", "grape", "orange", "banana", "apple"]
\`\`\`

## List Comprehensions

Create lists efficiently:

\`\`\`python
# Traditional way
squares = []
for x in range(5):
    squares.append(x ** 2)

# List comprehension
squares = [x ** 2 for x in range(5)]
print(squares)  # [0, 1, 4, 9, 16]

# With conditions
evens = [x for x in range(10) if x % 2 == 0]
print(evens)  # [0, 2, 4, 6, 8]
\`\`\`

## Copying Lists

\`\`\`python
original = [1, 2, 3]

# Wrong way (creates reference)
copy1 = original
copy1[0] = 99
print(original)  # [99, 2, 3] - Original changed!

# Right ways
copy2 = original.copy()
copy3 = original[:]
copy4 = list(original)
\`\`\`

Master lists for powerful programming! 💪`,
    videoUrl: "",
    orderIndex: 1,
    estimatedMinutes: 30,
    xpReward: 10,
    codeExamples: [
      `# Task manager with slicing
tasks = ["Email boss", "Finish report", "Team meeting", "Lunch break", "Code review", "Update docs"]

print("All tasks:", tasks)
print("Morning tasks:", tasks[:3])
print("Afternoon tasks:", tasks[3:])

# Mark completed (remove first 2)
completed = tasks[:2]
remaining = tasks[2:]
print(f"\\nCompleted: {completed}")
print(f"Remaining: {remaining}")

# Reverse priority
remaining.reverse()
print(f"Reversed priority: {remaining}")`,
      `# Temperature converter with list comprehension
celsius_temps = [0, 20, 30, 100]

# Convert to Fahrenheit
fahrenheit = [(c * 9/5) + 32 for c in celsius_temps]

print("Celsius:    ", celsius_temps)
print("Fahrenheit: ", fahrenheit)

# Filter hot days (> 25°C)
hot_days = [temp for temp in celsius_temps if temp > 25]
print(f"\\nHot days (>25°C): {hot_days}")

# Create labels
temp_labels = [f"{c}°C = {f}°F" for c, f in zip(celsius_temps, fahrenheit)]
for label in temp_labels:
    print(label)`,
    ],
    keyPoints: [
      "sort() and reverse() modify lists in place",
      "Slicing extracts sublists: list[start:end:step]",
      "List comprehensions create lists concisely",
      "Always copy lists properly to avoid references",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m5_lesson_3",
    moduleId: "python_fundamentals_module_5",
    courseId: "python_fundamentals",
    title: "Tuples and Sets",
    content: `# Tuples and Sets

## Tuples - Immutable Lists

Tuples are like lists but **cannot be changed**:

\`\`\`python
# Creating tuples
coordinates = (3, 5)
rgb_color = (255, 128, 0)
single_item = (42,)  # Note the comma!

# Accessing items (like lists)
print(coordinates[0])  # 3
print(coordinates[1])  # 5

# Unpacking
x, y = coordinates
print(f"X: {x}, Y: {y}")
\`\`\`

## Why Use Tuples?

\`\`\`python
# Tuples are immutable (can't change)
# coordinates[0] = 10  # Error!

# Use for data that shouldn't change
month_days = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
dimensions = (1920, 1080)  # Screen resolution

# Functions can return tuples
def get_user_info():
    return ("Alice", 25, "alice@email.com")

name, age, email = get_user_info()
\`\`\`

## Sets - Unique Collections

Sets store **unique values** with no duplicates:

\`\`\`python
# Creating sets
fruits = {"apple", "banana", "orange"}
numbers = {1, 2, 3, 3, 3}  # Duplicates removed
print(numbers)  # {1, 2, 3}

# Set from list (removes duplicates)
scores = [10, 20, 10, 30, 20, 40]
unique_scores = set(scores)
print(unique_scores)  # {10, 20, 30, 40}
\`\`\`

## Set Operations

\`\`\`python
# Set methods
colors = {"red", "blue", "green"}
colors.add("yellow")      # Add item
colors.remove("blue")     # Remove item
colors.discard("purple")  # Remove if exists

# Set math
set1 = {1, 2, 3, 4}
set2 = {3, 4, 5, 6}

print(set1 | set2)  # Union: {1, 2, 3, 4, 5, 6}
print(set1 & set2)  # Intersection: {3, 4}
print(set1 - set2)  # Difference: {1, 2}
\`\`\`

Choose the right tool for the job! 🛠️`,
    videoUrl: "",
    orderIndex: 2,
    estimatedMinutes: 35,
    xpReward: 10,
    codeExamples: [
      `# Student records with tuples
students = [
    ("Alice", 85, "A"),
    ("Bob", 72, "B"),
    ("Charlie", 91, "A"),
    ("Diana", 68, "C")
]

# Process records
for name, score, grade in students:
    print(f"{name}: {score}% (Grade {grade})")

# Find top scorer
top_student = max(students, key=lambda x: x[1])
print(f"\\nTop student: {top_student[0]} with {top_student[1]}%")`,
      `# Track unique visitors
visitors_monday = {"Alice", "Bob", "Charlie", "Diana"}
visitors_tuesday = {"Bob", "Charlie", "Eve", "Frank"}

# All unique visitors
all_visitors = visitors_monday | visitors_tuesday
print(f"Total unique visitors: {len(all_visitors)}")
print(f"Visitors: {all_visitors}")

# Both days visitors
both_days = visitors_monday & visitors_tuesday
print(f"\\nVisited both days: {both_days}")

# Only Monday visitors
monday_only = visitors_monday - visitors_tuesday
print(f"Monday only: {monday_only}")

# Check membership
if "Alice" in all_visitors:
    print("\\nAlice visited this week!")`,
    ],
    keyPoints: [
      "Tuples are immutable (unchangeable) sequences",
      "Use tuples for data that shouldn't change",
      "Sets contain only unique values",
      "Sets support mathematical operations",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m5_lesson_4",
    moduleId: "python_fundamentals_module_5",
    courseId: "python_fundamentals",
    title: "Dictionaries - Key-Value Storage",
    content: `# Dictionaries - Key-Value Storage

## What are Dictionaries?

Dictionaries store data in **key-value pairs**:

\`\`\`python
# Creating dictionaries
student = {
    "name": "Alice",
    "age": 20,
    "grade": "A",
    "subjects": ["Math", "Science"]
}

# Empty dictionary
empty_dict = {}
also_empty = dict()
\`\`\`

## Accessing Dictionary Data

\`\`\`python
# Get values by key
print(student["name"])     # "Alice"
print(student["age"])      # 20

# Safer with get()
print(student.get("grade"))       # "A"
print(student.get("gpa", 0.0))   # 0.0 (default)

# Check if key exists
if "name" in student:
    print(f"Student: {student['name']}")
\`\`\`

## Modifying Dictionaries

\`\`\`python
# Change values
student["age"] = 21
student["gpa"] = 3.8

# Add new keys
student["email"] = "alice@school.edu"

# Remove items
del student["subjects"]
removed = student.pop("grade", None)
\`\`\`

## Dictionary Methods

\`\`\`python
# Useful methods
print(student.keys())    # All keys
print(student.values())  # All values
print(student.items())   # Key-value pairs

# Iterate through dictionary
for key, value in student.items():
    print(f"{key}: {value}")

# Update multiple values
student.update({"age": 22, "year": 3})
\`\`\`

## Nested Dictionaries

\`\`\`python
# Complex data structures
classroom = {
    "teacher": "Mr. Smith",
    "room": "101A",
    "students": {
        "alice": {"grade": 90, "attendance": 95},
        "bob": {"grade": 85, "attendance": 88}
    }
}

# Access nested data
alice_grade = classroom["students"]["alice"]["grade"]
print(f"Alice's grade: {alice_grade}")
\`\`\`

Dictionaries organize data perfectly! 📚`,
    videoUrl: "",
    orderIndex: 3,
    estimatedMinutes: 40,
    xpReward: 10,
    codeExamples: [
      `# Contact book
contacts = {
    "Alice": {"phone": "123-456-7890", "email": "alice@email.com"},
    "Bob": {"phone": "098-765-4321", "email": "bob@email.com"},
    "Charlie": {"phone": "555-555-5555", "email": "charlie@email.com"}
}

# Add new contact
contacts["Diana"] = {
    "phone": "111-222-3333",
    "email": "diana@email.com"
}

# Search contact
name = "Bob"
if name in contacts:
    info = contacts[name]
    print(f"{name}'s Contact Info:")
    print(f"  Phone: {info['phone']}")
    print(f"  Email: {info['email']}")

# List all contacts
print("\\nAll Contacts:")
for name, info in contacts.items():
    print(f"- {name}: {info['phone']}")`,
      `# Inventory system
inventory = {
    "apple": {"price": 0.50, "quantity": 100},
    "banana": {"price": 0.30, "quantity": 150},
    "orange": {"price": 0.60, "quantity": 80}
}

# Calculate total value
total_value = 0
for item, details in inventory.items():
    value = details["price"] * details["quantity"]
    total_value += value
    print(f"{item.capitalize()}: \${value:.2f}")

print(f"\\nTotal inventory value: \${total_value:.2f}")

# Update quantity
item_sold = "apple"
quantity_sold = 5
inventory[item_sold]["quantity"] -= quantity_sold
print(f"\\nSold {quantity_sold} {item_sold}s")
print(f"Remaining: {inventory[item_sold]['quantity']}")`,
    ],
    keyPoints: [
      "Dictionaries store key-value pairs",
      "Access values using keys in square brackets",
      "Use get() for safe access with defaults",
      "Dictionaries can be nested for complex data",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// Module 5 Quiz
const quiz = {
  id: "python_fundamentals_m5_quiz",
  title: "Data Structures Challenge",
  description: "Test your knowledge of lists, tuples, sets, and dictionaries",
  courseId: "python_fundamentals",
  moduleId: "python_fundamentals_module_5",
  difficulty: "medium",
  category: "python_basics",
  timeLimit: 600,
  passingScore: 70,
  totalQuestions: 10,
  xpReward: 40,
  isActive: true,
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
};

// Module 5 Quiz Questions
const questions = [
  {
    id: "python_fundamentals_m5_q1",
    type: "code_output",
    question: "What will this code print?",
    codeSnippet: `fruits = ["apple", "banana", "orange"]
print(fruits[1])`,
    options: ["apple", "banana", "orange", "1"],
    correctAnswer: "banana",
    explanation:
      "List indexing starts at 0, so fruits[1] accesses the second element, which is 'banana'.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m5_q2",
    type: "mcq",
    question: "Which data structure would you use to store unique values only?",
    codeSnippet: null,
    options: ["List", "Tuple", "Set", "Dictionary"],
    correctAnswer: "Set",
    explanation:
      "Sets automatically remove duplicates and only store unique values.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m5_q3",
    type: "fill_code",
    question: "Complete the code to add 'grape' to the end of the list:",
    codeSnippet: `fruits = ["apple", "banana"]
fruits.___("grape")`,
    options: ["append", "add", "insert", "push"],
    correctAnswer: "append",
    explanation: "The append() method adds an item to the end of a list.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m5_q4",
    type: "boolean",
    question: "Tuples can be modified after creation.",
    codeSnippet: null,
    options: ["True", "False"],
    correctAnswer: "False",
    explanation:
      "Tuples are immutable, meaning they cannot be changed after creation. Lists are mutable.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m5_q5",
    type: "code_output",
    question: "What will this slicing operation return?",
    codeSnippet: `numbers = [0, 1, 2, 3, 4, 5]
print(numbers[2:5])`,
    options: ["[2, 3, 4]", "[2, 3, 4, 5]", "[1, 2, 3, 4]", "[3, 4, 5]"],
    correctAnswer: "[2, 3, 4]",
    explanation:
      "Slicing [2:5] returns elements from index 2 up to (but not including) index 5.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m5_q6",
    type: "mcq",
    question:
      "How do you access the value associated with key 'name' in a dictionary?",
    codeSnippet: `person = {"name": "Alice", "age": 25}`,
    options: [`person.name`, `person["name"]`, `person[0]`, `person{"name"}`],
    correctAnswer: `person["name"]`,
    explanation:
      "Dictionary values are accessed using square brackets with the key: dict[key].",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m5_q7",
    type: "debug",
    question: "Fix the error in creating this set:",
    codeSnippet: `unique_numbers = {1, 2, 3, 3, 4}
unique_numbers.append(5)`,
    options: [
      "unique_numbers.add(5)",
      "unique_numbers.push(5)",
      "unique_numbers[5] = 5",
      "unique_numbers + 5",
    ],
    correctAnswer: "unique_numbers.add(5)",
    explanation:
      "Sets use the add() method, not append(). append() is for lists.",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m5_q8",
    type: "code_output",
    question: "What is the length of this list after these operations?",
    codeSnippet: `items = [1, 2, 3]
items.append(4)
items.remove(2)
print(len(items))`,
    options: ["2", "3", "4", "5"],
    correctAnswer: "3",
    explanation:
      "Starting with 3 items, append adds 1 (total 4), remove deletes 1 (total 3).",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m5_q9",
    type: "mcq",
    question: "Which method returns and removes the last item from a list?",
    codeSnippet: null,
    options: ["remove()", "pop()", "delete()", "last()"],
    correctAnswer: "pop()",
    explanation:
      "The pop() method removes and returns the last item from a list (or item at specified index).",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m5_q10",
    type: "code_output",
    question: "What will this list comprehension create?",
    codeSnippet: `squares = [x**2 for x in range(4)]
print(squares)`,
    options: ["[0, 1, 2, 3]", "[1, 4, 9, 16]", "[0, 1, 4, 9]", "[2, 4, 6, 8]"],
    correctAnswer: "[0, 1, 4, 9]",
    explanation: "This creates a list of squares: 0²=0, 1²=1, 2²=4, 3²=9.",
    difficulty: "medium",
    points: 1,
  },
];
async function addModule5Content() {
  console.log("🚀 Adding Module 5 content...\n");

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

    console.log("\n🎉 Module 5 content added successfully!");
    console.log("📝 Next: Run add_module_6_content.js");
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    process.exit(0);
  }
}

// Run the function
addModule5Content();
