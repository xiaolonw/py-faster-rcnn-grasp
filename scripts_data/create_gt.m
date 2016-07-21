
src = '/scratch/xiaolonw/grasp_data/benchmarkData/gt_box_cache_dir/'
bboxdir = '/nfs.yoda/xiaolonw/grasp/dataset/annotations_gray/';
list = '/nfs.yoda/xiaolonw/grasp/dataset/namelist.txt'; 
splits = '/scratch/xiaolonw/grasp_data/benchmarkData/metadata/splits.mat';

fid = fopen(list, 'r');
names = {};
while ~feof(fid)
	s = fscanf(fid, '%s', 1);
	if length(s) == 0
		break;
	end
	names{end + 1} = s;

end
fclose(fid);

for i = 1 : 10
	foldername = sprintf('%s/%d', src, i);
	mkdir(foldername); 
end

backim = imread('/nfs.yoda/xiaolonw/grasp/dataset/background/background.jpg'); 
height = size(backim, 1);
width  = size(backim, 2);

outnames = {};

for i = 1 : numel(names)
	fname = names{i};
	boxname = [bboxdir '/' fname '.txt']; 
	matname = [src '/' fname '.mat'];
	fid2 = fopen(boxname, 'r');

	rec.objects = [];
	rec.imgsize = [height, width]; 

	obj.instanceId = 1;
	obj.difficult = 0;
	obj.truncated = 0;
	obj.bbox = [];
	obj.class = '';

	cnt = 1;

	while ~feof(fid2)
		cls = fscanf(fid2, '%d', 1);
		if length(cls) == 0
			break;
		end
		bbox = fscanf(fid2, '%d', 4); 
		obj.bbox = [bbox(1), bbox(3), bbox(2), bbox(4)]; 
		obj.class = num2str(cls); 
		rec.objects = [rec.objects, obj];
		obj.instanceId = cnt;
		cnt = cnt + 1;

	end

	fclose(fid2); 

	if numel(rec.objects) == 0
		continue;
	end

	save(matname, 'rec'); 
	outnames{end + 1} = fname;

end

rp =  randperm(numel(outnames)); 
trainval = {};
test = {};
for i = 1 : numel(rp) - 2000
	trainval{end + 1} = outnames{rp(i)};
end
for i = numel(rp) - 2000 + 1 : numel(rp)
	test{end + 1} = outnames{rp(i)};
end



save( splits , 'test' , 'trainval');

