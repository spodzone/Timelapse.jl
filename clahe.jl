#!/usr/bin/env julia

#
# Apply CLAHE adaptive histogram equalization
#

function tlog(str)
    tm=time()
    println("[$tm] - $str")
end

function adaptive(fname)
    ofname=replace(fname, r"(\..*)" => s"-clahe\1")
    src=load(ARGS[1])
    img = clahe(src, 128, xblocks=8, yblocks=8, clip=3)
    save(ofname, img)
end

tlog("Loading modules")

using Images, Statistics

tlog("Running")
for fname in ARGS[1:end]
    tlog("    $(fname)")
    adaptive(fname)
end

tlog("All done")
