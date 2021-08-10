// This IMAGEJ macro script will measure the intensity of the red and green channels based  on an auto default threshold 
// Ratio will help calculate green flourescence over red

// SET FILE DIRECTORY AND TYPE
extension = ".tif";
dir1 = getDirectory("Choose Source Directory ");
setBatchMode(true);
list = getFileList(dir1);

// loop through file list and sort out based on file format
for (i=0; i<list.length; i++) {
	if(endsWith(list[i], extension)) {
		measureCyFI(list[i]);
	}
}

// call function to split rgb channels of composite images and measure the ratio of red and green flourecense over the total image area
// data can be further processed to obtain ratio for statistics or other types of interpretation
function measureCyFI (img) {
	open(dir1+img);
	my_img = getImageID();
	run("Duplicate...", " ");
	copy = getImageID();
	close(my_img);
	selectImage(copy);
	run("RGB Stack");
	rgb_img = getImageID();
	setAutoThreshold("Default");
	// close();
	call("ij.plugin.frame.ThresholdAdjuster.setMode", "B&W");
	run("Set Measurements...", "area mean min integrated area_fraction redirect=None decimal=3");
	setSlice(2);
	run("Measure");
	setSlice(1);
	run("Measure");
	close(copy);
	close(rgb_img);
}
