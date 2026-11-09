"""Run with python3 modules/desktop/hyprland/tests/wallch.py."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "config/scripts/wallch.sh"


class WallpaperTest(unittest.TestCase):
    def test_selection_and_retention(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            walls = root / "walls"
            state = root / "state/wallch"
            binaries = root / "bin"
            for folder in (walls, state, binaries):
                folder.mkdir(parents=True)
            for name, body in {
                "pgrep": "exit 1",
                "awww": 'if [[ "$1" == img ]]; then\n'
                '  [[ "${FAIL_IMAGE:-0}" == 0 ]] || exit 1\n'
                '  printf "%s\\0" "$2" > "$WALL_LOG"\nfi',
                "hyprctl": 'echo "Monitor eDP-1"',
                "mpvpaper": 'printf "%s\\0" "$4" > "$WALL_LOG"',
            }.items():
                stub = binaries / name
                stub.write_text("#!/usr/bin/env bash\n" + body + "\n")
                stub.chmod(0o755)
            env = dict(os.environ, HOME=str(root), XDG_STATE_HOME=str(root / "state"),
                       wallpaper_path=str(walls), WALL_LOG=str(root / "displayed"),
                       PATH=str(binaries) + os.pathsep + os.environ["PATH"])
            first = walls / "b forest.jpg"
            second = walls / "c lake\n.png"
            first.touch()
            second.touch()
            saved = state / "current_wallpaper"

            def run(*args, success=True):
                result = subprocess.run(["bash", str(SCRIPT), *args], env=env,
                                        capture_output=True)
                self.assertEqual(result.returncode == 0, success, result.stderr)

            def selected(path):
                expected = os.fsencode(path) + b"\0"
                self.assertEqual(saved.read_bytes(), expected)
                self.assertEqual((root / "displayed").read_bytes(), expected)

            run("--restore")
            selected(first)
            run()
            selected(second)
            run("--restore")
            selected(second)
            (walls / "a new.jpg").touch()
            run("--restore")
            selected(second)
            run()
            selected(walls / "a new.jpg")
            (walls / "a new.jpg").unlink()
            run("--restore")
            selected(first)

            env["FAIL_IMAGE"] = "1"
            run(success=False)
            selected(first)
            del env["FAIL_IMAGE"]
            run("--invalid", success=False)
            selected(first)

            for legacy in (state / "wallpaper_index", root / ".config/hypr/wallpaper_index"):
                saved.unlink()
                legacy.parent.mkdir(parents=True, exist_ok=True)
                legacy.write_text("01\n")
                run("--restore")
                selected(second)
                legacy.unlink()
            saved.unlink()
            (state / "wallpaper_index").write_text("invalid\n")
            run("--restore")
            selected(first)

            video = walls / "d video.mp4"
            video.touch()
            run()
            selected(second)
            run()
            selected(video)
            run("--restore")
            selected(video)


if __name__ == "__main__":
    unittest.main()
