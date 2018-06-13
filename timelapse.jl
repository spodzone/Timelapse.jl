#!/usr/bin/env julia

info("Starting")

info("Loading modules")

#using Graphics, Images, Color, FixedPointNumbers
using Graphics, Images, FixedPointNumbers

function imageinterpolate(img1, img2, prop=0.5)
  "Return a new image interpolated prop proportion of the way from img1 to img2"
  img1b=reshape(data(img1),(width(img1)*height(img1)))
  img2b=reshape(data(img2),(width(img2)*height(img2)))
  
  d=[ img1b[i]+ (img2b[i]-img1b[i])*prop for i in 1:length(img1b) ]
  img3b=reshape(d, (width(img1), height(img1)))
  copy(img1, img3b)
end

function findimages(data, t)
  "Find the indexes and proportion between them corresponding to time t in data"
  idx=try minimum(find(map(x->x[1]>t, data)))-1 catch "" length(data) end
  left=max(1, idx)
  right=min(idx+1, length(data))
  tl=data[left][1]
  tr=data[right][1]
  prop=(t-tl)/(tr-tl)
  if(!isfinite(prop))
    prop=1
  end
  return left,right,prop
end


info("Sorting parameters")
noframes=try int(ARGS[1]) catch "" 100 end
imagedir=try ARGS[2] catch "" "./images" end
outdir=try ARGS[3] catch "" "./images-out" end

info("Reading images from directory [$imagedir]")
images=sort(readdir(imagedir))
images=map(x->"$imagedir/$x", images)
imagetimes = map(x->stat(x).mtime, images)
filedata=sort([ (imagetimes[i], images[i]) for i in 1:length(images) ])

info("Interpolating $noframes frames")

tstart=minimum(imagetimes)
tend=maximum(imagetimes)

noimages=length(images)
oldleft=-1
for i in 1:noframes
  desiredtime=tstart+(tend-tstart)*i/noframes
  left,right,prop=findimages(filedata, desiredtime)
  info("  frame $i / $noframes  left=$left, right=$right, prop=$prop")
  img1=imread(images[left])
  img2=imread(images[right])
  oimg=imageinterpolate(img1, img2, prop)
  ofile=@sprintf("%s/image-%05d.jpg", outdir, i)
  imwrite(oimg, ofile)
end

info("All done")
