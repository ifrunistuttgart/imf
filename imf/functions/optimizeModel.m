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

if level > 3
    for j=1:length(vars)
        vars{j} = regexprep(vars{j}, '^\+', '');
        vars{j} = regexprep(vars{j}, '[+-](?:[^+-]*\*)*0(?!\.)(?:\*[^+-]*)*', '');
    end
end

if level > 4
    % remove terms like e5*e4-e5*e4
    for j=1:length(vars)
        match = regexp(vars{j}, '[+-][^+-]*', 'match');
        if length(match) > 1
            for i=1:length(match)
                sign = regexp(match{i}, '^[+-]', 'match');
                term = regexp(match{i}, '(?<=(?:^[+-]))[^+-]*', 'match');
                
                for k=1:length(match)
                    
                    if k==i
                        continue;
                    end
                    
                    compareSign = regexp(match{k}, '^[+-]', 'match');
                    compareTerm = regexp(match{k}, '(?<=(?:^[+-]))[^+-]*', 'match');
                
                    if strcmp(sign{1}, '-')
                        searchSign = '+';
                    else
                        searchSign = '-';
                    end
                    
                    if strcmp(compareSign{1}, searchSign) && strcmp(compareTerm{1}, term{1})
                        vars{j} = strrep(vars{j}, [searchSign term{1}], '');
                        vars{j} = strrep(vars{j}, [sign{1} term{1}], '');
                        break;
                    end
                end
            end
        end
    end
end

end