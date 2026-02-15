# Todo CLI

A minimal Python CLI todo list app. Single file, no dependencies beyond stdlib.

## Commands

```
python todo.py add "buy milk"        # Add a todo
python todo.py list                  # List all todos
python todo.py done 1                # Mark todo #1 as done
python todo.py remove 1              # Remove todo #1
```

## Storage

Todos are stored in `todos.json` in the current directory. Format:

```json
[
  {"id": 1, "text": "buy milk", "done": false},
  {"id": 2, "text": "walk dog", "done": true}
]
```

IDs auto-increment (max existing ID + 1).

## Output

- `list` shows todos with checkboxes: `[x] 1: buy milk` or `[ ] 2: walk dog`
- Done items shown with strikethrough-style dim text
- `add` prints "Added: <text>"
- `done` prints "Done: <text>"
- `remove` prints "Removed: <text>"
- Invalid ID prints "No todo with ID <n>" and exits 1
