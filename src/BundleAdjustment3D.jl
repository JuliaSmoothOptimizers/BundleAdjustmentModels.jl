export constructPLYfile

function constructPLYfile(model :: BundleAdjustmentModel, x :: AbstractVector, filename :: String)
  output = open(filename, "w")
  npnts = model.npnts
  write(output, "ply \n")
  write(output, "format ascii 1.0 \n")
  write(output, "element vertex "*string(npnts)*" \n")
  write(output, "property float x \n")
  write(output, "property float y \n")
  write(output, "property float z \n")
  write(output, "property uchar red \n")
  write(output, "property uchar green \n")
  write(output, "property uchar blue \n")
  write(output, "end_header \n")
  for i = 1:npnts
    point = x[3*(i-1)+1:3*(i-1)+3]
    write(output, string(point[1])*" "*string(point[2])*" "*string(point[3])*" 255 255 255 \n")
  end
  close(output)
end