


txffile = 'scores.txt';

fid = fopen(txffile, 'r');
sumscore =  0
for i = 1 : 19
	s = fscanf(fid, '%s', 1);
	s = fscanf(fid, '%s', 1);
	score = fscanf(fid, '%f', 1);
	sumscore = sumscore + score;
end


fclose(fid);

sumscore = sumscore / 19

