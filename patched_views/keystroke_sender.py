#
# Sends keystrokes via the tweaker_keystroke_server background daemon.
#
# FL Studio's subinterpreter blocks most I/O, but the config loader
# successfully reads files using open() from the script directory.
# Key insight: the file path matters — try writing to the script dir
# and also try reading the server PID from a config-adjacent file.
#
import os
import json
import signal

# Paths relative to the script directory (where FL Studio CAN read files)
_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_PARENT_DIR = os.path.dirname(_SCRIPT_DIR)
_CMD_FILE_LOCAL = os.path.join(_PARENT_DIR, "keystroke_cmd")
_CMD_FILE_HOME = os.path.expanduser("~/.tweaker/keystroke_cmd")
_PID_FILE = os.path.expanduser("~/.tweaker/keystroke_server.pid")
_CONFIG_PATH = os.path.join(_PARENT_DIR, "tweaker_config.json")

_pending = []
_server_pid = None

# Try reading server PID at load time — test different methods
def _read_pid():
    """Try multiple ways to read the server PID."""
    pid = None

    # Method 1: read from PID file directly
    try:
        with open(_PID_FILE, "r") as f:
            pid = int(f.read().strip())
        print("[Tweaker] PID from pid file: %d" % pid)
        return pid
    except Exception as e:
        print("[Tweaker] PID file open failed: %s" % e)

    # Method 2: read PID from tweaker_config.json (we know config reads work)
    try:
        with open(_CONFIG_PATH, "r") as f:
            cfg = json.load(f)
        pid = cfg.get("keystroke_server_pid")
        if pid:
            print("[Tweaker] PID from config: %d" % pid)
            return int(pid)
        else:
            print("[Tweaker] no PID in config")
    except Exception as e:
        print("[Tweaker] config read for PID failed: %s" % e)

    return None

_server_pid = _read_pid()


def send_keystroke(key, modifiers=None):
    """Queue a keystroke command."""
    key_lower = key.lower()
    if modifiers:
        mod_str = ",".join(m.lower() for m in modifiers if m)
        line = "%s %s" % (key_lower, mod_str) if mod_str else key_lower
    else:
        line = key_lower
    _pending.append(line)
    print("[Tweaker] keystroke queued: %s" % line)


def flush_pending():
    """Flush pending keystrokes. Called from OnIdle/TimerEvent."""
    if not _pending:
        return

    lines = list(_pending)
    _pending.clear()

    for line in lines:
        written = False

        # Method 1: write to script directory (where config reads work)
        try:
            with open(_CMD_FILE_LOCAL, "a") as f:
                f.write(line + "\n")
            written = True
            print("[Tweaker] wrote to script dir via open()")
        except Exception as e:
            print("[Tweaker] script dir write failed: %s" % e)

        # Method 2: write to ~/.tweaker/
        if not written:
            try:
                with open(_CMD_FILE_HOME, "a") as f:
                    f.write(line + "\n")
                written = True
                print("[Tweaker] wrote to home dir via open()")
            except Exception as e:
                print("[Tweaker] home dir write failed: %s" % e)

        # Method 3: os.system
        if not written:
            r1 = os.system("echo '%s' >> %s" % (line, _CMD_FILE_LOCAL))
            r2 = os.system("echo '%s' >> %s" % (line, _CMD_FILE_HOME))
            print("[Tweaker] os.system returned: local=%s home=%s" % (r1, r2))

        # Method 4: signal the server (if we have PID)
        if _server_pid:
            try:
                os.kill(_server_pid, signal.SIGUSR1)
                print("[Tweaker] sent SIGUSR1 to %d" % _server_pid)
            except Exception as e:
                print("[Tweaker] os.kill failed: %s" % e)
