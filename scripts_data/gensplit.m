

src = '/scratch/xiaolonw/nyud2/benchmarkData/metadata/nyusplits.mat'; 
src2 = '/scratch/xiaolonw/nyud3/benchmarkData/metadata/nyusplits.mat'; 


load(src); 
trainval = [trainval [10000:29999] ]; 
save( src2 , 'test' , 'trainval');
