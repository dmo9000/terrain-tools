# Some favourite seeds:
#  2053 - small archipeligo
#  3001 - island with inland lake
#  3032 
#  80486 - noice
#  8087 - nice crater


$seed = 80486
$seed2 = $seed + 1
$seed3 = $seed + 2
$seed4 = $seed + 4


# create circle mask

if (Test-Path "circle_mask.png") {
    Write-Output "Circular mask exists ..."
} else {
    Write-Output "Creating circular mask ..."
    magick.exe convert -size 2160x2160 xc:black -fill white -stroke white -draw "circle 1080,1080 500,500"  -blur 0,128 circle_mask.png
}
Remove-Item images\*.png
nmake -f NMakefile perlin.exe

# seed, zscale, frequency, depth
./perlin.exe $seed  1.0 0.002 6 macro.pgm
#magick.exe convert -auto-level macro.pgm macro.png
magick.exe convert macro.pgm macro.png
./perlin.exe $seed2 0.75 0.005 6 medium.pgm
magick.exe convert medium.pgm medium.png
./perlin.exe $seed3 1.0 0.05 6 micro.pgm
magick.exe convert micro.pgm micro.png


Copy-Item macro.png images/macro.png
Copy-Item medium.png images/medium.png
Copy-Item micro.png images/micro.png


# clip the macro to the circle_mask

Write-Output "Clipping macro layer to circle_mask ..."
magick.exe convert macro.png circle_mask.png -compose multiply -composite clipped.png
magick.exe convert clipped.png macro.png
Copy-Item clipped.png images/clipped.png

# Copy-Item macro.png output.png
Write-Output "Creating hillsmask ..."
magick.exe convert macro.png -brightness-contrast -30,40 -blur 0,16 hillsmask.png

Copy-Item hillsmask.png images/hillsmask.png


Write-Output "Creating peaksmask ..."

# for brightness contrast, the brightness specifies the height cutoff and the contrast specifies the peak boost

magick.exe convert macro.png -brightness-contrast -50,80 -blur 0,8 peaksmask.png

Copy-Item peaksmask.png images/peaksmask.png

Write-Output "Adding hills detail ..."
magick.exe convert hillsmask.png medium.png -compose multiply -composite hills.png

Copy-Item hills.png images/hills.png

Write-Output "Adding peaks detail ..."
magick.exe convert peaksmask.png micro.png -compose multiply -composite peaks.png


Copy-Item peaks.png images/peaks.png

Write-Output "Overlaying hills (medium) detail  ..."
magick.exe convert macro.png hills.png -compose screen -composite stage1.png

Write-Output "Overlaying hills (medium) detail  ..."
magick.exe convert stage1.png hills.png -compose screen -composite stage2.png

Write-Output "Overlaying peaks (micro) detail  ..."
magick.exe convert stage2.png peaks.png -compose screen -composite stage3.png

Write-Output "Overlaying peaks (micro) detail  ..."
magick.exe convert stage3.png peaks.png -compose screen -composite stage4.png

Write-Output "Overlaying peaks (micro) detail  ..."
magick.exe convert stage4.png peaks.png -compose screen -composite stage5.png

Write-Output "Filling vertical space ..."
magick.exe convert -auto-level stage5.png output.png
# magick.exe convert stage5.png output.png

# split top and bottom halves
Write-Output "Creating coastline ..."

magick.exe convert medium.pgm medium.png
Copy-Item output.png images\output.png
magick.exe convert output.png -black-threshold 50% images\tophalf.png
magick.exe convert output.png -white-threshold 50% images\bottomhalf.tmp.png
magick.exe convert images\bottomhalf.tmp.png -fill black -opaque white images\bottomhalf.png
magick.exe convert images\bottomhalf.tmp.png -transparent '#ffffff' -alpha extract -negate images\tophalfmask.png
magick.exe convert images\tophalfmask.png -canny 0x1+10%+30% images\coastaledge.png

for ($i = 0; $i -lt 24; $i++) {
    Write-Output "  Iteration $i ..."
    magick.exe convert .\images\coastaledge.png -morphology Dilate Octagon images\coast.tmp.png
    Copy-Item images\coast.tmp.png images\coastaledge.png
    Remove-Item images\coast.tmp.png
}

# create high-contrast noise mask to modify the coastmask
./perlin.exe $seed4 0.875 0.01 5 images\shoredetail.pgm
magick.exe convert images/shoredetail.pgm images/shoredetail.png
Remove-Item images/shoredetail.pgm

#$shorelinemask = "images\macro.png"
#$shorelinemask = "images\medium.png"
#$shorelinemask = "images\micro.png"
$shorelinemask = "images\shoredetail.png"

magick.exe convert $shorelinemask -white-threshold 50% images\coastalnoise.tmp.png
magick.exe convert images\coastalnoise.tmp.png -transparent '#ffffff' -alpha extract -negate images\coastalnoise.png
Remove-Item images\coastalnoise.tmp.png

magick.exe convert images\coastaledge.png images\coastalnoise.png -compose multiply -composite images\noisycoastmask.png

# create the coast strip to be merged

magick.exe convert -size 2160x2160 xc:'rgb(50.25%,50.25%,50.25%)' images\coastcolor.png
magick.exe convert images\coastaledge.png images\coastcolor.png -compose multiply -composite images\coastband.png

# TODO: coastline variation, via macro/medium/micro mask with high contrast
#       also, blur the edges of the mask

#magick.exe convert -auto-level micro.png images\micro-expanded.png
#magick.exe convert images\coastaledge.png images\micro-expanded.png -compose multiply -composite images\coastline.png


# third argument is the coastline mask

#magick.exe convert images\output.png images\coastband.png images\coastaledge.png  -composite images\shorelined.png
magick.exe convert images\output.png images\coastband.png images\noisycoastmask.png  -composite images\shorelined.png
Remove-Item images\coast?.png
Remove-Item images\bottomhalf.tmp.png

magick.exe convert images\shorelined.png -blur 0,3 output.png


Write-Output "Eroding ..."
for ($i = 0; $i -lt 5; $i++) {
    Write-Output "  Iteration $i ..."
    magick.exe convert output.png -compress none erode-in.pgm
    magick.exe convert erode-in.pgm erode-in.png
    D:\git-local\erodr\erodr.exe -m 0.1 -s 0.05 -r 1 -t 100 -n 300000 -f erode-in.pgm -a -o erode-out.pgm 
    magick.exe convert erode-out.pgm erode-out.png
    Copy-Item -Force erode-out.png output.png
}


Copy-Item erode-in.png images\erode-in.png
Copy-Item erode-out.png images\erode-out.png

Write-Output "Final blur filter ..."

magick.exe convert erode-out.png -blur 0,2 output.png
Copy-Item output.png images\output.png

# Copy-Item medium.png output.png
