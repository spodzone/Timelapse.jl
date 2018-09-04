#!/usr/bin/env julia

function tlog(str)
    tm=time()
    println("[$tm] - $str")
end

tlog("Starting")

tlog("Loading modules")

using Images

function imageinterpolate(img1, img2, prop=0.5)
  "Return a new image interpolated PROP-proportion of the way from img1 to img2 (arrays)"
  d = img1 + (img2-img1)*prop
  d
end


fname=ARGS[1]
tlog("Loading image 1: [$fname]")
rolling=load(ARGS[1])
w,h=size(rolling)

for i in 1:length(ARGS)
    fname=ARGS[i]
    tlog("Loading image $i [$fname]")
    img=load(fname)
    img = RGB{Float16}.(img)    
    if(i==1)
        global rolling=deepcopy(img)
    else
        n=imageinterpolate(rolling, img, 1/i)
        global rolling=deepcopy(n)
    end
        
end

tlog("Converting final format")
rolling=reshape(rolling, (w,h))

tlog("Saving")
#info("  EXR")
#save("output.exr", rolling)
tlog("  PNG")
rolling=RGB{N0f16}.(rolling)

save("output.png", rolling)
tlog("  TIFF")
save("output.tiff", rolling)

tlog("All done")
