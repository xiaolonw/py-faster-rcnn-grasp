
srcdir = '/scratch/xiaolonw/nyud2/benchmarkData/gt_box_cache_dir/';
desdir = '/scratch/xiaolonw/nyud3/benchmarkData/gt_box_cache_dir/'; 


list = dir([srcdir '/*.mat']); 

for i = 1 : numel(list)
	fname = list(i).name; 
	num = str2num(fname(5:8)); 
	readname = [srcdir '/' fname]; 
	desname = sprintf('%s/img_%05d.mat', desdir, num);
	cmd = ['cp ' readname ' ' desname]; 
	system(cmd);

end



