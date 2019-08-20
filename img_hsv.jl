#!/usr/bin/env julia

@info("Starting")

levels=5
lvls=levels-1
sat=0.25

@info("Loading modules")

using Images, Statistics

@info("Loading images")
imgs=[ imresize(load(x), ratio=0.5) for x in ARGS ]

@info("Joining arrays")
imgs=[ reshape(img, length(img), 1) for img in imgs ]
img=foldr( (a,b)->cat(a,b,dims=1), imgs)
hsv=HSV{Float32}.(img)

vs=Array(0:1/(levels-1):1)

@info("Calculating")
hbyv = [ (RGB(h), round(h.v*lvls)/lvls) for h in hsv ]
meanhbyv = [ ( mean([ h for (h,v) in hbyv if v==vv]) , vv) for vv in vs ]
curves=zip(meanhbyv, vs)

@info("LUT (3d Cube format)")

println("TITLE \"test\"\nLUT_3D_SIZE $levels\n")
println("DOMAIN_MIN 0 0 0\nDOMAIN_MAX 1.0 1.0 1.0 \n")
for (thing,v) in curves
    r,g,b=thing[1].r, thing[1].g, thing[1].b
    @info("$r $g $b v=$v")
    println("$r $g $b")
end


