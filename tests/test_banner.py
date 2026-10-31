#!/usr/bin/env python3
"""Check interactive banner styling and once-per-session output on a PTY."""

import errno
import os
from pathlib import Path
import pty
import re
import subprocess
import tempfile
import unittest


class BannerTests(unittest.TestCase):
    def capture(self, mode="minimal", **overrides):
        script = Path(__file__).resolve().parents[1] / "custom_bash_commands.sh"
        with tempfile.TemporaryDirectory(prefix="cbc-banner-") as directory:
            home = Path(directory)
            config = home / ".config/cbc"
            config.mkdir(parents=True)
            (config / "cbc.config").write_text(
                f"CBC_BANNER_MODE={mode}\nCBC_SOURCE_BASH_ALIASES=false\n"
            )
            (home / ".cbc_aliases.sh").write_text("")
            env = os.environ.copy()
            for key in list(env):
                if key.startswith(("CBC_", "BASH_FUNC_")) or key in (
                    "BASH_ENV", "ENV", "NO_COLOR", "CLICOLOR",
                    "CLICOLOR_FORCE", "SHELLOPTS", "BASHOPTS"
                ):
                    env.pop(key)
            env.update(HOME=directory, TERM="xterm-256color")
            env.update(overrides)
            master, slave = pty.openpty()
            try:
                process = subprocess.Popen(
                    ["bash", "--noprofile", "--norc", "-ic",
                     # A function makes Gum availability deterministic while
                     # failing loudly if the ordinary banner launches it.
                     'gum() { return 99; }; source "$1"; source "$1"',
                     "_", str(script)],
                    stdout=slave, stderr=subprocess.DEVNULL, env=env,
                )
                os.close(slave)
                slave = None
                output = bytearray()
                while True:
                    try:
                        chunk = os.read(master, 65536)
                    except OSError as error:
                        if error.errno == errno.EIO:
                            break
                        raise
                    if not chunk:
                        break
                    output.extend(chunk)
                self.assertEqual(process.wait(timeout=10), 0)
                return output.decode()
            finally:
                os.close(master)
                if slave is not None:
                    os.close(slave)

    def test_minimal_once_with_ansi_yellow(self):
        output = self.capture()
        self.assertEqual(len(re.findall(r"v\d+\.\d+\.\d+", output)), 1)
        self.assertIn("\x1b[33m", output)
        self.assertNotIn("CUSTOM BASH COMMANDS", output)

    def test_full_once_with_both_colors(self):
        output = self.capture(mode="full")
        self.assertEqual(output.count("CUSTOM BASH COMMANDS"), 1)
        self.assertEqual(output.count("CHANGELOG:"), 1)
        self.assertIn("\x1b[32m", output)
        self.assertIn("\x1b[33m", output)

    def test_color_controls(self):
        self.assertNotIn("\x1b[", self.capture(NO_COLOR="1"))
        self.assertNotIn("\x1b[", self.capture(CLICOLOR="0"))
        self.assertNotIn("\x1b[", self.capture(TERM="dumb"))
        self.assertIn("\x1b[33m", self.capture(
            TERM="dumb", CLICOLOR_FORCE="1"
        ))


if __name__ == "__main__":
    unittest.main()
