# Powerline segment: compact hardware identity for status-right, e.g. "MacBook Air".
# The IORegistry marketing name minus its parenthetical; cached for the daemon's
# lifetime since hardware can't change mid-boot.
import plistlib
import re
import subprocess

_cached = None


def _run(cmd):
    try:
        out = subprocess.run(cmd, capture_output=True, timeout=5)
        return out.stdout.decode(errors='ignore').strip()
    except Exception:
        return ''


def _compute():
    model = ''
    xml = _run(['ioreg', '-ar', '-d1', '-k', 'product-name'])
    if xml:
        try:
            raw = plistlib.loads(xml.encode())[0].get('product-name', b'')
            model = raw.decode(errors='ignore').rstrip('\x00').strip()
        except Exception:
            pass
    # "MacBook Air (13-inch, M3, 2024)" -> "MacBook Air"
    model = re.sub(r'\s*\(.*\)$', '', model).strip()
    if not model:
        model = _run(['sysctl', '-n', 'hw.model'])  # e.g. "Mac15,12"

    return model


def dev_env(pl, segment_info=None, **kwargs):
    global _cached
    if _cached is None:
        _cached = _compute()
    if not _cached:
        return None
    return [{'contents': _cached, 'highlight_groups': ['hostname']}]
