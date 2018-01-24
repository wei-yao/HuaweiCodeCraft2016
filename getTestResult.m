fileId=fopen(['alltest.txt'],'rt');   
A=fscanf(fileId,'testname %s min %d  true %d round %d time %f\n');
fclose(fileId);
% load('alltest.txt');