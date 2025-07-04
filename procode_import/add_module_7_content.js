// add_module_7_content.js
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

// Module 7 Lessons
const lessons = [
  {
    id: "python_fundamentals_m7_lesson_1",
    moduleId: "python_fundamentals_module_7",
    courseId: "python_fundamentals",
    title: "Reading Files in Python",
    content: `# Reading Files in Python

## Opening Files

Work with external data:

\`\`\`python
# Basic file opening
file = open("data.txt", "r")  # "r" for read mode
content = file.read()
file.close()  # Important: always close!

# Better way - using 'with'
with open("data.txt", "r") as file:
    content = file.read()
    # File automatically closes when done
\`\`\`

## File Modes

\`\`\`python
# Common file modes
# "r"  - Read (default)
# "w"  - Write (overwrites existing)
# "a"  - Append
# "r+" - Read and write
# "b"  - Binary mode (e.g., "rb", "wb")
\`\`\`

## Reading Methods

\`\`\`python
# Read entire file
with open("story.txt", "r") as file:
    full_content = file.read()
    print(full_content)

# Read line by line
with open("data.txt", "r") as file:
    first_line = file.readline()
    second_line = file.readline()
    
# Read all lines into list
with open("data.txt", "r") as file:
    all_lines = file.readlines()
    for line in all_lines:
        print(line.strip())  # Remove newline
\`\`\`

## Efficient Line Processing

\`\`\`python
# Best way for large files
with open("large_file.txt", "r") as file:
    for line in file:
        # Process one line at a time
        # Memory efficient!
        print(line.strip())

# Count lines
with open("data.txt", "r") as file:
    line_count = sum(1 for line in file)
    print(f"Total lines: {line_count}")
\`\`\`

Files unlock data possibilities! 📁`,
    videoUrl: "",
    orderIndex: 0,
    estimatedMinutes: 25,
    xpReward: 10,
    codeExamples: [
      `# Read and analyze a text file
filename = "sample.txt"

try:
    with open(filename, "r") as file:
        content = file.read()
        
        # Basic statistics
        lines = content.splitlines()
        words = content.split()
        chars = len(content)
        
        print(f"File: {filename}")
        print(f"Lines: {len(lines)}")
        print(f"Words: {len(words)}")
        print(f"Characters: {chars}")
        
        # Show first 3 lines
        print("\\nFirst 3 lines:")
        for i, line in enumerate(lines[:3], 1):
            print(f"{i}: {line}")
            
except FileNotFoundError:
    print(f"Error: {filename} not found!")`,
      `# Process CSV data
with open("students.csv", "r") as file:
    # Skip header
    header = file.readline().strip()
    print(f"Columns: {header}")
    print("-" * 40)
    
    # Process each student
    total_score = 0
    student_count = 0
    
    for line in file:
        # Parse CSV line
        parts = line.strip().split(",")
        if len(parts) >= 3:
            name = parts[0]
            age = parts[1]
            score = float(parts[2])
            
            total_score += score
            student_count += 1
            
            print(f"{name} ({age}): {score}%")
    
    # Calculate average
    if student_count > 0:
        average = total_score / student_count
        print(f"\\nClass average: {average:.1f}%")`,
    ],
    keyPoints: [
      "Always use 'with' statement for file handling",
      "Files automatically close with 'with' statement",
      "read() gets entire content, readline() gets one line",
      "Iterate directly over file object for efficiency",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m7_lesson_2",
    moduleId: "python_fundamentals_module_7",
    courseId: "python_fundamentals",
    title: "Writing to Files",
    content: `# Writing to Files

## Writing Text Files

Create and modify files:

\`\`\`python
# Write mode (overwrites existing file!)
with open("output.txt", "w") as file:
    file.write("Hello, File World!\\n")
    file.write("This is line 2\\n")

# Append mode (adds to existing file)
with open("output.txt", "a") as file:
    file.write("This line is appended\\n")
\`\`\`

## Writing Multiple Lines

\`\`\`python
# Write a list of lines
lines = [
    "First line\\n",
    "Second line\\n", 
    "Third line\\n"
]

with open("multi.txt", "w") as file:
    file.writelines(lines)

# Better formatting
data = ["Apple", "Banana", "Orange"]
with open("fruits.txt", "w") as file:
    for fruit in data:
        file.write(f"{fruit}\\n")
\`\`\`

## Creating Reports

\`\`\`python
# Generate a formatted report
students = [
    ("Alice", 92),
    ("Bob", 85),
    ("Charlie", 78)
]

with open("report.txt", "w") as file:
    file.write("Student Grade Report\\n")
    file.write("=" * 30 + "\\n")
    
    for name, grade in students:
        file.write(f"{name:<15} {grade:>3}%\\n")
    
    file.write("=" * 30 + "\\n")
    average = sum(g for _, g in students) / len(students)
    file.write(f"Class Average: {average:.1f}%\\n")
\`\`\`

## Safe File Writing

\`\`\`python
import os

filename = "important_data.txt"

# Check if file exists
if os.path.exists(filename):
    response = input(f"{filename} exists. Overwrite? (y/n): ")
    if response.lower() != 'y':
        print("Write cancelled.")
    else:
        with open(filename, "w") as file:
            file.write("New data")
else:
    with open(filename, "w") as file:
        file.write("New file created")
\`\`\`

Create files to save your data! 💾`,
    videoUrl: "",
    orderIndex: 1,
    estimatedMinutes: 30,
    xpReward: 10,
    codeExamples: [
      `# Todo list manager
def save_todos(todos, filename="todos.txt"):
    """Save todo items to file"""
    with open(filename, "w") as file:
        file.write("MY TODO LIST\\n")
        file.write("=" * 30 + "\\n")
        
        for i, todo in enumerate(todos, 1):
            status = "✓" if todo["done"] else "○"
            file.write(f"{i}. [{status}] {todo['task']}\\n")
        
        file.write("\\n" + "=" * 30 + "\\n")
        completed = sum(1 for t in todos if t["done"])
        file.write(f"Completed: {completed}/{len(todos)}\\n")

# Example usage
my_todos = [
    {"task": "Learn Python", "done": True},
    {"task": "Practice file handling", "done": True},
    {"task": "Build a project", "done": False}
]

save_todos(my_todos)
print("Todo list saved!")`,
      `# Log file writer
from datetime import datetime

def write_log(message, level="INFO", filename="app.log"):
    """Write timestamped log entry"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    with open(filename, "a") as file:
        file.write(f"[{timestamp}] {level}: {message}\\n")

# Simulate application logging
write_log("Application started")
write_log("User logged in", "INFO")
write_log("Failed login attempt", "WARNING")
write_log("Database connection lost", "ERROR")

print("Check app.log for entries!")

# Read and display log
print("\\nRecent log entries:")
with open("app.log", "r") as file:
    lines = file.readlines()
    for line in lines[-5:]:  # Last 5 entries
        print(line.strip())`,
    ],
    keyPoints: [
      "Mode 'w' overwrites, 'a' appends to files",
      "write() for single string, writelines() for list",
      "Always include newlines (\\n) when needed",
      "Check file existence before overwriting",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m7_lesson_3",
    moduleId: "python_fundamentals_module_7",
    courseId: "python_fundamentals",
    title: "Working with CSV and JSON Files",
    content: `# Working with CSV and JSON Files

## CSV Files

Comma-Separated Values for tabular data:

\`\`\`python
import csv

# Reading CSV
with open("data.csv", "r") as file:
    csv_reader = csv.reader(file)
    
    # Skip header
    header = next(csv_reader)
    print(f"Columns: {header}")
    
    # Read rows
    for row in csv_reader:
        print(row)  # List of values

# Writing CSV
data = [
    ["Name", "Age", "City"],
    ["Alice", 25, "New York"],
    ["Bob", 30, "London"]
]

with open("output.csv", "w", newline="") as file:
    csv_writer = csv.writer(file)
    csv_writer.writerows(data)
\`\`\`

## CSV DictReader/DictWriter

Work with dictionaries:

\`\`\`python
# Read as dictionaries
with open("data.csv", "r") as file:
    csv_reader = csv.DictReader(file)
    for row in csv_reader:
        print(f"{row['Name']} is {row['Age']} years old")

# Write from dictionaries
people = [
    {"name": "Charlie", "age": 35, "job": "Engineer"},
    {"name": "Diana", "age": 28, "job": "Designer"}
]

with open("people.csv", "w", newline="") as file:
    fieldnames = ["name", "age", "job"]
    writer = csv.DictWriter(file, fieldnames=fieldnames)
    
    writer.writeheader()
    writer.writerows(people)
\`\`\`

## JSON Files

JavaScript Object Notation for structured data:

\`\`\`python
import json

# Reading JSON
with open("data.json", "r") as file:
    data = json.load(file)
    print(data)

# Writing JSON
person = {
    "name": "Eve",
    "age": 32,
    "skills": ["Python", "JavaScript", "SQL"],
    "active": True
}

with open("person.json", "w") as file:
    json.dump(person, file, indent=4)

# JSON string conversion
json_string = json.dumps(person)
parsed = json.loads(json_string)
\`\`\`

Master data formats for real applications! 📊`,
    videoUrl: "",
    orderIndex: 2,
    estimatedMinutes: 35,
    xpReward: 10,
    codeExamples: [
      `# Student grade manager with CSV
import csv

def save_grades(students, filename="grades.csv"):
    """Save student grades to CSV"""
    with open(filename, "w", newline="") as file:
        fieldnames = ["name", "math", "science", "english", "average"]
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        
        writer.writeheader()
        
        for student in students:
            # Calculate average
            grades = [student["math"], student["science"], student["english"]]
            student["average"] = round(sum(grades) / len(grades), 1)
            writer.writerow(student)

def load_grades(filename="grades.csv"):
    """Load grades from CSV"""
    students = []
    try:
        with open(filename, "r") as file:
            reader = csv.DictReader(file)
            for row in reader:
                # Convert grades to numbers
                row["math"] = float(row["math"])
                row["science"] = float(row["science"])
                row["english"] = float(row["english"])
                row["average"] = float(row["average"])
                students.append(row)
    except FileNotFoundError:
        print(f"{filename} not found")
    
    return students

# Example usage
student_data = [
    {"name": "Alice", "math": 92, "science": 88, "english": 95},
    {"name": "Bob", "math": 78, "science": 85, "english": 82},
    {"name": "Charlie", "math": 95, "science": 92, "english": 88}
]

save_grades(student_data)
loaded = load_grades()

print("Student Grades:")
for s in loaded:
    print(f"{s['name']}: Average = {s['average']}%")`,
      `# Configuration manager with JSON
import json
import os

class ConfigManager:
    def __init__(self, filename="config.json"):
        self.filename = filename
        self.config = self.load_config()
    
    def load_config(self):
        """Load configuration from JSON file"""
        if os.path.exists(self.filename):
            with open(self.filename, "r") as file:
                return json.load(file)
        else:
            # Default configuration
            return {
                "app_name": "My Python App",
                "version": "1.0.0",
                "settings": {
                    "theme": "dark",
                    "language": "en",
                    "auto_save": True
                },
                "last_opened": []
            }
    
    def save_config(self):
        """Save configuration to JSON file"""
        with open(self.filename, "w") as file:
            json.dump(self.config, file, indent=4)
    
    def get(self, key, default=None):
        """Get configuration value"""
        return self.config.get(key, default)
    
    def set(self, key, value):
        """Set configuration value"""
        self.config[key] = value
        self.save_config()

# Usage example
config = ConfigManager()

print(f"App: {config.get('app_name')}")
print(f"Theme: {config.config['settings']['theme']}")

# Update settings
config.config['settings']['theme'] = 'light'
config.save_config()

print("\\nConfiguration updated!")`,
    ],
    keyPoints: [
      "CSV is great for tabular data (rows and columns)",
      "JSON handles complex nested data structures",
      "Use csv module for CSV, json module for JSON",
      "Always handle FileNotFoundError when reading",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// Module 7 Quiz
const quiz = {
  id: "python_fundamentals_m7_quiz",
  title: "File Handling Expertise",
  description: "Test your knowledge of reading, writing, and processing files",
  courseId: "python_fundamentals",
  moduleId: "python_fundamentals_module_7",
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

// Module 7 Quiz Questions
const questions = [
  {
    id: "python_fundamentals_m7_q1",
    type: "fill_code",
    question: "Complete the code to open a file for reading:",
    codeSnippet: `with ___("data.txt", "r") as file:
    content = file.read()`,
    options: ["open", "file", "read", "load"],
    correctAnswer: "open",
    explanation: "The open() function is used to open files in Python.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m7_q2",
    type: "mcq",
    question: "Which mode would you use to add content to an existing file?",
    codeSnippet: null,
    options: ["r", "w", "a", "x"],
    correctAnswer: "a",
    explanation:
      "Mode 'a' stands for append and adds content to the end of an existing file.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m7_q3",
    type: "boolean",
    question: "The 'with' statement automatically closes the file when done.",
    codeSnippet: null,
    options: ["True", "False"],
    correctAnswer: "True",
    explanation:
      "The 'with' statement ensures the file is properly closed even if an error occurs.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m7_q4",
    type: "code_output",
    question: "What does file.readline() return when called on an empty file?",
    codeSnippet: `# Assume empty.txt is an empty file
with open("empty.txt", "r") as file:
    line = file.readline()
    print(repr(line))`,
    options: ["None", '""', "[]", "Error"],
    correctAnswer: '""',
    explanation:
      "readline() returns an empty string when there's nothing to read.",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m7_q5",
    type: "mcq",
    question: "Which method reads all lines into a list?",
    codeSnippet: null,
    options: ["read()", "readline()", "readlines()", "readall()"],
    correctAnswer: "readlines()",
    explanation:
      "readlines() returns a list where each element is a line from the file.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m7_q6",
    type: "debug",
    question: "Fix the CSV writing code:",
    codeSnippet: `import csv
data = [["Name", "Age"], ["Alice", 25]]
with open("output.csv", "w") as file:
    writer = csv.writer(file)
    writer.write(data)`,
    options: [
      "writer.writerows(data)",
      "writer.writelines(data)",
      "writer.append(data)",
      "writer.save(data)",
    ],
    correctAnswer: "writer.writerows(data)",
    explanation:
      "CSV writer uses writerows() to write multiple rows, not write().",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m7_q7",
    type: "fill_code",
    question: "Complete the code to load JSON data:",
    codeSnippet: `import json
with open("data.json", "r") as file:
    data = json._____(file)`,
    options: ["load", "read", "parse", "get"],
    correctAnswer: "load",
    explanation: "json.load() reads JSON data from a file object.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m7_q8",
    type: "mcq",
    question:
      "What happens when you open a file in 'w' mode that already exists?",
    codeSnippet: null,
    options: [
      "It appends to the file",
      "It overwrites the file",
      "It raises an error",
      "It creates a backup",
    ],
    correctAnswer: "It overwrites the file",
    explanation:
      "Mode 'w' overwrites existing files completely. Use 'a' to append.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m7_q9",
    type: "code_output",
    question: "What type of object does csv.DictReader return for each row?",
    codeSnippet: `# CSV contains: Name,Age
#              Alice,25
reader = csv.DictReader(file)
row = next(reader)
print(type(row))`,
    options: ["list", "dict", "tuple", "str"],
    correctAnswer: "dict",
    explanation:
      "DictReader returns each row as a dictionary with column names as keys.",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m7_q10",
    type: "boolean",
    question: "JSON can only store string data.",
    codeSnippet: null,
    options: ["True", "False"],
    correctAnswer: "False",
    explanation:
      "JSON supports strings, numbers, booleans, arrays, objects, and null.",
    difficulty: "easy",
    points: 1,
  },
];

async function addModule7Content() {
  console.log("🚀 Adding Module 7 content...\n");

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

    console.log("\n🎉 Module 7 content added successfully!");
    console.log("📝 Next: Run add_module_8_content.js");
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    process.exit(0);
  }
}

// Run the function
addModule7Content();
