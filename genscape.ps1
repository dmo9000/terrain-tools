nmake -f NMakefile perlin.exe

# seed, zscale, frequency, depth
./perlin.exe 15332 0.75 0.003 3 macro.pgm
#magick.exe convert -auto-level macro.pgm macro.png
magick.exe convert macro.pgm macro.png
./perlin.exe 1 1.00 0.005 6 medium.pgm
magick.exe convert medium.pgm medium.png
./perlin.exe 2 1.0 0.1 5 micro.pgm
magick.exe convert micro.pgm micro.png

# Copy-Item macro.png output.png
Write-Output "Creating hillsmask ..."
magick.exe convert macro.png -brightness-contrast -30,40 -blur 0,16 hillsmask.png

Write-Output "Creating peaksmask ..."

# for brightness contrast, the brightness specifies the height cutoff and the contrast specifies the peak boost

magick.exe convert macro.png -brightness-contrast -50,80 -blur 0,8 peaksmask.png


Write-Output "Adding hills detail ..."
magick.exe convert hillsmask.png medium.png -compose multiply -composite hills.png

Write-Output "Adding peaks detail ..."
magick.exe convert peaksmask.png micro.png -compose multiply -composite peaks.png


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
#magick.exe convert stage5.png output.png

Write-Output "Eroding ..."

magick.exe convert output.png erode-in.pgm
D:\git-local\erodr\erodr.exe -f erode-in.pgm -a -o erode-out.pgm 

# Copy-Item medium.png output.png
