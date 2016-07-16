
srcdir = '/scratch/xiaolonw/nyud2/data/images/';
desdir = '/scratch/xiaolonw/nyud3/data/images/'; 


list = dir([srcdir '/*.png']); 

for i = 1 : numel(list)
	fname = list(i).name; 
	num = str2num(fname(5:8)); 
	readname = [srcdir '/' fname]; 
	desname = sprintf('%s/img_%05d.png', desdir, num);
	cmd = ['cp ' readname ' ' desname]; 
	system(cmd);

end



