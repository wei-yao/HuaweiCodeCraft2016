function testAll(  )
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
homeDir='test-case';
fileId=fopen([homeDir '\' 'alltest.txt'],'wt');
top = dir(homeDir);
for i=3:1:length(top)
    secondDir=[homeDir '\' top(i).name];
    if(~isdir(secondDir))
       continue;
    end
    second=dir(secondDir);
    for j=3:1:length(second)
        if(isdir([secondDir '\' second(3).name]))
            thirdDir=[secondDir '\' second(j).name]
              third=dir(thirdDir);
                [fmin,idPath,trueSol,iterRound,time] =  test(thirdDir);
                fprintf(fileId,'testname %s min %d  true %d round %d time %f\n',thirdDir,fmin,trueSol,iterRound,time);
        else
                [fmin,idPath,trueSol,iterRound,time] =  test(secondDir);
                 fprintf(fileId,'testname %s min %d  true %d round %d time %f\n',secondDir,fmin,trueSol,iterRound,time);
                break;
        end
        
    end
end
fclose(fileId);
end
function [fmin,idPath,trueSol,iterRound,time]= test(name)
   topo=[name '\' 'topo.csv'];
   demand=[name '\' 'demand.csv'];
   result=[name '\' 'matlab_result.csv'];
   [fmin,idPath,trueSol,iterRound,time]=findPath(topo,demand);
   file=fopen(result,'wt');
   len= length(idPath);
   fprintf(file,'min %d  true %d round %d time %f\n',fmin,trueSol,iterRound,time);
   if(len==0)
    fprintf(file,'NA');
   else
       for i=1:len-1
        fprintf(file, '%d|',idPath(i));
       end
       fprintf(file, '%d|',idPath(len));
   end
   fclose(file);
end
