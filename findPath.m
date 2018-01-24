function  [fmin,idPath,trueSol,iterRound,time]=findPath(topo,demand  )
tic;
topo=load(topo);
% demand.csv �е� | ��Ҫ���滻�ɿո�
% demand=load('demand.csv');
demand=textread(demand,'','delimiter',',|');
% ��һ����Ϊmatla�����±��1��ʼ.
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
        %id���ٽ�����д洢��id��0��ʼ
        idMatrix(row,col)=topo(i,1);
    end
end

indicator=(idMatrix~=-1);
edgeNum=length(find(idMatrix~=-1));
% ȡindicatorΪ1�ĵط� adjMatrix��Ӧ��ֵ�����е�ֵ������������1ά����.
f=adjMatrix(indicator);
aeSize=vN+mustPointsNum+2;
% ���Լ������1��ÿ����ĳ����֮� ��ʼ�㣬�ؾ���ĳ���  ��  vN+mustPointsNum+2��
% Ae . x=be;
Ae=zeros(aeSize,edgeNum);
be=zeros(aeSize,1);
% �����֮���Լ��
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
% ����Լ������
% vList ������ʼ��ͱؾ���
vList=demand+1;
for i=1:length(vList);
    v=vList(i);
    temp=zeros(vN,vN);
    temp(v,:)=1;
%     ǰ���Ѿ��й�vN��Լ������.
    Ae(i+vN,:)=temp(indicator);
    if(v==startPoint)
        be(i+vN)=1;
    else if(v==endPoint)
            be(i+vN)=0;
        else
%             �ؾ���
            be(i+vN)=1;
        end
    end
end
% ����Լ������ A . X<=b;
% ����Լ������: ���ڱؾ��㣬��ʼ��֮��ĵ� ����<=1;
aneSize=vN-mustPointsNum-2;
A=zeros(aneSize,edgeNum);
b=ones(aneSize,1);
offset=1;
for i=1:vN
%     �ж��Ƿ��ǷǱؾ���
    if(isempty(find(vList==i, 1)))
        temp=zeros(vN,vN);
        temp(i,:)=1;
        A(offset,:)=temp(indicator);
        offset=offset+1;
    end
end
% ��������бߵ� ��㣬�յ������
ids=zeros(length(f),2);
[ids(:,1),ids(:,2)]=find(idMatrix~=-1);
% ������½� [0,1]
lb=zeros(edgeNum,1);
ub=ones(edgeNum,1);
% ����������mps�ļ��Ĳ���.
% VarNameFun = @(m) (['var' int2str(m)]);
% returning varname 'x', 'y' 'z'
%  BuildMPS(A, b, Ae,be, f,lb,ub,'Pbtest','VarNameFun',VarNameFun,'Binary',[1:edgeNum],'MPSfilename','Pbtest.mps');
% ���
iterRound=0;
toc;
% tic;
options = optimoptions('intlinprog','Display','off');
while(true)
    [x,fmin]=intlinprog(f,1:edgeNum,A,b,Ae,be,lb,ub,options);
    iterRound=iterRound+1;
    if(isempty(x))
        disp('�޽�');
        idPath=[];
        trueSol=0;
        time=toc;
        return;
    end
%     ���ؼ������л�����㵽�յ�·�����б�, subTours{1} Ϊ��㵽�յ��·��.
    subTours=mdetectSubtours(x,ids,startPoint,endPoint);
    numTours=length(subTours);
    if(numTours==1)
        break;
    end
%     ���ӵĲ���Լ��������ÿһ���������е�ĳ���֮��<=����-1��
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

% idPathΪ�ߵ�id�б�
for i=1:length(curTour)-1
    idPath(i)=idMatrix(curTour(i),curTour(i+1));
end
% ���-1 
nodeList=nodeList-1;
% nodeList
% ͨ���ж������ϱؾ���ĸ����Ƿ���ڱؾ��������жϽ��Ƿ���ȷ
trueSol=(length(intersect(curTour,mustPoints))==mustPointsNum)
time=toc;
end