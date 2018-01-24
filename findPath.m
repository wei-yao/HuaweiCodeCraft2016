function  [fmin,idPath,trueSol,iterRound,time]=findPath(topo,demand  )
tic;
topo=load(topo);
% demand.csv 中的 | 需要被替换成空格
% demand=load('demand.csv');
demand=textread(demand,'','delimiter',',|');
% 加一是因为matla吧中下标从1开始.
startPoint=demand(1)+1;
endPoint=demand(2)+1;
mustPoints=demand(3:end)+1;
mustPointsNum=length(mustPoints);
INT_MAX=999999;
maxId=max([topo(:,2) topo(:,3)]);
maxId=max(maxId(:));
vN=maxId+1
adjMatrix=ones(vN,vN)*INT_MAX;
idMatrix=-ones(vN,vN);
for i=1:length(topo)
    row=topo(i,2)+1;
    col=topo(i,3)+1;
    cost=topo(i,4);
    if(cost<adjMatrix(row,col))
        adjMatrix(row,col)=cost;
        %id的临界矩阵中存储的id从0开始
        idMatrix(row,col)=topo(i,1);
    end
end

indicator=(idMatrix~=-1);
edgeNum=length(find(idMatrix~=-1));
% 取indicator为1的地方 adjMatrix对应的值，所有的值按列主序拉成1维向量.
f=adjMatrix(indicator);
aeSize=vN+mustPointsNum+2;
% 相等约束条件1：每个点的出入度之差， 起始点，必经点的出度  共  vN+mustPointsNum+2个
% Ae . x=be;
Ae=zeros(aeSize,edgeNum);
be=zeros(aeSize,1);
% 出入度之差的约束
for i=1:vN
    temp=zeros(vN,vN);
    temp(i,:)=1;
    temp(:,i)=-1;
    temp(i,i)=0;
    Ae(i,:)=temp(indicator);
    
    if(i==startPoint)
        be(i)=1;
    else if(i==endPoint)
            be(i)=-1;
        end
    end
end
% 出度约束条件
% vList 包括起始点和必经点
vList=demand+1;
for i=1:length(vList);
    v=vList(i);
    temp=zeros(vN,vN);
    temp(v,:)=1;
%     前面已经有过vN个约束条件.
    Ae(i+vN,:)=temp(indicator);
    if(v==startPoint)
        be(i+vN)=1;
    else if(v==endPoint)
            be(i+vN)=0;
        else
%             必经点
            be(i+vN)=1;
        end
    end
end
% 不等约束条件 A . X<=b;
% 不等约束条件: 对于必经点，起始点之外的点 出度<=1;
aneSize=vN-mustPointsNum-2;
A=zeros(aneSize,edgeNum);
b=ones(aneSize,1);
offset=1;
for i=1:vN
%     判断是否是非必经点
    if(isempty(find(vList==i, 1)))
        temp=zeros(vN,vN);
        temp(i,:)=1;
        A(offset,:)=temp(indicator);
        offset=offset+1;
    end
end
% 这个是所有边的 起点，终点对数组
ids=zeros(length(f),2);
[ids(:,1),ids(:,2)]=find(idMatrix~=-1);
% 解的上下界 [0,1]
lb=zeros(edgeNum,1);
ub=ones(edgeNum,1);
% 下面是生成mps文件的部分.
% VarNameFun = @(m) (['var' int2str(m)]);
% returning varname 'x', 'y' 'z'
%  BuildMPS(A, b, Ae,be, f,lb,ub,'Pbtest','VarNameFun',VarNameFun,'Binary',[1:edgeNum],'MPSfilename','Pbtest.mps');
% 求解
iterRound=0;
toc;
% tic;
options = optimoptions('intlinprog','Display','off');
while(true)
    [x,fmin]=intlinprog(f,1:edgeNum,A,b,Ae,be,lb,ub,options);
    iterRound=iterRound+1;
    if(isempty(x))
        disp('无解');
        idPath=[];
        trueSol=0;
        time=toc;
        return;
    end
%     返回检测的所有环和起点到终点路径的列表, subTours{1} 为起点到终点的路径.
    subTours=mdetectSubtours(x,ids,startPoint,endPoint);
    numTours=length(subTours);
    if(numTours==1)
        break;
    end
%     附加的不等约束条件，每一个环中所有点的出度之和<=点数-1；
    App=zeros(numTours,edgeNum);
    bpp=zeros(numTours,1);
    for i=1:numTours
        curTour=subTours{i};
        temp=zeros(vN,vN);
        %         syntax?
%         temp(curTour,:)=1;
       if(i~=1)
           temp(curTour,curTour)=1;
        App(i,:)=temp(indicator);
        bpp(i)=length(curTour)-1;
       else
           for j=1:length(curTour)-1
                temp(curTour(j),curTour(j+1))=1;
           end
           App(i,:)=temp(indicator);
           bpp(i)=length(curTour)-2;
       end
    end
    A=[A;App];
    b=[b;bpp];
end
iterRound
curTour=subTours{1};
nodeList=curTour;

% idPath为边的id列表
for i=1:length(curTour)-1
    idPath(i)=idMatrix(curTour(i),curTour(i+1));
end
% 标号-1 
nodeList=nodeList-1;
% nodeList
% 通过判断主线上必经点的个数是否等于必经点总数判断解是否正确
trueSol=(length(intersect(curTour,mustPoints))==mustPointsNum)
time=toc;
end