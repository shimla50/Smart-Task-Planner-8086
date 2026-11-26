# 🧠 Smart Task Planner 8086

A menu-driven task management system built with **8086 Assembly Language**.

This project was created as part of my **CSE341** coursework at BRAC University.  
The main goal of this project is to manage simple tasks using low-level Assembly programming concepts such as arrays, procedures, loops, conditional jumps, memory offsets, and DOS interrupts.

---

## 📌 Project Overview

**Smart Task Planner 8086** is a console-based task planner where users can add, view, search, update, delete, restore, and organize tasks.

Each task contains:

- Task ID
- Task title
- Task priority
- Task status
- Task description

The program stores task information in memory while the program is running.

---

## ✨ Features

- Add new tasks
- View all active tasks
- Search task by ID
- Sort tasks by priority
- Mark tasks as completed
- Delete tasks
- Undo the last deleted task
- Update task title, priority, and description
- Filter tasks by priority
- Simple menu-based interface

---

## 🛠️ Technologies Used

- 8086 Assembly Language
- DOS interrupt `INT 21H`
- MASM / TASM style syntax
- EMU8086 / DOSBox compatible environment

---

## 📁 Project Structure

```text
Smart-Task-Planner-8086/
│
├── Smart-Task-Planner-8086.asm
└── README.md
```

---

## ▶️ How to Run

You can run this project using any 8086 Assembly-supported environment.

Recommended tools:

- EMU8086
- MASM
- TASM
- DOSBox with assembler setup

Basic steps:

1. Open `Smart-Task-Planner-8086.asm`
2. Assemble the file
3. Run the generated executable
4. Use the menu options to manage tasks

---

## 🧩 Menu Options

```text
1. Add Task
2. View All Tasks
3. Search Task by ID
4. Sort Tasks by Priority
5. Mark Task Completed
6. Delete Task
7. Undo Last Delete
8. Update Task
9. Filter by Priority
0. Exit
```

---

## ⚙️ How It Works

All data lives in fixed-size arrays in the `.DATA` segment. One task is one index across these parallel arrays:

| Array | Size | Holds |
|---|---|---|
| `TASK_IDS` | 20 bytes | Task ID |
| `TASK_TITLES` | 20 × 20 bytes | Title, up to 19 characters |
| `TASK_PRIORITIES` | 20 bytes | 1 = Low, 2 = Medium, 3 = High |
| `TASK_STATUS` | 20 bytes | Pending or Done |
| `TASK_ACTIVE` | 20 bytes | 1 if the task exists, 0 if deleted |
| `DESC_BUFFER` + `TASK_DESC_OFFSETS` | 2 KB + 20 words | All descriptions in one shared buffer, with each task's start offset |

Key ideas in the code:

- **Sorting**: bubble sort by priority (High first). Every swap moves the matching entries in all the parallel arrays, including the 20-byte titles, so each task stays intact.
- **Delete and undo**: deleting only sets `TASK_ACTIVE` to 0 and remembers the index in `LAST_DELETED_INDEX`, so the last deleted task can be restored.
- **Input and output**: `READ_NUMBER`, `PRINT_NUMBER`, `READ_STRING` and `READ_DYNAMIC_STRING` are hand-written procedures built on DOS `INT 21H`.

### Limits

- Up to 20 tasks per run.
- Titles up to 19 characters; descriptions share a 2 KB buffer.
- Undo restores only the most recently deleted task.
- Tasks are kept in memory only and are lost when the program exits.

---

## 🚀 Why This Project Matters

This project shows how a practical task management system can be built using low-level programming.

Instead of using built-in data structures, the program manually handles:

- Memory allocation
- Task indexing
- String input
- Number input
- Sorting logic
- Task searching
- Status tracking
- Procedure-based code organization

It helped me understand how higher-level programming concepts work internally.

---

## 📄 Main Source File

```text
Smart-Task-Planner-8086.asm
```

This file contains the full Assembly source code of the project.

---

## 👩‍💻 Author

**Shimla**

GitHub: [@shimla50](https://github.com/shimla50)

---

## ⭐ Note

This project was developed for academic learning and practice with 8086 Assembly Language.