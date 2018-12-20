#!/usr/bin/env python

import sys
import os


def main(src, dst):
    if sys.version_info.major > 2:
        os.symlink(src, dst)
        print("symlink created")
    else:
        print("python 2 not support yet")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("mklink.py [src] [dst]")
        sys.exit(1)

    main(sys.argv[1], sys.argv[2])
