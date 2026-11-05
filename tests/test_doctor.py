#!/usr/bin/env python3
"""Run from the repository root: python3 tests/test_doctor.py."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
TOOLS = (
    "bash git curl sed awk sha256sum find sort xargs man xdg-open setsid "
    "gum fzf bat eza imv-x11 nvim wl-copy"
).split()


class DoctorTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        config = self.home / "config"
        config.mkdir()
        (self.home / "modules").mkdir()
        (self.home / ".cbc_aliases.sh").touch()
        (self.home / ".custom_bash_commands.sh").touch()
        (config / "cbc.config").write_text(
            "CBC_SHOW_BANNER=false\nCBC_USE_GUM=false\n"
            "CBC_SOURCE_BASH_ALIASES=false\n"
        )
        self.env = {
            **os.environ,
            "HOME": str(self.home),
            "CBC_CONFIG_DIR": str(config),
            "CBC_CONFIG_FILE": str(config / "cbc.config"),
            "CBC_MODULE_ROOT": str(self.home / "modules"),
            "CBC_PACKAGE_MANIFEST": str(self.home / "packages.toml"),
            "CBC_OMARCHY_COLORS_FILE": "",
            "REPO_SCRIPT": str(ROOT / "custom_bash_commands.sh"),
        }

    def run_shell(self, body, setup=""):
        # Real text utilities are used; discovery and network are deterministic.
        script = r'''
source "$REPO_SCRIPT" >/dev/null
command() {
  if [[ "$1" == -v ]]; then
    if [[ " $MISSING " == *" $2 "* ]]; then return 1; fi
    case " $FIXTURE_TOOLS " in
    *" $2 "*) printf '/fixture/%s\n' "$2"; return 0 ;;
    esac
  fi
  builtin command "$@"
}
curl() {
  if [[ "$NETWORK_FAIL" == true ]]; then
    printf '%s\n503' '{"message":"service unavailable"}'
  else
    printf '%s\n200' '{"tag_name":"v9.8.7"}'
  fi
}
git() {
  [[ "$NETWORK_FAIL" == true ]] && return 1
  printf 'abc123\tHEAD\n'
}
gum() { printf '\033[31mGUM SHOULD NOT RENDER JSON\033[0m\n'; }
'''
        return subprocess.run(
            ["bash", "--noprofile", "--norc", "-c", script + setup + body],
            env={
                **self.env,
                "FIXTURE_TOOLS": " ".join(TOOLS),
                "MISSING": "",
                "NETWORK_FAIL": "false",
            },
            capture_output=True,
            text=True,
            timeout=20,
        )

    def document(self, result, status=0):
        self.assertEqual(result.returncode, status, result.stderr)
        self.assertEqual(result.stderr, "")
        self.assertNotIn("\x1b", result.stdout)
        data = json.loads(result.stdout)
        # Require readable two-space indentation at every nesting level.
        # Use parsed values so equivalent JSON string escapes are allowed.
        expected = json.dumps(data, indent=2, ensure_ascii=False)
        self.assertEqual(
            [len(line) - len(line.lstrip())
             for line in result.stdout.splitlines()],
            [len(line) - len(line.lstrip())
             for line in expected.splitlines()],
        )
        self.assertTrue(result.stdout.endswith("\n"))
        self.assertEqual(data["schema_version"], 2)
        self.assertTrue(data["context"]["version"].startswith("v"))
        self.assertNotIn("checks", data)
        self.assertEqual(data["summary"]["exit_status"], status)
        checks = self.checks(data)
        self.assertEqual(len({c["id"] for c in checks}), len(checks))
        self.assertEqual(data["summary"]["counts"], self.counts(checks))
        self.assertEqual(data["summary"]["status"], self.overall(checks))
        for section in data["sections"].values():
            self.assertTrue(section["title"])
            self.assertEqual(section["counts"], self.counts(section["checks"]))
            self.assertEqual(section["status"], self.overall(section["checks"]))
            for check in section["checks"]:
                self.assertIsInstance(check["data"], dict)
        for advice in data["recommendations"]:
            self.assertIn(advice["check_id"], {c["id"] for c in checks})
            self.assertTrue(advice["message"])
        return data

    @staticmethod
    def checks(data):
        return [check for section in data["sections"].values()
                for check in section["checks"]]

    @staticmethod
    def counts(checks):
        return {s: sum(c["status"] == s for c in checks)
                for s in ("OK", "WARN", "FAIL", "skipped")}

    @staticmethod
    def overall(checks):
        for status in ("FAIL", "WARN", "OK"):
            if any(c["status"] == status for c in checks):
                return status
        return "skipped"

    def test_success_and_totals(self):
        data = self.document(self.run_shell("cbc doctor --json"))
        self.assertEqual(data["command"], "cbc doctor")
        self.assertEqual(data["summary"]["status"], "OK")
        self.assertEqual(
            data["context"]["config_file"], self.env["CBC_CONFIG_FILE"]
        )
        checks = self.checks(data)
        self.assertEqual(
            set(data["sections"]),
            {"dependencies", "files", "modules", "network"},
        )
        self.assertEqual(sum(data["summary"]["counts"].values()), len(checks))
        self.assertEqual(data["recommendations"], [])
        by_id = {c["id"]: c for c in checks}
        self.assertEqual(by_id["dependency:curl"]["data"], {
            "command": "curl", "required": True, "available": True,
            "resolved_path": "/fixture/curl",
        })
        self.assertEqual(
            by_id["network:GitHub API"]["data"]["http_status"], 200
        )
        self.assertEqual(
            by_id["network:GitHub API"]["data"]["release_tag"], "v9.8.7"
        )
        self.assertEqual(by_id["network:GitHub git"]["data"]["head"], "abc123")

    def test_optional_warning_and_required_failure(self):
        warning = self.document(self.run_shell(
            "cbc doctor --json", "MISSING=gum\n"
        ))
        self.assertEqual(warning["summary"]["status"], "WARN")
        self.assertEqual(warning["summary"]["counts"]["WARN"], 1)
        self.assertEqual(
            warning["recommendations"][0]["check_id"], "dependency:gum"
        )
        failure = self.document(self.run_shell(
            "cbc doctor --json", "MISSING='gum curl git'\nCBC_USE_GUM=true\n"
        ), 1)
        self.assertEqual(failure["summary"]["status"], "FAIL")
        self.assertEqual(failure["summary"]["counts"]["FAIL"], 5)
        by_id = {c["id"]: c for c in self.checks(failure)}
        self.assertEqual(by_id["dependency:curl"]["data"], {
            "command": "curl", "required": True, "available": False,
            "resolved_path": None,
        })
        for name in ("GitHub API", "GitHub git"):
            self.assertFalse(by_id[f"network:{name}"]["data"]["attempted"])
            self.assertEqual(
                by_id[f"network:{name}"]["data"]["reason"], "dependency_missing"
            )

    def test_network_failure(self):
        data = self.document(self.run_shell(
            "cbc doctor --json", "NETWORK_FAIL=true\n"
        ), 1)
        checks = {c["id"]: c for c in self.checks(data)}
        self.assertEqual(data["summary"]["counts"]["FAIL"], 2)
        self.assertEqual(checks["network:GitHub API"]["status"], "FAIL")
        self.assertEqual(
            checks["network:GitHub API"]["detail"],
            "http 503: service unavailable",
        )
        self.assertTrue(checks["network:GitHub API"]["data"]["attempted"])
        self.assertEqual(
            checks["network:GitHub API"]["data"]["http_status"], 503
        )
        self.assertIsNone(checks["network:GitHub API"]["data"]["release_tag"])

    def test_json_without_external_tools(self):
        data = self.document(self.run_shell(
            "cbc doctor --json",
            'MISSING="$FIXTURE_TOOLS"\nPATH=/nonexistent\n',
        ), 1)
        self.assertEqual(data["summary"]["status"], "FAIL")
        self.assertEqual(data["summary"]["counts"]["FAIL"], 20)

    def test_network_unknowns_are_null(self):
        for payload, status, expected in (
            ("\\n000", 1, "FAIL"), ("{}\\n200", 0, "WARN"),
        ):
            with self.subTest(payload=payload):
                data = self.document(self.run_shell(
                    "cbc doctor --json",
                    f"curl() {{ printf '{payload}'; }}\n",
                ), status)
                api = data["sections"]["network"]["checks"][0]
                self.assertEqual(api["status"], expected)
                self.assertTrue(api["data"]["attempted"])
                self.assertIsNone(api["data"]["release_tag"])
                if status:
                    self.assertIsNone(api["data"]["http_status"])

    def test_manifest_module_states(self):
        self.env["CBC_PACKAGE_MANIFEST"] = str(self.home / "packages.toml")
        (self.home / "packages.toml").write_text(
            '[[module.deps]]\nuse = "author/ready"\n'
            '[[module.deps]]\nuse = "author/broken"\n'
            '[[module.deps]]\nuse = "author/absent"\n'
        )
        for name in ("ready", "broken"):
            (self.home / "modules" / name).mkdir()
        (self.home / "modules" / "ready" / "cbc-module.sh").touch()
        data = self.document(self.run_shell("cbc doctor --json"))
        section = data["sections"]["modules"]
        checks = {c["id"]: c for c in section["checks"]}
        for name, installed, entrypoint in (
            ("ready", True, True), ("broken", True, False),
            ("absent", False, False),
        ):
            facts = checks[f"module:Module {name}"]["data"]
            self.assertIs(facts["tracked"], True)
            self.assertIs(facts["installed"], installed)
            self.assertIs(facts["entrypoint_present"], entrypoint)
            self.assertEqual(facts["source"], f"author/{name}")
        self.assertEqual(section["counts"]["WARN"], 2)
        self.assertEqual(data["summary"]["status"], "WARN")
        self.assertEqual(len(data["recommendations"]), 2)

    def test_disabled_file_check_is_not_a_presence_observation(self):
        data = self.document(self.run_shell("cbc doctor --json"))
        checks = {c["id"]: c for c in self.checks(data)}
        aliases = checks["file:Bash aliases"]
        self.assertFalse(aliases["data"]["enabled"])
        self.assertIsNone(aliases["data"]["present"])
        self.assertEqual(aliases["status"], "OK")

    def test_missing_files_and_module_names_are_escaped(self):
        name = 'quoted" slash\\ café\tline\nend'
        (self.home / "modules" / name).mkdir()
        (self.home / ".custom_bash_commands.sh").unlink()
        data = self.document(self.run_shell("cbc doctor --json"), 1)
        checks = {c["id"]: c for c in self.checks(data)}
        self.assertEqual(checks["file:Main script"]["status"], "FAIL")
        self.assertEqual(
            checks[f"module:Module {name}"]["label"], f"Module {name}"
        )
        module = checks[f"module:Module {name}"]["data"]
        self.assertEqual(module["name"], name)
        self.assertEqual(module["path"], str(self.home / "modules" / name))
        self.assertFalse(module["tracked"])
        self.assertTrue(module["installed"])
        self.assertFalse(module["entrypoint_present"])
        self.assertEqual(
            checks["file:Main script"]["data"]["path"],
            str(self.home / ".custom_bash_commands.sh"),
        )

    def test_serializer_all_control_characters_and_unicode(self):
        result = self.run_shell(r'''
value=$'"\\ café'
for ((i=1; i<32; i++)); do
  printf -v octal '%03o' "$i"
  printf -v char '%b' "\\$octal"
  value+="$char"
done
cbc_doctor_json_string "$value"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            json.loads(result.stdout), '"\\ café' + ''.join(
                chr(i) for i in range(1, 32)
            )
        )

    def test_startup_types_and_skipped_banner(self):
        data = self.document(self.run_shell("cbc doctor startup --json"))
        self.assertEqual(data["command"], "cbc doctor startup")
        self.assertEqual(set(data["sections"]), {
            "shell", "configuration", "modules", "theme", "banner",
        })
        checks = {c["id"]: c for c in self.checks(data)}
        modules = checks["startup:module"]["data"]
        self.assertEqual(modules["installed"], 0)
        self.assertEqual(modules["entrypoints"], 0)
        settings = checks["startup:config"]["data"]["settings"]
        self.assertIs(settings["CBC_SHOW_BANNER"], False)
        self.assertEqual(settings["CBC_USE_GUM"], "false")
        self.assertEqual(checks["startup:banner"]["status"], "skipped")
        self.assertIsNone(checks["startup:banner"]["data"]["duration_us"])
        self.assertIsNone(checks["startup:banner"]["data"]["exit_status"])
        self.assertEqual(data["summary"]["counts"]["skipped"], 1)
        for step, check in checks.items():
            if step == "startup:banner":
                continue
            measurement = check["data"]
            self.assertIs(type(measurement["duration_us"]), int)
            self.assertGreaterEqual(measurement["duration_us"], 0)
            self.assertEqual(check["status"], "OK")
            self.assertEqual(measurement["exit_status"], 0)

    def test_json_bypasses_active_styling(self):
        setup = r'''
CBC_GUM_ACTIVE=true
CBC_USE_GUM=true
cbc_style_box() { printf 'unexpected styling\n'; return 2; }
cbc_style_message() { printf 'unexpected styling\n'; return 2; }
'''
        for args in ("--json", "startup --json"):
            with self.subTest(args=args):
                self.document(self.run_shell(f"cbc doctor {args}", setup))

    def test_startup_failures_and_noisy_steps(self):
        setup = r'''
CBC_SHOW_BANNER=true
cbc_config_load() { printf 'config noise\n'; return 7; }
cbc_pkg_source_modules() { printf 'module noise\n'; return 9; }
display_version() { printf 'banner noise\n'; return 4; }
'''
        data = self.document(self.run_shell(
            "cbc doctor --json startup", setup
        ))
        checks = {c["id"]: c for c in self.checks(data)}
        self.assertEqual(data["summary"]["status"], "FAIL")
        self.assertEqual(data["summary"]["counts"]["FAIL"], 3)
        advice_ids = {a["check_id"] for a in data["recommendations"]}
        for step, status in (("config", 7), ("module", 9), ("banner", 4)):
            check = checks[f"startup:{step}"]
            self.assertEqual(check["status"], "FAIL")
            self.assertEqual(check["data"]["exit_status"], status)
            self.assertIn(check["id"], advice_ids)

    def test_startup_missing_config_and_installed_modules(self):
        Path(self.env["CBC_CONFIG_FILE"]).unlink()
        for name in ("ready", "missing-entrypoint"):
            (self.home / "modules" / name).mkdir()
        (self.home / "modules" / "ready" / "cbc-module.sh").touch()
        data = self.document(self.run_shell("cbc doctor startup --json"))
        checks = {c["id"]: c for c in self.checks(data)}
        self.assertIs(checks["startup:config"]["data"]["present"], False)
        self.assertEqual(checks["startup:module"]["data"]["installed"], 2)
        self.assertEqual(checks["startup:module"]["data"]["entrypoints"], 1)

    def test_slow_startup_advice_does_not_fail_successful_steps(self):
        setup = r'''
CBC_SHOW_BANNER=true
cbc_doctor_time_call() {
  local measured=1000
  case "$1" in
  module_us|banner_us) measured=60000 ;;
  fresh_interactive_us) measured=250000 ;;
  esac
  printf -v "$1" '%d' "$measured"
}
'''
        data = self.document(self.run_shell("cbc doctor startup --json", setup))
        self.assertEqual(data["summary"]["status"], "OK")
        self.assertEqual(data["summary"]["counts"]["OK"], 7)
        self.assertEqual(
            {a["check_id"] for a in data["recommendations"]},
            {"startup:fresh_interactive", "startup:module", "startup:banner"},
        )

    def test_reports_do_not_retain_previous_checks_or_advice(self):
        result = self.run_shell(
            "MISSING=curl\ncbc doctor --json\n"
            "MISSING=''\ncbc doctor --json\n"
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        decoder = json.JSONDecoder()
        first, end = decoder.raw_decode(result.stdout)
        second = json.loads(result.stdout[end:])
        self.assertTrue(first["recommendations"])
        self.assertEqual(second["recommendations"], [])
        self.assertEqual(second["summary"]["counts"]["FAIL"], 0)
        self.assertEqual(len(self.checks(first)), len(self.checks(second)))

    def test_argument_errors_have_empty_stdout(self):
        for args in (
            "--json --bogus", "--bogus --json", "startup --json extra",
            "--json startup startup", "--json -- extra",
        ):
            with self.subTest(args=args):
                result = self.run_shell(f"cbc doctor {args}")
                self.assertEqual(result.returncode, 1)
                self.assertEqual(result.stdout, "")
                self.assertIn("Error:", result.stderr)

    def test_help_and_human_output(self):
        for args in ("--json -h", "startup --json -h"):
            result = self.run_shell(f"cbc doctor {args}")
            self.assertEqual(result.returncode, 0)
            self.assertIn("--json", result.stdout)
        for args, title in (("", "Summary"), ("startup", "Startup Summary")):
            result = self.run_shell(f"cbc doctor {args}")
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(title, result.stdout)


if __name__ == "__main__":
    unittest.main()
