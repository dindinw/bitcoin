#!/usr/bin/env python

import os
import sys


def main(src, dst):
    os.symlink(src, dst)
    print("symlink created")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("mklink.py [src] [dst]")
        os.exit(1)

    main(sys.argv[1], sys.argv[2])