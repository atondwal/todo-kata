"""Minimal CLI todo list app. See spec/todo.md for details."""

import json
import os
import sys

TODOS_FILE = "todos.json"


def load_todos():
    if not os.path.exists(TODOS_FILE):
        return []
    with open(TODOS_FILE) as f:
        return json.load(f)


def save_todos(todos):
    with open(TODOS_FILE, "w") as f:
        json.dump(todos, f, indent=2)


def next_id(todos):
    if not todos:
        return 1
    return max(t["id"] for t in todos) + 1


def find_todo(todos, todo_id):
    for t in todos:
        if t["id"] == todo_id:
            return t
    return None


def cmd_add(args):
    text = args[0]
    todos = load_todos()
    todo = {"id": next_id(todos), "text": text, "done": False}
    todos.append(todo)
    save_todos(todos)
    print(f"Added: {text}")


def cmd_list(args):
    todos = load_todos()
    for t in todos:
        check = "x" if t["done"] else " "
        text = t["text"]
        if t["done"]:
            # Dim text for done items
            text = f"\033[2m{text}\033[0m"
        print(f"[{check}] {t['id']}: {text}")


def cmd_done(args):
    todo_id = int(args[0])
    todos = load_todos()
    todo = find_todo(todos, todo_id)
    if todo is None:
        print(f"No todo with ID {todo_id}", file=sys.stderr)
        sys.exit(1)
    todo["done"] = True
    save_todos(todos)
    print(f"Done: {todo['text']}")


def cmd_remove(args):
    todo_id = int(args[0])
    todos = load_todos()
    todo = find_todo(todos, todo_id)
    if todo is None:
        print(f"No todo with ID {todo_id}", file=sys.stderr)
        sys.exit(1)
    todos = [t for t in todos if t["id"] != todo_id]
    save_todos(todos)
    print(f"Removed: {todo['text']}")


COMMANDS = {
    "add": cmd_add,
    "list": cmd_list,
    "done": cmd_done,
    "remove": cmd_remove,
}

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] not in COMMANDS:
        print("Usage: python todo.py <add|list|done|remove> [args]", file=sys.stderr)
        sys.exit(1)
    COMMANDS[sys.argv[1]](sys.argv[2:])
