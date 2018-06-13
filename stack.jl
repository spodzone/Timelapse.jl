#!/usr/bin/env julia

info("Starting")

info("Loading modules")

#using Images, Color, FixedPointNumbers
using Images, FixedPointNumbers

function imageinterpolate(img1, img2, prop=0.5)
  "Return a new image interpolated prop proportion of the way from img1 to img2"
  img1=float32(img1)
  img2=float32(img2)
  img1b=reshape(data(img1),(width(img1)*height(img1)))
  img2b=reshape(data(img2),(width(img2)*height(img2)))
  
  d=[ img1b[i]+ (img2b[i]-img1b[i])*prop for i in 1:length(img1b) ]
  img3b=reshape(d, (width(img1), height(img1)))
  copy(img1, img3b)
end


fname=ARGS[1]
info("Loading image 1: [$fname]")
rolling=imread(ARGS[1])

for i in 2:length(ARGS)
  fname=ARGS[i]
  info("Loading image $i: [$fname]")
  img=imread(fname)
  n=imageinterpolate(rolling, img, 1/i)
  rolling=deepcopy(n)
end

# rolling=convert(Image{HSV}, rolling)
rolling=convert(Image{RGB}, rolling)

imwrite(rolling, "output.exr")
imwrite(rolling, "output.png")
imwrite(rolling, "output.tiff")

info("All done")
