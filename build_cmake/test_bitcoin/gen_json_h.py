#!/usr/bin/env python
# Copyright (c) 2018 The Bitcoin developers

import sys

# port from src/Makefile.test.include
# $(HEXDUMP) -v -e '8/1 "0x%02x, "' -e '"\n"' $< | $(SED) -e 's/0x  ,//g' && \

# For Python3
def main3(test_name, input_file):
    with open(input_file, "rb") as f:
        contents = f.read()

    print("namespace json_tests{")
    print("   static unsigned const char {}[] = {{".format(test_name))
    print(", ".join(map(lambda x: "0x{:02x}".format(x), contents)))
    print(" };")
    print("};")

# For Python2
def main2(test_name, input_file):
    with open(input_file, "rb") as f:
        contents = f.read()

    print("namespace json_tests{")
    print("   static unsigned const char {}[] = {{".format(test_name))
    print(", ".join(map(lambda x: "0x{:02x}".format(ord(x)), contents)))
    print(" };")
    print("};")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("We need additional pylons!")
        sys.exit(1)
    if sys.version_info.major > 2:
        main3(sys.argv[1], sys.argv[2])
    else:
        main2(sys.argv[1], sys.argv[2])