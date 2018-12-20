#!/usr/bin/env python

import sys
import os
import platform


def main(src, dst):
   symlink(src, dst)
   print("symlink created")

# Note : the original _symlink_win32 code copied from
# https://github.com/erdc/python/blob/v2.7.4/Lib/test/symlink_support.py
def _symlink_win32(target, link, target_is_directory=False):
    """
    Ctypes symlink implementation since Python doesn't support
    symlinks in windows yet. Borrowed from jaraco.windows project.
    """
    import ctypes.wintypes
    CreateSymbolicLink = ctypes.windll.kernel32.CreateSymbolicLinkW
    CreateSymbolicLink.argtypes = (
        ctypes.wintypes.LPWSTR,
        ctypes.wintypes.LPWSTR,
        ctypes.wintypes.DWORD,
    )
    CreateSymbolicLink.restype = ctypes.wintypes.BOOLEAN

    def format_system_message(errno):
        """
        Call FormatMessage with a system error number to retrieve
        the descriptive error message.
        """
        # first some flags used by FormatMessageW
        ALLOCATE_BUFFER = 0x100
        ARGUMENT_ARRAY = 0x2000
        FROM_HMODULE = 0x800
        FROM_STRING = 0x400
        FROM_SYSTEM = 0x1000
        IGNORE_INSERTS = 0x200

        # Let FormatMessageW allocate the buffer (we'll free it below)
        # Also, let it know we want a system error message.
        flags = ALLOCATE_BUFFER | FROM_SYSTEM
        source = None
        message_id = errno
        language_id = 0
        result_buffer = ctypes.wintypes.LPWSTR()
        buffer_size = 0
        arguments = None
        bytes = ctypes.windll.kernel32.FormatMessageW(
            flags,
            source,
            message_id,
            language_id,
            ctypes.byref(result_buffer),
            buffer_size,
            arguments,
        )
        # note the following will cause an infinite loop if GetLastError
        #  repeatedly returns an error that cannot be formatted, although
        #  this should not happen.
        handle_nonzero_success(bytes)
        message = result_buffer.value
        ctypes.windll.kernel32.LocalFree(result_buffer)
        return message

    def handle_nonzero_success(result):
        if result == 0:
            value = ctypes.windll.kernel32.GetLastError()
            strerror = format_system_message(value)
            raise WindowsError(value, strerror)

    target_is_directory = target_is_directory or os.path.isdir(target)
    handle_nonzero_success(CreateSymbolicLink(link, target, target_is_directory))

symlink = os.symlink if hasattr(os, 'symlink') else (
    _symlink_win32 if platform.system() == 'Windows' else None
)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("mklink.py [src] [dst]")
        sys.exit(1)

    main(sys.argv[1], sys.argv[2])
