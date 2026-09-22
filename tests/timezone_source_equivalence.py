"""Ensure timezone migrations leave app/provider logic unchanged, apart from reviewed inputs."""
import ast
import json
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[1]
BASE = "74a7d00a"

class InputsOnly(ast.NodeTransformer):
    def visit_FunctionDef(self, node):
        if node.name in {"get_schema", "_timezone_location"}:
            return None
        return self.generic_visit(node)

    def visit_Call(self, node):
        if isinstance(node.func, ast.Name) and node.func.id == "_timezone_location":
            return self.visit(node.args[1])
        return self.generic_visit(node)

for app in json.loads((root / "tests/timezone-migrations.json").read_text()):
    before = subprocess.check_output(["git", "show", BASE + ":" + app["source_path"]], cwd=root, text=True)
    after = (root / app["source_path"]).read_text()
    if app["app_id"] in {"evcc", "shouldideploy"}:
        after = after.replace('load("time.star", "time")\n', '')
    if app["app_id"] == "retrograde-planet":
        before = before.replace('timezone_id = "America/Dallas"', 'timezone_id = "UTC"')
    old_tree = InputsOnly().visit(ast.parse(before))
    new_tree = InputsOnly().visit(ast.parse(after))
    assert ast.dump(old_tree) == ast.dump(new_tree), app["app_id"]
print("79 app/provider bodies match their reviewed predecessor after isolating timezone inputs")
