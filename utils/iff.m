function res=iff(condition,truestatement,falsestament,vargin)
res = {};
switch nargin
    case 2 
        if condition
            res = truestatement;           
        end
    case 3
        if condition
            res = truestatement;
        else
            res = falsestament;
        end
    otherwise
        display(vargin)
end