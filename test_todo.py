import json
import os
import subprocess
import sys
import tempfile
import unittest


class TodoTest(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()
        self.todos_path = os.path.join(self.tmpdir, "todos.json")

    def tearDown(self):
        if os.path.exists(self.todos_path):
            os.remove(self.todos_path)
        os.rmdir(self.tmpdir)

    def run_todo(self, *args):
        result = subprocess.run(
            [sys.executable, os.path.join(os.path.dirname(__file__), "todo.py"), *args],
            capture_output=True, text=True, cwd=self.tmpdir,
        )
        return result

    def load_todos(self):
        with open(self.todos_path) as f:
            return json.load(f)

    # --- add ---

    def test_add_creates_file_and_todo(self):
        r = self.run_todo("add", "buy milk")
        self.assertEqual(r.returncode, 0)
        self.assertEqual(r.stdout.strip(), "Added: buy milk")
        todos = self.load_todos()
        self.assertEqual(len(todos), 1)
        self.assertEqual(todos[0], {"id": 1, "text": "buy milk", "done": False})

    def test_add_increments_id(self):
        self.run_todo("add", "first")
        self.run_todo("add", "second")
        todos = self.load_todos()
        self.assertEqual(todos[0]["id"], 1)
        self.assertEqual(todos[1]["id"], 2)

    # --- list ---

    def test_list_empty(self):
        r = self.run_todo("list")
        self.assertEqual(r.returncode, 0)
        self.assertEqual(r.stdout.strip(), "")

    def test_list_shows_todos(self):
        self.run_todo("add", "buy milk")
        self.run_todo("add", "walk dog")
        r = self.run_todo("list")
        lines = r.stdout.strip().split("\n")
        self.assertEqual(len(lines), 2)
        self.assertIn("[ ] 1: buy milk", lines[0])
        self.assertIn("[ ] 2: walk dog", lines[1])

    def test_list_shows_done_items(self):
        self.run_todo("add", "buy milk")
        self.run_todo("done", "1")
        r = self.run_todo("list")
        self.assertIn("[x] 1:", r.stdout)
        self.assertIn("buy milk", r.stdout)

    # --- done ---

    def test_done_marks_complete(self):
        self.run_todo("add", "buy milk")
        r = self.run_todo("done", "1")
        self.assertEqual(r.returncode, 0)
        self.assertEqual(r.stdout.strip(), "Done: buy milk")
        todos = self.load_todos()
        self.assertTrue(todos[0]["done"])

    def test_done_invalid_id(self):
        r = self.run_todo("done", "99")
        self.assertEqual(r.returncode, 1)
        self.assertIn("No todo with ID 99", r.stdout.strip() + r.stderr.strip())

    # --- remove ---

    def test_remove_deletes_todo(self):
        self.run_todo("add", "buy milk")
        r = self.run_todo("remove", "1")
        self.assertEqual(r.returncode, 0)
        self.assertEqual(r.stdout.strip(), "Removed: buy milk")
        todos = self.load_todos()
        self.assertEqual(len(todos), 0)

    def test_remove_invalid_id(self):
        r = self.run_todo("remove", "42")
        self.assertEqual(r.returncode, 1)
        self.assertIn("No todo with ID 42", r.stdout.strip() + r.stderr.strip())

    # --- id auto-increment ---

    def test_id_after_removal(self):
        """max existing ID + 1: after removing id=2, max is 1, so next is 2."""
        self.run_todo("add", "first")
        self.run_todo("add", "second")
        self.run_todo("remove", "2")
        self.run_todo("add", "third")
        todos = self.load_todos()
        ids = [t["id"] for t in todos]
        self.assertEqual(ids, [1, 2])


if __name__ == "__main__":
    unittest.main()
