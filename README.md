# Senior-Design-SUAS-Image-Processing
Image processing software for Stevens Institute of Technology SUAS competition 2015

analyzeFolder is the batch processor the imports images and sends them to be processed.  it also update the text file

imageProcessing contains the localization algorithm

findTarget determines if a target is in the image

determineColors determines the colors of the target shape and alphanumeric

colornames is used by determineColors


tree:
===========
analyzeFolder
     imageProcessing
          findTarget
	       determineColors
	            colornames
