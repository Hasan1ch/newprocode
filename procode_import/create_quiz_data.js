// create_quiz_data.js
// This script creates comprehensive quiz data for ProCode

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Quiz data organized by category
const quizData = {
  // Module Quizzes for Python Fundamentals course
  moduleQuizzes: [
    {
      title: "Python Variables & Data Types",
      description: "Test your understanding of Python variables and data types",
      courseId: "python_fundamentals",
      moduleId: "module_001",
      difficulty: "beginner",
      category: "module",
      timeLimit: 600, // 10 minutes
      passingScore: 70,
      totalQuestions: 10,
      xpReward: 50,
      isActive: true,
      questions: [
        {
          type: "mcq",
          question: "Which of the following is a valid Python variable name?",
          options: ["2variable", "_variable", "variable-name", "class"],
          correctAnswer: "_variable",
          explanation:
            "Variable names can start with letters or underscore, but not numbers or contain hyphens. 'class' is a reserved keyword.",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "What is the output of: type(3.14)",
          codeSnippet: "type(3.14)",
          options: [
            "<class 'int'>",
            "<class 'float'>",
            "<class 'str'>",
            "<class 'number'>",
          ],
          correctAnswer: "<class 'float'>",
          explanation:
            "3.14 is a floating-point number, so its type is 'float'",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "Which data type is mutable in Python?",
          options: ["int", "str", "list", "tuple"],
          correctAnswer: "list",
          explanation:
            "Lists are mutable (can be changed), while int, str, and tuple are immutable",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "boolean",
          question: "True or False: Python is a statically typed language",
          options: ["True", "False"],
          correctAnswer: "False",
          explanation:
            "Python is dynamically typed - variable types are determined at runtime",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "What will be the output?",
          codeSnippet: "x = 5\ny = '5'\nprint(x == y)",
          options: ["True", "False", "Error", "None"],
          correctAnswer: "False",
          explanation: "5 (int) is not equal to '5' (string) in Python",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "mcq",
          question: "How do you create a multi-line string in Python?",
          options: [
            "Using single quotes ''",
            'Using double quotes ""',
            "Using triple quotes ''' or \"\"\"",
            "Using backticks ``",
          ],
          correctAnswer: "Using triple quotes ''' or \"\"\"",
          explanation: "Triple quotes allow strings to span multiple lines",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "What is the result of: 10 // 3",
          codeSnippet: "10 // 3",
          options: ["3.33", "3", "4", "3.0"],
          correctAnswer: "3",
          explanation: "// is floor division operator, returns integer result",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "mcq",
          question: "Which method converts a string to lowercase?",
          options: [".lowercase()", ".lower()", ".toLower()", ".downcase()"],
          correctAnswer: ".lower()",
          explanation:
            "The lower() method converts all characters to lowercase",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "boolean",
          question:
            "True or False: In Python, 'None' represents the absence of a value",
          options: ["True", "False"],
          correctAnswer: "True",
          explanation:
            "None is Python's null value, representing absence of a value",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "What is the output?",
          codeSnippet: "x = [1, 2, 3]\ny = x\ny.append(4)\nprint(x)",
          options: ["[1, 2, 3]", "[1, 2, 3, 4]", "Error", "[4]"],
          correctAnswer: "[1, 2, 3, 4]",
          explanation:
            "Lists are mutable and y = x creates a reference, not a copy",
          difficulty: "hard",
          points: 5,
        },
      ],
    },
    {
      title: "Python Control Flow",
      description: "Master if statements, loops, and control structures",
      courseId: "python_fundamentals",
      moduleId: "module_002",
      difficulty: "beginner",
      category: "module",
      timeLimit: 900, // 15 minutes
      passingScore: 70,
      totalQuestions: 10,
      xpReward: 50,
      isActive: true,
      questions: [
        {
          type: "mcq",
          question: "What is the correct syntax for an if statement in Python?",
          options: [
            "if (x > 5):",
            "if x > 5:",
            "if x > 5 then:",
            "if (x > 5) {",
          ],
          correctAnswer: "if x > 5:",
          explanation:
            "Python doesn't require parentheses for conditions and uses colon",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "What will this code print?",
          codeSnippet: "for i in range(3):\n    print(i)",
          options: ["0 1 2", "1 2 3", "0 1 2 3", "1 2"],
          correctAnswer: "0 1 2",
          explanation: "range(3) generates numbers 0, 1, 2",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "Which keyword is used to exit a loop prematurely?",
          options: ["exit", "break", "stop", "end"],
          correctAnswer: "break",
          explanation: "The 'break' keyword exits the current loop",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "What does 'continue' do in a loop?",
          options: [
            "Exits the loop",
            "Skips to the next iteration",
            "Pauses the loop",
            "Restarts the loop",
          ],
          correctAnswer: "Skips to the next iteration",
          explanation:
            "'continue' skips the rest of the current iteration and moves to the next",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "boolean",
          question: "True or False: Python has a do-while loop",
          options: ["True", "False"],
          correctAnswer: "False",
          explanation: "Python only has 'while' and 'for' loops, no do-while",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "mcq",
          question: "What is the output?",
          codeSnippet:
            "x = 5\nif x > 10:\n    print('A')\nelif x > 3:\n    print('B')\nelse:\n    print('C')",
          options: ["A", "B", "C", "Nothing"],
          correctAnswer: "B",
          explanation:
            "x is 5, which is not > 10 but is > 3, so 'B' is printed",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "mcq",
          question: "How do you create an infinite loop in Python?",
          options: ["for(;;)", "while True:", "loop:", "infinite:"],
          correctAnswer: "while True:",
          explanation:
            "while True: creates an infinite loop that runs until broken",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "What is the output?",
          codeSnippet: "for i in range(2, 8, 2):\n    print(i, end=' ')",
          options: ["2 4 6 8", "2 4 6", "2 3 4 5 6 7", "2 4 6 8 10"],
          correctAnswer: "2 4 6",
          explanation: "range(2, 8, 2) starts at 2, stops before 8, steps by 2",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "boolean",
          question: "True or False: 'else' can be used with loops in Python",
          options: ["True", "False"],
          correctAnswer: "True",
          explanation:
            "Python allows 'else' with for/while loops, executed when loop completes normally",
          difficulty: "hard",
          points: 5,
        },
        {
          type: "mcq",
          question: "What does this list comprehension produce?",
          codeSnippet: "[x**2 for x in range(4) if x % 2 == 0]",
          options: ["[0, 4]", "[0, 1, 4, 9]", "[1, 9]", "[0, 2, 4]"],
          correctAnswer: "[0, 4]",
          explanation: "Squares of even numbers from 0 to 3: 0² = 0, 2² = 4",
          difficulty: "hard",
          points: 5,
        },
      ],
    },
  ],

  // Quick Challenge Quizzes
  quickChallenges: [
    {
      title: "Python Basics Speed Run",
      description: "5 quick questions to test your Python fundamentals",
      courseId: "general",
      difficulty: "easy",
      category: "quick",
      timeLimit: 300, // 5 minutes
      passingScore: 60,
      totalQuestions: 5,
      xpReward: 25,
      isActive: true,
      questions: [
        {
          type: "mcq",
          question: "How do you print 'Hello World' in Python?",
          options: [
            "echo 'Hello World'",
            "print('Hello World')",
            "console.log('Hello World')",
            "printf('Hello World')",
          ],
          correctAnswer: "print('Hello World')",
          explanation: "print() is the function used to output text in Python",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "boolean",
          question:
            "True or False: Python uses indentation to define code blocks",
          options: ["True", "False"],
          correctAnswer: "True",
          explanation:
            "Python uses indentation instead of curly braces for code blocks",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "Which symbol is used for single-line comments in Python?",
          options: ["//", "#", "/*", "--"],
          correctAnswer: "#",
          explanation: "# is used for single-line comments in Python",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "What is the file extension for Python files?",
          options: [".python", ".py", ".pyt", ".pt"],
          correctAnswer: ".py",
          explanation: "Python files use the .py extension",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "How do you get user input in Python?",
          options: ["get()", "input()", "read()", "scan()"],
          correctAnswer: "input()",
          explanation: "input() function is used to get user input",
          difficulty: "easy",
          points: 5,
        },
      ],
    },
    {
      title: "Data Structures Quick Check",
      description: "Test your knowledge of Python data structures",
      courseId: "general",
      difficulty: "medium",
      category: "quick",
      timeLimit: 300, // 5 minutes
      passingScore: 60,
      totalQuestions: 5,
      xpReward: 25,
      isActive: true,
      questions: [
        {
          type: "mcq",
          question: "How do you create an empty dictionary?",
          options: ["[]", "{}", "()", "dict[]"],
          correctAnswer: "{}",
          explanation:
            "{} creates an empty dictionary, [] creates an empty list",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "What method adds an element to the end of a list?",
          options: [".add()", ".append()", ".insert()", ".push()"],
          correctAnswer: ".append()",
          explanation: "append() adds an element to the end of a list",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "Which data structure is ordered and immutable?",
          options: ["list", "dict", "tuple", "set"],
          correctAnswer: "tuple",
          explanation: "Tuples are ordered and immutable (cannot be changed)",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "boolean",
          question: "True or False: Sets can contain duplicate values",
          options: ["True", "False"],
          correctAnswer: "False",
          explanation: "Sets automatically remove duplicates",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "mcq",
          question:
            "How do you access the value of key 'name' in dictionary d?",
          options: ["d.name", "d['name']", "d.get['name']", "d(name)"],
          correctAnswer: "d['name']",
          explanation:
            "Dictionary values are accessed using square brackets with the key",
          difficulty: "medium",
          points: 5,
        },
      ],
    },
  ],

  // Weekly Challenge Quizzes
  weeklyChallenges: [
    {
      title: "Python Master Challenge - Week 1",
      description: "Comprehensive test covering all Python basics",
      courseId: "general",
      difficulty: "hard",
      category: "weekly",
      timeLimit: 1800, // 30 minutes
      passingScore: 80,
      totalQuestions: 20,
      xpReward: 100,
      isActive: true,
      questions: [
        {
          type: "mcq",
          question: "What is the output of this code?",
          codeSnippet: "x = [1, 2, 3]\ny = x[:]\ny.append(4)\nprint(x)",
          options: ["[1, 2, 3]", "[1, 2, 3, 4]", "Error", "[1, 2, 3, 4, 4]"],
          correctAnswer: "[1, 2, 3]",
          explanation:
            "x[:] creates a shallow copy, so modifying y doesn't affect x",
          difficulty: "hard",
          points: 5,
        },
        {
          type: "mcq",
          question:
            "Which method would you use to remove and return the last element from a list?",
          options: [".remove()", ".pop()", ".delete()", ".extract()"],
          correctAnswer: ".pop()",
          explanation:
            "pop() removes and returns the last element (or element at specified index)",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "mcq",
          question: "What does the 'pass' statement do?",
          options: [
            "Exits the function",
            "Does nothing",
            "Continues to next iteration",
            "Raises an error",
          ],
          correctAnswer: "Does nothing",
          explanation:
            "'pass' is a null operation - a placeholder where code will eventually go",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "boolean",
          question: "True or False: Python supports multiple inheritance",
          options: ["True", "False"],
          correctAnswer: "True",
          explanation:
            "Python allows a class to inherit from multiple parent classes",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "mcq",
          question: "What is the output?",
          codeSnippet:
            "def func(a, b=2, c=3):\n    return a + b + c\n\nprint(func(1, c=4))",
          options: ["6", "7", "8", "Error"],
          correctAnswer: "7",
          explanation: "func(1, c=4) uses a=1, b=2(default), c=4, so 1+2+4=7",
          difficulty: "hard",
          points: 5,
        },
        {
          type: "mcq",
          question:
            "Which of these is NOT a valid way to format strings in Python?",
          options: [
            "f'Hello {name}'",
            "'Hello %s' % name",
            "'Hello {}'.format(name)",
            "'Hello ' + name",
          ],
          correctAnswer: "'Hello ' + name",
          explanation:
            "While concatenation works, it's not a formatting method. All others are valid formatting techniques",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "mcq",
          question: "What exception is raised when dividing by zero?",
          options: [
            "ValueError",
            "ZeroDivisionError",
            "MathError",
            "DivisionError",
          ],
          correctAnswer: "ZeroDivisionError",
          explanation:
            "Python raises ZeroDivisionError when attempting to divide by zero",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "What is a lambda function?",
          options: [
            "A function that returns another function",
            "An anonymous function",
            "A recursive function",
            "A generator function",
          ],
          correctAnswer: "An anonymous function",
          explanation:
            "Lambda functions are anonymous (unnamed) functions defined in one line",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "boolean",
          question:
            "True or False: Global variables can be modified inside functions without the 'global' keyword",
          options: ["True", "False"],
          correctAnswer: "False",
          explanation:
            "To modify global variables inside functions, you need to use the 'global' keyword",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "mcq",
          question: "What is the result of: 'Python'[1:4]",
          codeSnippet: "'Python'[1:4]",
          options: ["'yth'", "'ytho'", "'Pyt'", "'tho'"],
          correctAnswer: "'yth'",
          explanation:
            "String slicing [1:4] returns characters from index 1 up to (but not including) 4",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "mcq",
          question: "Which module is used for regular expressions in Python?",
          options: ["regex", "re", "regexp", "pattern"],
          correctAnswer: "re",
          explanation:
            "The 're' module provides regular expression support in Python",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "mcq",
          question: "What is the output?",
          codeSnippet: "a = [1, 2, 3]\nb = a\na = a + [4]\nprint(b)",
          options: ["[1, 2, 3]", "[1, 2, 3, 4]", "Error", "[4]"],
          correctAnswer: "[1, 2, 3]",
          explanation:
            "a + [4] creates a new list, so b still references the original [1, 2, 3]",
          difficulty: "hard",
          points: 5,
        },
        {
          type: "boolean",
          question: "True or False: Dictionary keys must be immutable",
          options: ["True", "False"],
          correctAnswer: "True",
          explanation:
            "Dictionary keys must be immutable (strings, numbers, tuples), not lists or other dicts",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "mcq",
          question: "What does the zip() function do?",
          options: [
            "Compresses files",
            "Combines multiple iterables element-wise",
            "Creates a copy of a list",
            "Sorts a list",
          ],
          correctAnswer: "Combines multiple iterables element-wise",
          explanation:
            "zip() pairs up elements from multiple iterables into tuples",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "mcq",
          question:
            "Which method would you use to get all keys from a dictionary?",
          options: [".keys()", ".getkeys()", ".allkeys()", ".key_list()"],
          correctAnswer: ".keys()",
          explanation:
            "The keys() method returns a view of all dictionary keys",
          difficulty: "easy",
          points: 5,
        },
        {
          type: "mcq",
          question: "What is the output?",
          codeSnippet:
            "def outer():\n    x = 1\n    def inner():\n        nonlocal x\n        x = 2\n    inner()\n    return x\n\nprint(outer())",
          options: ["1", "2", "Error", "None"],
          correctAnswer: "2",
          explanation:
            "'nonlocal' allows inner function to modify the outer function's variable",
          difficulty: "hard",
          points: 5,
        },
        {
          type: "boolean",
          question:
            "True or False: Python lists are implemented as dynamic arrays",
          options: ["True", "False"],
          correctAnswer: "True",
          explanation:
            "Python lists are implemented as dynamic arrays that can grow/shrink as needed",
          difficulty: "hard",
          points: 5,
        },
        {
          type: "mcq",
          question: "What is a generator in Python?",
          options: [
            "A function that generates random numbers",
            "A function that returns an iterator",
            "A class that creates objects",
            "A module that generates code",
          ],
          correctAnswer: "A function that returns an iterator",
          explanation:
            "Generators are functions that return iterators using 'yield' keyword",
          difficulty: "hard",
          points: 5,
        },
        {
          type: "mcq",
          question: "Which of these will create a shallow copy of a list?",
          options: ["list.copy()", "list[:]", "list(list)", "All of the above"],
          correctAnswer: "All of the above",
          explanation: "All three methods create shallow copies of a list",
          difficulty: "medium",
          points: 5,
        },
        {
          type: "mcq",
          question:
            "What is the time complexity of accessing an element in a Python list by index?",
          options: ["O(1)", "O(n)", "O(log n)", "O(n²)"],
          correctAnswer: "O(1)",
          explanation: "List access by index is O(1) - constant time operation",
          difficulty: "hard",
          points: 5,
        },
      ],
    },
  ],
};

async function createQuizWithQuestions(quizInfo) {
  try {
    const { questions, ...quizData } = quizInfo;

    // Create quiz document
    const quizRef = await db.collection("quizzes").add({
      ...quizData,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Created quiz: ${quizData.title} (${quizRef.id})`);

    // Create questions subcollection
    const batch = db.batch();
    questions.forEach((question, index) => {
      const questionRef = quizRef.collection("questions").doc();
      batch.set(questionRef, {
        ...question,
        orderIndex: index,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    await batch.commit();
    console.log(`  Added ${questions.length} questions`);

    return quizRef.id;
  } catch (error) {
    console.error(`Error creating quiz ${quizInfo.title}:`, error);
    throw error;
  }
}

async function seedQuizzes() {
  console.log("🚀 Starting quiz seeding process...\n");

  try {
    // Create module quizzes
    console.log("📚 Creating Module Quizzes...");
    for (const quiz of quizData.moduleQuizzes) {
      await createQuizWithQuestions(quiz);
    }

    // Create quick challenges
    console.log("\n⚡ Creating Quick Challenges...");
    for (const quiz of quizData.quickChallenges) {
      await createQuizWithQuestions(quiz);
    }

    // Create weekly challenges
    console.log("\n🏆 Creating Weekly Challenges...");
    for (const quiz of quizData.weeklyChallenges) {
      await createQuizWithQuestions(quiz);
    }

    console.log("\n✅ Quiz seeding completed successfully!");
    console.log(
      `Total quizzes created: ${
        quizData.moduleQuizzes.length +
        quizData.quickChallenges.length +
        quizData.weeklyChallenges.length
      }`
    );
  } catch (error) {
    console.error("❌ Error during seeding:", error);
  } finally {
    process.exit();
  }
}

// Run the seeder
seedQuizzes();
