
srcdir = '/nfs/hn38/users/xiaolonw/dcgan/results_10k/train_3dnormal_joint4/';
desdir = '/scratch/xiaolonw/nyud3/data/images/'; 


list = dir([srcdir '/*.jpg']); 
startid = 10000;

for i = 1 : numel(list)
	nowid = startid + i - 1;
	fname = list(i).name; 
	readname = [srcdir '/' fname]; 
	desname  = [desdir '/' num2str(nowid) '.png'];  
	im = imread(readname); 
	im = imresize(im, [512, 512]); 
	imwrite(im, desname); 
end



