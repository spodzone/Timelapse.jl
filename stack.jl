#!/usr/bin/env julia

info("Starting")

info("Loading modules")

using Images, FixedPointNumbers

function imageinterpolate(img1, img2, prop=0.5)
  "Return a new image interpolated PROP-proportion of the way from img1 to img2 (arrays)"
  d=[ img1[i]+ (img2[i]-img1[i])*prop for i in 1:length(img1) ]
  d
end


fname=ARGS[1]
info("Loading image 1: [$fname]")
rolling=load(ARGS[1])
w,h,props = (width(rolling), height(rolling), properties(rolling))

for i in 2:length(ARGS)
  fname=ARGS[i]
  info("Loading image $i: [$fname]")
  img=load(fname)
  img=reshape(data(float32(img)), w*h)
  n=imageinterpolate(rolling, img, 1/i)
  rolling=deepcopy(n)
end

info("Converting final format")
rolling=reshape(rolling, (w,h))
rolling=convert(Image{Images.RGB24}, rolling)

info("Saving")
#info("  EXR")
#imwrite(rolling, "output.exr")
info("  PNG")
imwrite(rolling, "output.png")
info("  TIFF")
imwrite(rolling, "output.tiff")

info("All done")
