function [expr, vars] = optimizeModel(expr, level)
vars = [];

if level == 0
    return;
end

% find function calls e.g. cos(q1) and replace by e1, e2, ...
for i=1:length(expr)
    matches = regexp(expr{i}, '(?<=(?:[+\-*\/]))([a-zA-Z]+\([^\)]*\))', 'match');
    vars = [vars unique(matches, 'stable')];
    vars = unique(vars, 'stable');
end

for i=1:length(expr)
    for j=1:length(vars)
        expr{i} = strrep(expr{i}, vars{j}, ['e' num2str(j)]);
    end
end

if level > 1
    for i=1:length(expr)
        expr{i} = strrep(expr{i}, '-(-1)*', '+');
        expr{i} = strrep(expr{i}, '+(-1)*', '-');
    end
end

if level > 2
    j0 = 0;
    while j0 < length(vars)
        j0 = length(vars);
        
        for i=1:length(expr)
            matches = regexp(expr{i}, '(?<=\()[^()]*(?=\))', 'match');
            vars = [vars unique(matches, 'stable')];
            vars = unique(vars, 'stable');
        end
        
        for i=1:length(expr)
            for j=j0+1:length(vars)
                expr{i} = strrep(expr{i}, ['(' vars{j} ')'], ['e' num2str(j)]);
            end
        end
    end
end
end

function [var] = simplifySymbolic(expr, var)
syms(expr);
try
    res = eval(var);
    var = simplify(res);
catch
end
end