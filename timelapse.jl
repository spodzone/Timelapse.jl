#!/usr/bin/env julia

function tlog(str)
    tm=time()
    println("[$tm] - $str")
end

tlog("Starting")

tlog("Loading modules")

using Images, Printf

function imageinterpolate(img1, img2, prop=0.5)
  "Return a new image interpolated prop proportion of the way from img1 to img2"
  d = img1 + (img2-img1)*prop
  d
end

function findimages(data, t)
  "Find the indexes and proportion between them corresponding to time t in data"
  idx=length(filter( x -> x[1]<t, data))
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


tlog("Sorting parameters")
noframes=try parse(Int, ARGS[1]) catch N 100 end
imagedir=try ARGS[2] catch N  "./images" end
outdir=try ARGS[3] catch N  "./images-out" end

tlog("Reading images from directory [$imagedir]")
images=sort(readdir(imagedir))
images=map(x->"$imagedir/$x", images)
imagetimes = map(x->stat(x).mtime, images)
filedata=sort([ (imagetimes[i], images[i]) for i in 1:length(images) ])

tlog("Interpolating $noframes frames")

tstart=minimum(imagetimes)
tend=maximum(imagetimes)

noimages=length(images)
oldleft=-1
for i in 1:noframes
  desiredtime=tstart+(tend-tstart)*i/noframes
  left,right,prop=findimages(filedata, desiredtime)
  tlog("  frame $i / $noframes  left=$left, right=$right, prop=$prop")
  img1=load(images[left])
  img2=load(images[right])
  img1 = RGB{Float16}.(img1)
  img2 = RGB{Float16}.(img2)

  oimg=imageinterpolate(img1, img2, prop)
  oimg=RGB{N0f8}.(oimg)
  ofile=@sprintf("%s/image-%05d.jpg", outdir, i)
  tlog("  saving $ofile")
  save(ofile, oimg)
end

tlog("All done")
