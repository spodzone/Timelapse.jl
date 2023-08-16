#!/usr/bin/env julia

using Images
using Statistics
using Dates
using Distributed
using JSON

function tlog(instr)
  nowstr = Dates.format(Dates.now(), ISODateTimeFormat)
  println("[$nowstr] $instr")
end

function mkstats(channel)
  tlog("Analyzing channel of type " * string(typeof(channel)))
  ret = Dict()
  mn = mean(channel)
  ret["Mean"] = mn
  sharp = stdm(channel, mn)
  ret["stdev"] = sharp
  u = unique(channel)
  nlevels = length(u)
  ret["Distinct_levels"] = nlevels
  nbits = log2(nlevels)
  ret["Bits_required"] = nbits
  nearestword = 8
  while nearestword < nbits
    nearestword = nearestword * 2
  end
  ret["Utilization%"] = float32(nbits) / float(nearestword) * 100.0
  ret["Quantization%"] = (1.0 - float32(nbits) / float(nearestword)) * 100.0
  return ret
end

function analyze(instr)
  tlog("Analysing image [$instr]")
  pic = Images.load(instr)
  L = Gray.(pic)
  # R = red.(pic)
  # G = green.(pic)
  # B = blue.(pic)

  hsv_img = HSV.(pic)
  hsv = channelview(float.(hsv_img))
  H = hsv[1, :, :]
  S = hsv[2, :, :]
  V = hsv[3, :, :]

  ret = Dict()
  ret["Filename"] = instr
  channelnames = ["L", "H", "S", "V"]
  channelvalues = [L, H, S, V]
  channels = Dict(zip(channelnames, channelvalues))
  Threads.@threads for k in channelnames
    ret[k] = mkstats(channels[k])
  end
  return ret
end

function main()
  ret = pmap(analyze, ARGS)
  println(JSON.json(ret, 4))
end

main()