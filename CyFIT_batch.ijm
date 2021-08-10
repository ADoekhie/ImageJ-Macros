// This IMAGEJ macro processes all the fluorescence images in .tif format, with Cy or FITC in their title, in a folder and any subfolders.


// INITIAL SETUP 
// filetypes and directories
extension = ".tif"; // set file extension

dir1 = getDirectory("Choose Source Directory "); // or use the var below
dir2 = getDirectory("Choose Destination Directory "); // or use the var below

// dir1 = "set hardcoded source directory path";
// dir2 =  "set hardcoded destination directory path";

// set number of slices per spectrum of the image taken
slices = 5; 

// set first colour mode
mode1 = "Cy3"; 

// set second colour mode
mode2 = "FITC"; 

// set imageprocessing mode
setBatchMode(true); // process without displaying each image
list = getFileList(dir1); // index all files from folder 1


// IMAGE INDEXING 
// index all images based on their extension
img_list = newArray(); 

for (i=0; i<list.length; i++) {
	if(endsWith(list[i], extension)) {
		img_list = Array.concat(img_list, list[i]);
	}
}

Array.sort(img_list); // sort the image list alfabetically

Cy_list = newArray(img_list.length); // create a new list for Cy3 coloured images based on the length of all files

FITC_list = newArray(img_list.length); // create a new list for FITC coloured images based on the length of all files

// run through the image list and pass Cy3 and FITC images to their own list
for (i=0; i<img_list.length; i++) {
	if (indexOf(img_list[i], mode1) > 1)
		Cy_list[i] = img_list[i];
	if (indexOf(img_list[i], mode2) > 1)
		FITC_list[i] = img_list[i];

}

// SET LOOPING VARIABLES
var f = 1;
var d = 1;
var n = 1;
var m_image = " ";
var start = 0;

// check if composite files already exist in source directory and start processing from that point onwards
for (i=0; i<img_list.length; i++){
	t_image = "Composite_"+img_list[i];

	if (File.exists(dir2+t_image)) {
		start = i;
	}
	
}

var img_n = slices * 2; // process every n images of which half is each spectrum colour
var img_l = slices * 2 - 1; // name files from 0 - 9 

// loop through each image, find out what spectrum it contains, pass this on to the checkFL function
// once the counter reaches number of slices * 2 it'll composite all images for that one sample
for (i=start; i<img_list.length; i++){
	if (n <= img_n) {
		checkFL(i);
	}
	n++;
	if (n > img_n) {
		t_image = "Composite_"+img_list[(i-img_l)];
		processCyFIT(dir2, n, t_image,i);
		n = 1; // reset counter
	}
	
} 

// check what spectrum colour each image has based on its filename and process that with the respective function
function checkFL(i) {
	print(d,f);
	if (indexOf(Cy_list[i], extension) > 1) {
		processCy(dir1, "Cy3", Cy_list[i], d);
		d++;
		if (d > slices) { d = d-slices; }
		}
	if (indexOf(FITC_list[i], extension) > 1) {
		processFITC(dir1, "FITC", FITC_list[i], f);
		f++;
		m_image = FITC_list[i];
		if (f > slices) { f = f-slices; }
		}
}

// process Cy3 images and stack them based on the number of slices
function processCy(dir1, color, my_image, d1) {
	if (color == "Cy3") {
		open(dir1+my_image); // open the file
		image1 = getImageID();
		run("Duplicate...", " ");
		copy = getImageID();
		selectImage(image1);
		close();
		selectImage(copy);
		run("Brightness/Contrast...");
		run("Enhance Contrast", "saturated=0.35");
		run("Apply LUT");
		run("Close");
		run("Channels Tool...");
		run("Red");
		selectWindow("Channels");
		run("Close");
			if (d1 == slices)
				run("Images to Stack", "name=Stack1 title=[] use");
	}
}

// process FITCS images and stack them based on the number of slices
function processFITC(dir1, color, my_image, f1){
	if (color == "FITC") {
		open(dir1+my_image); // open the file
		image1 = getImageID();
		run("Duplicate...", " ");
		copy = getImageID();
		selectImage(image1);
		close();
		selectImage(copy);
		run("Brightness/Contrast...");
		run("Enhance Contrast", "saturated=0.35");
		run("Apply LUT");
		run("Close");
		run("Channels Tool...");
		run("Green");
		selectWindow("Channels");
		run("Close");
			if (f1 == slices)
				run("Images to Stack", "name=Stack2 title=[] use");	
	}
}

// process Cy3/FITC images and RGB stack them and export to destination folder
function processCyFIT(dir2, n, my_image,i){
	if (n == (slices+1) ) {
		if (File.exists(dir2+my_image)) {
			run("Close All");
			return;
		} else {	
			print("exporting");
			run("Merge Channels...", "c1=Stack1 c2=Stack2 create");
			cm = getImageID();
			selectImage(cm);
			run("Stack to RGB", " ");
			saveAs(extension, dir2+my_image);
     			run("Close All");
		}
	}
}
