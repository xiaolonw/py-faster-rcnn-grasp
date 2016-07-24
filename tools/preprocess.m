
jpgdir  = '/nfs.yoda/xiaolonw/grasp/results/test_imgs/';


list = dir([jpgdir '/*.jpg']); 


for i = 1 : numel(list)
	imname = list(i).name; 
	imname = [jpgdir '/' imname]; 
	im = imread(imname);
	height = round(size(im, 1) / 3);
	width  = round(size(im, 2) / 3); 
	im = imresize(im, [height, width]); 
	imwrite(im, imname); 
end
