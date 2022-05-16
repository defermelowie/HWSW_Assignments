#!/usr/bin/env python3

from sys import argv

binfile = argv[1]
nwords = int(argv[2])

with open(binfile, "rb") as f:
    bindata = f.read()

assert len(bindata) < 4*nwords
assert len(bindata) % 4 == 0

print("memory_initialization_radix = 16;")
print("memory_initialization_vector = ")

for i in range(nwords):
    if i < len(bindata) // 4:
        w = bindata[4*i : 4*i+4]
        print("%02x%02x%02x%02x" % (w[3], w[2], w[1], w[0]), end="")
        if i == (len(bindata) // 4) -1:
            print(";")
        else:
            print(",")
    # else:
    #     print("00000000", end="")
