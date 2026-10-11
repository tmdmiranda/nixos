#!/usr/bin/env python3
"""Waybar status and GTK slider control for Linuwu-Sense fans."""

import glob
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path


FAN_SPEED_PATHS = (
    Path("/sys/devices/platform/acer-wmi/nitro_sense/fan_speed"),
    Path(
        "/sys/module/linuwu_sense/drivers/platform:acer-wmi/"
        "acer-wmi/nitro_sense/fan_speed"
    ),
)


def fan_speed_path():
    return next((path for path in FAN_SPEED_PATHS if path.is_file()), None)


def read_settings():
    path = fan_speed_path()
    if path is None:
        return None

    try:
        contents = path.read_text()
    except OSError:
        return None

    match = re.fullmatch(r"\s*(\d+)\s*,\s*(\d+)\s*", contents)
    if not match:
        return None
    return int(match.group(1)), int(match.group(2))


def read_rpms():
    for hwmon in sorted(glob.glob("/sys/class/hwmon/hwmon*")):
        try:
            name = Path(hwmon, "name").read_text().strip().lower()
        except OSError:
            continue

        if name not in {"acer", "linuwu_sense"}:
            continue

        values = []
        for sensor in ("fan1_input", "fan2_input"):
            try:
                values.append(int(Path(hwmon, sensor).read_text().strip()))
            except (OSError, ValueError):
                values.append(None)
        return values

    return [None, None]


def fan_description(name, target, rpm):
    actual = f"{rpm} RPM" if rpm is not None else "RPM unavailable"
    mode = "auto" if target == 0 else f"target {target}%"
    return f"{name}: {actual} ({mode})"


def status():
    settings = read_settings()
    rpms = read_rpms()

    if settings is None:
        payload = {
            "text": "N/A",
            "tooltip": "Linuwu-Sense Nitro fan control was not found.",
            "class": "unavailable",
        }
    else:
        cpu, gpu = settings
        if cpu == 0 and gpu == 0:
            text = (
                f"{rpms[0]}/{rpms[1]} RPM"
                if rpms[0] is not None and rpms[1] is not None
                else "AUTO"
            )
            css_class = "auto"
        elif cpu == gpu:
            text = f"{cpu}%"
            css_class = "manual"
        else:
            cpu_text = "AUTO" if cpu == 0 else str(cpu)
            gpu_text = "AUTO" if gpu == 0 else str(gpu)
            text = f"{cpu_text}/{gpu_text}%"
            css_class = "mixed"

        tooltip = "\n".join(
            (
                fan_description("CPU fan", cpu, rpms[0]),
                fan_description("GPU fan", gpu, rpms[1]),
                "Click to change fan control.",
            )
        )
        payload = {"text": text, "tooltip": tooltip, "class": css_class}

    print(json.dumps(payload))


def show_message(message, error=False):
    style = Path(__file__).with_name("fan-control.css")
    mode = "--error" if error else "--info"
    try:
        subprocess.run(
            [
                "yad",
                mode,
                "--title=Fan control",
                f"--text={message}",
                "--center",
                "--on-top",
                "--button=Close:0",
                f"--css={style}",
            ],
            check=False,
        )
    except FileNotFoundError:
        print(f"fan-speed: {message}", file=sys.stderr)


def control_dialog(cpu, gpu, rpms):
    current_cpu = f"{cpu}%" if cpu else "Auto"
    current_gpu = f"{gpu}%" if gpu else "Auto"
    cpu_rpm = f"{rpms[0]} RPM" if rpms[0] is not None else "RPM unavailable"
    gpu_rpm = f"{rpms[1]} RPM" if rpms[1] is not None else "RPM unavailable"
    text = (
        f"CPU  {cpu_rpm}  ·  {current_cpu}\n"
        f"GPU  {gpu_rpm}  ·  {current_gpu}\n\n"
        "Drag either slider, then Apply. Set a slider to 0 for firmware auto."
    )
    style = Path(__file__).with_name("fan-control.css")
    slider_cpu = cpu
    slider_gpu = gpu

    try:
        return subprocess.run(
            [
                "yad",
                "--form",
                "--title=Fan control",
                f"--text={text}",
                "--width=440",
                "--fixed",
                "--undecorated",
                "--on-top",
                "--skip-taskbar",
                "--class=acer-fan-control",
                "--name=acer-fan-control",
                "--separator=|",
                "--buttons-layout=end",
                "--button=Apply:0",
                "--button=Auto:10",
                "--button=Cancel:1",
                "--field=CPU fan % (0 = Auto):SCL",
                str(slider_cpu),
                "--field=GPU fan % (0 = Auto):SCL",
                str(slider_gpu),
                f"--css={style}",
            ],
            text=True,
            capture_output=True,
            env={**os.environ, "GDK_BACKEND": "x11"},
            check=False,
        )
    except FileNotFoundError:
        show_message("YAD is required for the fan slider. Install the 'yad' package.", error=True)
        return None


def apply(cpu, gpu):
    if not (0 <= cpu <= 100 and 0 <= gpu <= 100):
        raise ValueError("fan speeds must be between 0 and 100")

    if os.geteuid() != 0:
        raise PermissionError("fan settings can only be written by the privileged helper")

    path = fan_speed_path()
    if path is None:
        raise FileNotFoundError("Linuwu-Sense Nitro fan_speed sysfs node was not found")
    path.write_text(f"{cpu},{gpu}\n")


def apply_with_auth(cpu, gpu):
    helper = Path("/run/current-system/sw/bin/acer-nitro-fan-set")
    if helper.is_file() and shutil.which("sudo"):
        try:
            helper = helper.resolve(strict=True)
            result = subprocess.run(
                ["sudo", "-n", str(helper), str(cpu), str(gpu)],
                text=True,
                capture_output=True,
                check=False,
            )
        except OSError as error:
            show_message(f"Could not run the passwordless fan helper: {error}", error=True)
            return False

        if result.returncode == 0:
            return True

        detail = result.stderr.strip() or "The passwordless fan helper failed."
        show_message(detail, error=True)
        return False

    script = str(Path(__file__).resolve())
    try:
        result = subprocess.run(
            ["pkexec", "--disable-internal-agent", script, "--apply", str(cpu), str(gpu)],
            text=True,
            capture_output=True,
            check=False,
        )
    except FileNotFoundError:
        show_message("pkexec is not installed; fan settings were not changed.", error=True)
        return False

    if result.returncode == 0:
        return True

    detail = result.stderr.strip()
    if not detail:
        detail = "Authentication was cancelled or the fan setting could not be written."
    show_message(detail, error=True)
    return False


def menu():
    settings = read_settings()
    if settings is None:
        print("fan-speed: Linuwu-Sense fan control was not found", file=sys.stderr)
        return

    cpu, gpu = settings
    result = control_dialog(cpu, gpu, read_rpms())
    if result is None:
        return
    if result.returncode == 10:
        apply_with_auth(0, 0)
        return
    if result.returncode == 1:
        if result.stderr.strip():
            show_message(result.stderr.strip(), error=True)
        return
    if result.returncode != 0:
        detail = result.stderr.strip() or f"The slider dialog exited with code {result.returncode}."
        show_message(detail, error=True)
        return

    values = result.stdout.strip().split("|")
    if len(values) < 2:
        show_message("Could not read the selected fan speeds. Nothing was changed.", error=True)
        return
    try:
        new_cpu, new_gpu = int(values[0]), int(values[1])
    except ValueError:
        show_message("The selected fan speeds were invalid. Nothing was changed.", error=True)
        return
    apply_with_auth(new_cpu, new_gpu)


def main(argv):
    if argv == ["--status"]:
        status()
        return 0
    if argv == ["--menu"]:
        menu()
        return 0
    if len(argv) == 3 and argv[0] == "--apply":
        try:
            cpu, gpu = int(argv[1]), int(argv[2])
            apply(cpu, gpu)
        except (ValueError, OSError, PermissionError) as error:
            print(f"fan-speed: {error}", file=sys.stderr)
            return 1
        return 0

    print(f"Usage: {Path(sys.argv[0]).name} --status|--menu|--apply CPU GPU", file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
