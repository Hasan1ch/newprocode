// add_module_8_content.js
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

// Module 8 Lessons
const lessons = [
  {
    id: "python_fundamentals_m8_lesson_1",
    moduleId: "python_fundamentals_module_8",
    courseId: "python_fundamentals",
    title: "Understanding and Handling Errors",
    content: `# Understanding and Handling Errors

## Types of Errors

Python has different error types:

\`\`\`python
# Syntax Error - Code won't run
# print("Hello"  # Missing parenthesis

# Runtime Errors - Happen during execution
# number = 10 / 0  # ZeroDivisionError
# my_list = [1, 2, 3]
# print(my_list[10])  # IndexError

# Logic Errors - Code runs but gives wrong result
# average = sum([10, 20, 30]) / 2  # Should be /3
\`\`\`

## Try-Except Blocks

Handle errors gracefully:

\`\`\`python
# Basic error handling
try:
    number = int(input("Enter a number: "))
    result = 10 / number
    print(f"Result: {result}")
except ValueError:
    print("That's not a valid number!")
except ZeroDivisionError:
    print("Cannot divide by zero!")
\`\`\`

## Multiple Exception Handling

\`\`\`python
# Handle multiple exceptions
try:
    file = open("data.txt", "r")
    data = file.read()
    number = int(data)
    result = 100 / number
except FileNotFoundError:
    print("File not found!")
except ValueError:
    print("File doesn't contain a valid number!")
except ZeroDivisionError:
    print("Number in file is zero!")
finally:
    # Always runs, even if error occurs
    print("Cleanup complete")
\`\`\`

## Else and Finally

\`\`\`python
try:
    file = open("config.txt", "r")
except FileNotFoundError:
    print("Creating default config...")
else:
    # Runs only if no exception
    print("Config loaded successfully")
    file.close()
finally:
    # Always runs
    print("Configuration check complete")
\`\`\`

Handle errors like a pro! 🛡️`,
    videoUrl: "",
    orderIndex: 0,
    estimatedMinutes: 30,
    xpReward: 10,
    codeExamples: [
      `# Safe calculator
def safe_calculator():
    while True:
        try:
            num1 = float(input("Enter first number: "))
            operator = input("Enter operator (+, -, *, /): ")
            num2 = float(input("Enter second number: "))
            
            if operator == "+":
                result = num1 + num2
            elif operator == "-":
                result = num1 - num2
            elif operator == "*":
                result = num1 * num2
            elif operator == "/":
                result = num1 / num2
            else:
                print("Invalid operator!")
                continue
            
            print(f"Result: {result}")
            break
            
        except ValueError:
            print("Please enter valid numbers!")
        except ZeroDivisionError:
            print("Cannot divide by zero!")
        except KeyboardInterrupt:
            print("\\nCalculator closed.")
            break
        except Exception as e:
            print(f"Unexpected error: {e}")

# Run calculator
safe_calculator()`,
      `# File processor with error handling
def process_data_file(filename):
    """Safely process a data file"""
    try:
        with open(filename, "r") as file:
            lines = file.readlines()
            
        numbers = []
        errors = []
        
        for i, line in enumerate(lines, 1):
            try:
                number = float(line.strip())
                numbers.append(number)
            except ValueError:
                errors.append(f"Line {i}: '{line.strip()}' is not a number")
        
        if numbers:
            print(f"Successfully processed {len(numbers)} numbers")
            print(f"Sum: {sum(numbers)}")
            print(f"Average: {sum(numbers)/len(numbers):.2f}")
        
        if errors:
            print(f"\\nFound {len(errors)} errors:")
            for error in errors[:3]:  # Show first 3 errors
                print(f"  - {error}")
            
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        return None
    except Exception as e:
        print(f"Unexpected error: {e}")
        return None

# Test the function
process_data_file("numbers.txt")`,
    ],
    keyPoints: [
      "Use try-except to handle potential errors",
      "Catch specific exceptions before general ones",
      "finally block always executes",
      "else block runs if no exception occurs",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m8_lesson_2",
    moduleId: "python_fundamentals_module_8",
    courseId: "python_fundamentals",
    title: "Raising and Creating Custom Exceptions",
    content: `# Raising and Creating Custom Exceptions

## Raising Exceptions

Sometimes you need to raise errors:

\`\`\`python
def validate_age(age):
    if age < 0:
        raise ValueError("Age cannot be negative!")
    if age > 150:
        raise ValueError("Age seems unrealistic!")
    return age

# Using the function
try:
    age = validate_age(-5)
except ValueError as e:
    print(f"Invalid input: {e}")
\`\`\`

## Custom Exception Classes

Create your own exception types:

\`\`\`python
# Define custom exceptions
class GameError(Exception):
    """Base class for game exceptions"""
    pass

class InvalidMoveError(GameError):
    """Raised when move is invalid"""
    def __init__(self, move, reason):
        self.move = move
        self.reason = reason
        super().__init__(f"Invalid move '{move}': {reason}")

class GameOverError(GameError):
    """Raised when game is over"""
    pass

# Using custom exceptions
def make_move(position, board):
    if position < 0 or position > 8:
        raise InvalidMoveError(position, "Position out of bounds")
    if board[position] != ' ':
        raise InvalidMoveError(position, "Position already taken")
    # Make the move...
\`\`\`

## Exception Chaining

Show related errors:

\`\`\`python
def load_user_data(user_id):
    try:
        # Try to load from database
        data = database.get(user_id)
    except DatabaseError as e:
        # Chain exceptions to show cause
        raise UserNotFoundError(f"User {user_id} not found") from e

# The traceback will show both exceptions
\`\`\`

## Best Practices

\`\`\`python
# Good: Specific error handling
def divide_safe(a, b):
    try:
        return a / b
    except ZeroDivisionError:
        return float('inf')  # Or None, or raise custom error

# Good: Validation with clear errors
def create_user(name, age, email):
    if not name or not isinstance(name, str):
        raise ValueError("Name must be a non-empty string")
    if not 0 < age < 150:
        raise ValueError(f"Age {age} is not valid")
    if '@' not in email:
        raise ValueError("Invalid email format")
    
    return {"name": name, "age": age, "email": email}
\`\`\`

Create robust applications! 💪`,
    videoUrl: "",
    orderIndex: 1,
    estimatedMinutes: 35,
    xpReward: 10,
    codeExamples: [
      `# Password validator with custom exceptions
class PasswordError(Exception):
    """Base class for password exceptions"""
    pass

class PasswordTooShortError(PasswordError):
    """Password is too short"""
    pass

class PasswordTooWeakError(PasswordError):
    """Password doesn't meet complexity requirements"""
    pass

def validate_password(password):
    """Validate password strength"""
    if len(password) < 8:
        raise PasswordTooShortError("Password must be at least 8 characters")
    
    has_upper = any(c.isupper() for c in password)
    has_lower = any(c.islower() for c in password)
    has_digit = any(c.isdigit() for c in password)
    has_special = any(c in "!@#\$%^&*" for c in password)
    
    if not (has_upper and has_lower and has_digit):
        raise PasswordTooWeakError(
            "Password must contain uppercase, lowercase, and digits"
        )
    
    # Password is valid
    strength = "Strong" if has_special else "Medium"
    return f"Password accepted. Strength: {strength}"

# Test the validator
test_passwords = ["abc", "password", "Password1", "P@ssw0rd!"]

for pwd in test_passwords:
    try:
        result = validate_password(pwd)
        print(f"'{pwd}': {result}")
    except PasswordTooShortError as e:
        print(f"'{pwd}': Too short - {e}")
    except PasswordTooWeakError as e:
        print(f"'{pwd}': Too weak - {e}")`,
      `# Bank account with exception handling
class BankAccount:
    class InsufficientFundsError(Exception):
        """Not enough money in account"""
        def __init__(self, requested, available):
            super().__init__(
                f"Requested \${requested:.2f} but only \${available:.2f} available"
            )
            self.requested = requested
            self.available = available
    
    def __init__(self, owner, initial_balance=0):
        self.owner = owner
        self.balance = initial_balance
        self.transactions = []
    
    def deposit(self, amount):
        if amount <= 0:
            raise ValueError("Deposit amount must be positive")
        
        self.balance += amount
        self.transactions.append(f"Deposit: +\${amount:.2f}")
        return self.balance
    
    def withdraw(self, amount):
        if amount <= 0:
            raise ValueError("Withdrawal amount must be positive")
        
        if amount > self.balance:
            raise self.InsufficientFundsError(amount, self.balance)
        
        self.balance -= amount
        self.transactions.append(f"Withdraw: -\${amount:.2f}")
        return self.balance
    
    def get_statement(self):
        print(f"Account: {self.owner}")
        print("Transactions:")
        last_five = self.transactions[-5:] if len(self.transactions) >= 5 else self.transactions
        for trans in last_five:
            print(f"  {trans}")
        print(f"Current balance: \${self.balance:.2f}")

# Use the bank account
account = BankAccount("Alice", 100)

try:
    account.deposit(50)
    account.withdraw(30)
    account.withdraw(200)  # This will fail
except BankAccount.InsufficientFundsError as e:
    print(f"Transaction failed: {e}")
finally:
    account.get_statement()`,
    ],
    keyPoints: [
      "Raise exceptions with clear error messages",
      "Create custom exceptions for specific errors",
      "Inherit from Exception or specific exception types",
      "Use exception chaining to show root causes",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    id: "python_fundamentals_m8_lesson_3",
    moduleId: "python_fundamentals_module_8",
    courseId: "python_fundamentals",
    title: "Final Project: Building a Complete Application",
    content: `# Final Project: Building a Complete Application

## Project: Personal Task Manager

Let's build a complete application using everything we've learned!

## Project Structure

\`\`\`python
# Task Manager Features:
# 1. Add tasks with priorities
# 2. Mark tasks as complete
# 3. Save/load from file
# 4. Search and filter tasks
# 5. Generate reports
\`\`\`

## Core Classes

\`\`\`python
from datetime import datetime
import json
import os

class Task:
    def __init__(self, title, priority="medium", due_date=None):
        self.id = datetime.now().timestamp()
        self.title = title
        self.priority = priority
        self.due_date = due_date
        self.completed = False
        self.created_at = datetime.now().isoformat()
    
    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "priority": self.priority,
            "due_date": self.due_date,
            "completed": self.completed,
            "created_at": self.created_at
        }
    
    @classmethod
    def from_dict(cls, data):
        task = cls(data["title"], data["priority"], data["due_date"])
        task.id = data["id"]
        task.completed = data["completed"]
        task.created_at = data["created_at"]
        return task
\`\`\`

## Main Application

\`\`\`python
class TaskManager:
    def __init__(self, filename="tasks.json"):
        self.filename = filename
        self.tasks = []
        self.load_tasks()
    
    def add_task(self, title, priority="medium", due_date=None):
        if not title:
            raise ValueError("Task title cannot be empty")
        
        task = Task(title, priority, due_date)
        self.tasks.append(task)
        self.save_tasks()
        return task
    
    def complete_task(self, task_id):
        task = self.find_task(task_id)
        if task:
            task.completed = True
            self.save_tasks()
            return True
        return False
    
    def list_tasks(self, show_completed=False):
        filtered = [t for t in self.tasks 
                   if show_completed or not t.completed]
        
        # Sort by priority
        priority_order = {"high": 0, "medium": 1, "low": 2}
        filtered.sort(key=lambda t: priority_order.get(t.priority, 3))
        
        return filtered
\`\`\`

## File Operations

\`\`\`python
    def save_tasks(self):
        try:
            data = [task.to_dict() for task in self.tasks]
            with open(self.filename, "w") as file:
                json.dump(data, file, indent=2)
        except Exception as e:
            print(f"Error saving tasks: {e}")
    
    def load_tasks(self):
        try:
            if os.path.exists(self.filename):
                with open(self.filename, "r") as file:
                    data = json.load(file)
                    self.tasks = [Task.from_dict(item) for item in data]
        except Exception as e:
            print(f"Error loading tasks: {e}")
            self.tasks = []
\`\`\`

## User Interface

\`\`\`python
def main():
    manager = TaskManager()
    
    while True:
        print("\\n=== Task Manager ===")
        print("1. Add Task")
        print("2. List Tasks")
        print("3. Complete Task")
        print("4. Generate Report")
        print("5. Exit")
        
        try:
            choice = input("\\nChoice: ")
            
            if choice == "1":
                title = input("Task title: ")
                priority = input("Priority (high/medium/low): ") or "medium"
                manager.add_task(title, priority)
                print("✓ Task added!")
                
            elif choice == "2":
                tasks = manager.list_tasks()
                if not tasks:
                    print("No pending tasks!")
                else:
                    for task in tasks:
                        status = "✓" if task.completed else "○"
                        print(f"{status} [{task.priority}] {task.title}")
                        
            elif choice == "5":
                print("Goodbye!")
                break
                
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    main()
\`\`\`

Congratulations! You've built a complete Python application! 🎉`,
    videoUrl: "",
    orderIndex: 2,
    estimatedMinutes: 60,
    xpReward: 10,
    codeExamples: [
      `# Extended Task Manager with search and statistics
class ExtendedTaskManager(TaskManager):
    def search_tasks(self, keyword):
        """Search tasks by title"""
        keyword = keyword.lower()
        return [task for task in self.tasks 
                if keyword in task.title.lower()]
    
    def get_statistics(self):
        """Generate task statistics"""
        total = len(self.tasks)
        completed = sum(1 for t in self.tasks if t.completed)
        pending = total - completed
        
        by_priority = {}
        for task in self.tasks:
            if not task.completed:
                priority = task.priority
                by_priority[priority] = by_priority.get(priority, 0) + 1
        
        return {
            "total": total,
            "completed": completed,
            "pending": pending,
            "by_priority": by_priority,
            "completion_rate": (completed / total * 100) if total > 0 else 0
        }
    
    def generate_report(self):
        """Generate a text report"""
        stats = self.get_statistics()
        
        report = []
        report.append("=" * 40)
        report.append("TASK MANAGER REPORT")
        report.append("=" * 40)
        report.append(f"Total Tasks: {stats['total']}")
        report.append(f"Completed: {stats['completed']}")
        report.append(f"Pending: {stats['pending']}")
        report.append(f"Completion Rate: {stats['completion_rate']:.1f}%")
        
        if stats['by_priority']:
            report.append("\\nPending by Priority:")
            for priority, count in stats['by_priority'].items():
                report.append(f"  {priority.capitalize()}: {count}")
        
        report.append("=" * 40)
        
        # Save report
        with open("task_report.txt", "w") as file:
            file.write("\\n".join(report))
        
        return "\\n".join(report)

# Example usage
manager = ExtendedTaskManager()

# Add sample tasks
manager.add_task("Complete Python course", "high")
manager.add_task("Build portfolio project", "high")
manager.add_task("Update resume", "medium")
manager.add_task("Apply for jobs", "medium")

# Complete a task
tasks = manager.list_tasks()
if tasks:
    manager.complete_task(tasks[0].id)

# Generate report
print(manager.generate_report())`,
      `# Task Manager with data validation and error handling
class RobustTaskManager(ExtendedTaskManager):
    VALID_PRIORITIES = ["high", "medium", "low"]
    
    def add_task(self, title, priority="medium", due_date=None):
        # Validate inputs
        if not title or not isinstance(title, str):
            raise ValueError("Task title must be a non-empty string")
        
        if len(title) > 100:
            raise ValueError("Task title too long (max 100 characters)")
        
        if priority not in self.VALID_PRIORITIES:
            raise ValueError(f"Priority must be one of: {', '.join(self.VALID_PRIORITIES)}")
        
        # Validate due date if provided
        if due_date:
            try:
                # Expect format: YYYY-MM-DD
                datetime.strptime(due_date, "%Y-%m-%d")
            except ValueError:
                raise ValueError("Due date must be in format YYYY-MM-DD")
        
        return super().add_task(title, priority, due_date)
    
    def export_to_csv(self, filename="tasks.csv"):
        """Export tasks to CSV file"""
        import csv
        
        try:
            with open(filename, "w", newline="") as file:
                fieldnames = ["id", "title", "priority", "due_date", "completed", "created_at"]
                writer = csv.DictWriter(file, fieldnames=fieldnames)
                
                writer.writeheader()
                for task in self.tasks:
                    writer.writerow(task.to_dict())
            
            return f"Exported {len(self.tasks)} tasks to {filename}"
        except Exception as e:
            raise Exception(f"Failed to export tasks: {e}")
    
    def import_from_csv(self, filename="tasks.csv"):
        """Import tasks from CSV file"""
        import csv
        
        if not os.path.exists(filename):
            raise FileNotFoundError(f"File {filename} not found")
        
        imported = 0
        errors = []
        
        try:
            with open(filename, "r") as file:
                reader = csv.DictReader(file)
                
                for row_num, row in enumerate(reader, 2):
                    try:
                        task = Task.from_dict({
                            "id": float(row["id"]),
                            "title": row["title"],
                            "priority": row["priority"],
                            "due_date": row["due_date"] if row["due_date"] else None,
                            "completed": row["completed"].lower() == "true",
                            "created_at": row["created_at"]
                        })
                        self.tasks.append(task)
                        imported += 1
                    except Exception as e:
                        errors.append(f"Row {row_num}: {e}")
            
            self.save_tasks()
            
            result = f"Imported {imported} tasks"
            if errors:
                result += f" ({len(errors)} errors)"
            
            return result, errors
            
        except Exception as e:
            raise Exception(f"Failed to import tasks: {e}")

# Complete application example
if __name__ == "__main__":
    # Create task manager
    manager = RobustTaskManager()
    
    # Demonstrate error handling
    try:
        manager.add_task("")  # Will raise error
    except ValueError as e:
        print(f"Error handled: {e}")
    
    # Add valid tasks
    manager.add_task("Complete final project", "high", "2024-12-31")
    manager.add_task("Review all modules", "medium")
    
    # Export and show success
    print(manager.export_to_csv())
    print("\\nProject complete! You're now a Python programmer! 🎉")`,
    ],
    keyPoints: [
      "Combine all concepts: functions, classes, files, errors",
      "Plan before coding - design your application",
      "Use proper error handling throughout",
      "Save and load data for persistence",
    ],
    challengeId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// Module 8 Quiz
const quiz = {
  id: "python_fundamentals_m8_quiz",
  title: "Final Assessment - Python Mastery",
  description: "Test your complete Python knowledge with this final challenge",
  courseId: "python_fundamentals",
  moduleId: "python_fundamentals_module_8",
  difficulty: "hard",
  category: "python_basics",
  timeLimit: 900,
  passingScore: 70,
  totalQuestions: 10,
  xpReward: 50,
  isActive: true,
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
};

// Module 8 Quiz Questions
const questions = [
  {
    id: "python_fundamentals_m8_q1",
    type: "fill_code",
    question: "Complete the code to handle a specific exception:",
    codeSnippet: `try:
    result = 10 / 0
___ ZeroDivisionError:
    print("Cannot divide by zero!")`,
    options: ["except", "catch", "handle", "error"],
    correctAnswer: "except",
    explanation:
      "Use 'except' followed by the exception type to catch specific errors.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m8_q2",
    type: "mcq",
    question: "Which block always executes whether an exception occurs or not?",
    codeSnippet: null,
    options: ["else", "except", "finally", "always"],
    correctAnswer: "finally",
    explanation:
      "The finally block always executes, regardless of whether an exception occurred.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m8_q3",
    type: "code_output",
    question: "What will this code print?",
    codeSnippet: `try:
    x = 5
    y = x + 3
except:
    print("Error")
else:
    print("Success")
finally:
    print("Done")`,
    options: ["Error\\nDone", "Success\\nDone", "Done", "Success"],
    correctAnswer: "Success\\nDone",
    explanation:
      "No exception occurs, so else block runs, followed by finally block.",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m8_q4",
    type: "boolean",
    question: "You can create custom exception classes in Python.",
    codeSnippet: null,
    options: ["True", "False"],
    correctAnswer: "True",
    explanation:
      "You can create custom exceptions by inheriting from the Exception class.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m8_q5",
    type: "debug",
    question: "Fix the error in this exception handling:",
    codeSnippet: `try:
    file = open("data.txt", "r")
    content = file.read()
except FileNotFoundError, e:
    print(f"Error: {e}")`,
    options: [
      "except FileNotFoundError as e:",
      "except FileNotFoundError: e",
      "except (FileNotFoundError, e):",
      "except FileNotFoundError -> e:",
    ],
    correctAnswer: "except FileNotFoundError as e:",
    explanation: "Use 'as' to assign the exception to a variable in Python 3.",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m8_q6",
    type: "mcq",
    question: "What's the best practice for file handling with exceptions?",
    codeSnippet: null,
    options: [
      "Always use try-except around file operations",
      "Use 'with' statement for automatic cleanup",
      "Check if file exists before opening",
      "All of the above",
    ],
    correctAnswer: "All of the above",
    explanation:
      "Good file handling combines 'with' statements, existence checks, and exception handling.",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m8_q7",
    type: "fill_code",
    question: "Complete the code to raise a custom error:",
    codeSnippet: `if age < 0:
    ___ ValueError("Age cannot be negative")`,
    options: ["raise", "throw", "error", "except"],
    correctAnswer: "raise",
    explanation: "Use 'raise' to throw an exception in Python.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m8_q8",
    type: "code_output",
    question: "What type of error will this code raise?",
    codeSnippet: `numbers = [1, 2, 3]
print(numbers[5])`,
    options: ["ValueError", "IndexError", "KeyError", "TypeError"],
    correctAnswer: "IndexError",
    explanation:
      "Accessing an index that doesn't exist in a list raises IndexError.",
    difficulty: "easy",
    points: 1,
  },
  {
    id: "python_fundamentals_m8_q9",
    type: "mcq",
    question: "Which approach is best for a production application?",
    codeSnippet: null,
    options: [
      "Catch all exceptions with bare except:",
      "Let exceptions crash the program",
      "Log errors and handle gracefully",
      "Ignore exceptions silently",
    ],
    correctAnswer: "Log errors and handle gracefully",
    explanation:
      "Production apps should log errors for debugging while handling them gracefully for users.",
    difficulty: "medium",
    points: 1,
  },
  {
    id: "python_fundamentals_m8_q10",
    type: "boolean",
    question:
      "A well-designed Python application should validate user input before processing.",
    codeSnippet: null,
    options: ["True", "False"],
    correctAnswer: "True",
    explanation:
      "Input validation prevents errors and security issues. Always validate before processing.",
    difficulty: "easy",
    points: 1,
  },
];

async function addModule8Content() {
  console.log("🚀 Adding Module 8 content...\n");

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
      console.log(`✅ Question ${question.id.slice(-2)} added`);
    }

    console.log("\n🎉 Module 8 content added successfully!");
    console.log(
      "\n🎊 CONGRATULATIONS! All Python Fundamentals content is complete!"
    );
    console.log("📚 8 Modules");
    console.log("📝 8 Quizzes");
    console.log("💡 80 Questions");
    console.log("🚀 Ready for students to learn Python!");
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    process.exit(0);
  }
}

// Run the function
addModule8Content();
