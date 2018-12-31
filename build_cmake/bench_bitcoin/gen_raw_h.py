import sys


# Port from Makefile.bench.include
# $(HEXDUMP) -v -e '8/1 "0x%02x, "' -e '"\n"' $< | $(SED) -e 's/0x  ,//g' && \

def main(raw_file, raw_file_name):
    with open(raw_file, "rb") as f:
        contents = f.read()

    print("static unsigned const char {}[] = {{".format(raw_file_name))
    print(", ".join(map(lambda x: "0x{:02x}".format(ord(x)), contents)))
    print(" };")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("gen_raw_h.py [raw_file] [raw_file_name]")
        sys.exit(1)
    if sys.version_info.major > 2:
        def ord(x) : return x
    main(sys.argv[1],sys.argv[2])
