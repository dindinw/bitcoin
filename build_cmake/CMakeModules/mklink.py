#!/usr/bin/env python

import sys
import os
import platform


def main(src, dst):
    if os.path.isfile(dst) and os.path.islink(dst):
        os.remove(dst)
        # print('old symlink "%s" removed' % dst)
    symlink(src, dst)
    print("symlink created")


# Note : the original _symlink_win32 code copied from
# https://github.com/erdc/python/blob/v2.7.4/Lib/test/symlink_support.py
# The _symlink_win32 method using the win32 API only provided by ctypes
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

    DeleteFile = ctypes.windll.kernel32.DeleteFileW
    DeleteFile.argtypes = (ctypes.c_wchar_p,)
    DeleteFile.restype = ctypes.c_bool

    GetFileAttributesW = ctypes.windll.kernel32.GetFileAttributesW
    GetFileAttributesW.argtypes = (ctypes.c_wchar_p,)
    GetFileAttributesW.restype = ctypes.c_uint

    def islink(path):
        FILE_ATTRIBUTE_REPARSE_POINT = 1024
        return bool(GetFileAttributesW(path) & FILE_ATTRIBUTE_REPARSE_POINT)

    def handle_nonzero_success(result):
        if result == 0:
            value = ctypes.windll.kernel32.GetLastError()
            strerror = (value)
            raise WindowsError(value, strerror)

    target_is_directory = target_is_directory or os.path.isdir(target)

    if islink(link) :
        # check if the link already exist and del it
        # need to make sure we can only delete the file if it's a link, not a real file
        if not DeleteFile(link):
            raise WindowsError('could not delete file "%s"' % link)
    handle_nonzero_success(CreateSymbolicLink(link, target, target_is_directory))


symlink = os.symlink if hasattr(os, 'symlink') else (
    _symlink_win32 if platform.system() == 'Windows' else None
)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("mklink.py [src] [dst]")
        sys.exit(1)

    main(sys.argv[1], sys.argv[2])
