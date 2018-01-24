function subTours = mdetectSubtours(x,idxs,startPoint,endPoint)
% Returns a cell array of subtours. The first subtour is the first row of x, etc.

%   Copyright 2014 The MathWorks, Inc. 

x = round(x); % correct for not-exactly integers
r = find(x); % indices of the trips that exist in the solution
substuff = idxs(r,:); % the collection of node pairs in the solution
unvisited = ones(length(r),1); % keep track of places not yet visited
curr = 1; % subtour we are evaluating
startour = find(substuff(:,1) == startPoint); % first unvisited trip
    while ~isempty(startour)
        home = substuff(startour,1); % starting point of subtour
        nextpt = substuff(startour,2); % next point of tour
        visited = nextpt; unvisited(startour) = 0; % update unvisited points
        while (nextpt ~= home&&nextpt~=endPoint)
            % Find the other trips that starts at nextpt
            srow= find(substuff(:,1) == nextpt);
%             % Find just the new trip
%             trow = srow(srow ~= startour);
%             scol = 3-scol(trow == srow); % turn 1 into 2 and 2 into 1
            startour = srow; % the new place on the subtour
            nextpt = substuff(startour,2); % the point not where we came from
            visited = [visited,nextpt]; % update nodes on the subtour
            unvisited(startour) = 0; % update unvisited
        end
        if(nextpt==endPoint)
            visited=[startPoint,visited];
        end
%         这条路尽头是终点，说明不是环.
        subTours{curr} = visited; % store in cell array
        curr = curr + 1; % next subtour
        startour = find(unvisited,1); % first unvisited trip
    end
    
end

