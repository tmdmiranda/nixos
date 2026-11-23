import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "config/scripts/wallpiper.sh"


class StartupTest(unittest.TestCase):
    def test_login_wait_and_offline_fallback(self):
        for ready, disconnected in ((True, False), (False, False), (True, True)):
            with self.subTest(ready=ready, disconnected=disconnected), tempfile.TemporaryDirectory() as folder:
                root = Path(folder)
                bins = root / "bin"
                bins.mkdir()
                log = root / ".local/share/Steam/logs/connection_log.txt"
                log.parent.mkdir(parents=True)
                log.write_text("[Logged On, 4, 7] old session\n")
                os.utime(log, (1, 1))
                for name, body in {
                    "pgrep": 'test -f "$HOME/running"',
                    "nvidia-offload": 'exec "$@"',
                    "steam": 'printf "%s\\n" "$@" > "$HOME/args"\ntouch "$HOME/running"',
                    "sleep": 'n=$(cat "$HOME/waits" 2>/dev/null || echo 0)\n'
                    'echo "$((n+1))" > "$HOME/waits"\n'
                    'if [[ "$READY" == 1 && "$n" == 2 ]]; then\n'
                    '  echo "[Logged On, 4, 7] new session" > "$LOG"\n'
                    '  if [[ "$DISCONNECTED" == 1 ]]; then\n'
                    '    echo "[Disconnected, 4, 7] connection lost" >> "$LOG"\nfi\n'
                    '  echo "CClientJobGetClientUpdateHosts: cached version not expired" >> "$LOG"\nfi',
                    "wallpiperd": 'printf "%s\\n" "$WALLPIPER_CAPTURE_RENDER_NODE" '
                    '"$WALLPIPER_PROTON_BIN" > "$HOME/launched"',
                }.items():
                    stub = bins / name
                    stub.write_text("#!/usr/bin/env bash\n" + body + "\n")
                    stub.chmod(0o755)
                env = dict(os.environ, HOME=str(root), LOG=str(log), READY=str(int(ready)),
                           DISCONNECTED=str(int(disconnected)),
                           PATH=str(bins) + os.pathsep + os.environ["PATH"])
                result = subprocess.run(["bash", str(SCRIPT)], env=env,
                                        capture_output=True, timeout=10)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual((root / "args").read_text(), "-silent\n")
                self.assertEqual(int((root / "waits").read_text()), 3 if ready and not disconnected else 30)
                self.assertEqual((root / "launched").read_text().splitlines(), [
                    "226:128",
                    str(root / ".local/share/Steam/compatibilitytools.d/GE-Proton11-6-x86_64/proton"),
                ])


if __name__ == "__main__":
    unittest.main()
