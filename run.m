function writeFile()
A = [1 1 0; -1 0 -1];
    b = [5; -10];
    L = [0; -1; 0];
    U = [4; +1; +inf];
    Aeq = [0 -1 1];
    beq = 7;
    cost = [1 4 9];
%     VarNameFun = @(m) (['var' int2str(m)]); % returning varname 'x', 'y' 'z'

    Contain = BuildMPS(A, b, Aeq, beq, cost, L, U,
                       'Integer', [1:intNum], ... % first variable 'x' integer
                       'MPSfilename', 'Pbtest.mps');
end