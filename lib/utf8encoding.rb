# -*- coding: utf-8 -*-
require 'rubygems'
require 'find'

Find.find("./") do |p|
  if p =~ /\.(rb|rake)$/
    arr = File.read(p).split("\n")
    if arr.first.index("utf-8").to_i > 0
      arr[0] = "# -*- coding: utf-8 -*-"
    else
      arr = ["# -*- coding: utf-8 -*-"] + arr
    end
    File.open(p, "w") do |f|
      f.write arr.join("\n")
    end
  end
end