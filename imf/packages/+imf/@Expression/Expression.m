classdef Expression < handle
    properties
        name;
        
        zero = 0;
        one = 0;
        
        singleTerm = 0;
        
        expr;
    end
    
    methods
        function obj = Expression( in )
            if nargin > 0
                for i = 1:size(in,1)
                    for j = 1:size(in,2)
                        if isa(in(i,j), 'numeric')
                            obj(i,j).expr = imf.DoubleConstant(in(i,j));
                        else
                            obj(i,j).expr = in(i,j).getExpression;
                        end
                    end
                end
            end
        end
        
        function out = copy(obj)
            if strcmp(class(obj), 'imf.Expression')
                out = imf.Expression(copy(obj.expr));
            else
                error(['Undefined copy constructor for class ' class(obj) ' !']);
            end
        end
        
        function r = dot(obj1, b, dim)
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.Dot(obj1(i,j));
                end
            end
        end
        
        function r = ddot(obj1, b, dim)
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.Ddot(obj1(i,j));
                end
            end
        end
        
        function r = next(obj1, b, dim)
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.Next(obj1(i,j));
                end
            end
        end
        
        %Matlab help: "Implementing Operators for Your Class"
        
        function r = mtimes(obj1,obj2)    % *
            if length(obj2) == 1
                for i = 1:size(obj1,1)
                    for j = 1:size(obj1,2)
                        r(i,j) = imf.Expression(imf.Product(obj1(i,j),obj2));
                    end
                end
            elseif length(obj1) == 1
                for i = 1:size(obj2,1)
                    for j = 1:size(obj2,2)
                        r(i,j) = imf.Expression(imf.Product(obj2(i,j),obj1));
                    end
                end
            else
                if size(obj1,2) ~= size(obj2,1)
                    error('ERROR: Invalid imf.Product. Check your dimensions..');
                end
                for i = 1:size(obj1,1)
                    for j = 1:size(obj2,2)
                        r(i,j) = imf.Expression(imf.Product(obj1(i,1),obj2(1,j)));
                        for k = 2:size(obj1,2)
                            r(i,j) = imf.Expression(imf.Addition(r(i,j), imf.Product(obj1(i,k),obj2(k,j))));
                        end
                    end
                end
            end
        end
        
        function r = times(obj1,obj2)    % .*
            if length(obj2) == 1
                for i = 1:size(obj1,1)
                    for j = 1:size(obj1,2)
                        r(i,j) = imf.Expression(imf.Product(obj1(i,j),obj2));
                    end
                end
            elseif length(obj1) == 1
                for i = 1:size(obj2,1)
                    for j = 1:size(obj2,2)
                        r(i,j) = imf.Expression(imf.Product(obj2(i,j),obj1));
                    end
                end
            else
                if size(obj1,1) ~= size(obj2,1) || size(obj1,2) ~= size(obj2,2)
                    error('ERROR: Invalid imf.Product. Check your dimensions..');
                end
                for i = 1:size(obj1,1)
                    for j = 1:size(obj1,2)
                        r(i,j) = imf.Expression(imf.Product(obj1(i,j),obj2(i,j)));
                    end
                end
            end
        end
        
        function r = plus(obj1,obj2)      % +
            if size(obj1,1) ~= size(obj2,1) || size(obj1,2) ~= size(obj2,2)
                error('ERROR: Invalid imf.Addition. Check your dimensions..');
            end
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.Expression(imf.Addition(obj1(i,j),obj2(i,j)));
                end
            end
        end
        
        function r = minus(obj1,obj2)     % -
            if size(obj1,1) ~= size(obj2,1) || size(obj1,2) ~= size(obj2,2)
                error('ERROR: Invalid imf.Subtraction. Check your dimensions..');
            end
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.Expression(imf.Subtraction(obj1(i,j),obj2(i,j)));
                end
            end
        end
        
        function r = mrdivide(obj1,obj2)  % /
            if length(obj2) == 1
                for i = 1:size(obj1,1)
                    for j = 1:size(obj1,2)
                        r(i,j) = imf.Expression(imf.Quotient(obj1(i,j),obj2));
                    end
                end
            else
                if numel(obj1) > 1 || numel(obj2) > 1
                    error('ERROR: Invalid division !');
                end
                r = imf.Quotient(obj1,obj2);
            end
        end
        
        function r = rdivide(obj1,obj2)    % ./
            if length(obj2) == 1
                for i = 1:size(obj1,1)
                    for j = 1:size(obj1,2)
                        r(i,j) = imf.Expression(imf.Quotient(obj1(i,j),obj2));
                    end
                end
            else
                if size(obj1,1) ~= size(obj2,1) || size(obj1,2) ~= size(obj2,2)
                    error('ERROR: Invalid imf.Quotient. Check your dimensions..');
                end
                for i = 1:size(obj1,1)
                    for j = 1:size(obj1,2)
                        r(i,j) = imf.Expression(imf.Quotient(obj1(i,j),obj2(i,j)));
                    end
                end
            end
        end
        
        function r = uminus(obj1)         % -
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.Expression(imf.Subtraction(imf.DoubleConstant(0),obj1(i,j)));
                end
            end
        end
        
        function r = uplus(obj1)          % +
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.Expression(obj1(i,j));
                end
            end
        end
        
        function r = mpower(obj1, obj2)   % ^
            if numel(obj1) > 1 || numel(obj2) > 1
                error('ERROR: Invalid power !');
            end
            r = imf.Power(obj1,obj2);
        end
        
        function r = power(obj1, obj2)   % .^
            if length(obj2) == 1
                for i = 1:size(obj1,1)
                    for j = 1:size(obj1,2)
                        r(i,j) = imf.Expression(imf.Power(obj1(i,j),obj2));
                    end
                end
            else
                if size(obj1,1) ~= size(obj2,1) || size(obj1,2) ~= size(obj2,2)
                    error('ERROR: Invalid imf.Power. Check your dimensions..');
                end
                for i = 1:size(obj1,1)
                    for j = 1:size(obj1,2)
                        r(i,j) = imf.Expression(imf.Power(obj1(i,j),obj2(i,j)));
                    end
                end
            end
        end
        
        function r = eq(obj1, obj2)       % ==
            if isnumeric(obj1) && length(obj1) == 1
                obj1 = obj1*ones(size(obj2));
            elseif isnumeric(obj2) && length(obj2) == 1
                obj2 = obj2*ones(size(obj1));
            end
            if isa(obj1, 'imf.Variable') && length(obj1) == 1 && size(obj2,2) == 2  % special case of a VariablesGrid
                r = imf.Equals(obj1,obj2);
            else
                if size(obj1,1) ~= size(obj2,1) || size(obj1,2) ~= size(obj2,2)
                    error('ERROR: Invalid imf.Equals. Check your dimensions..');
                end
                for i = 1:size(obj1,1)
                    for j = 1:size(obj1,2)
                        r(i,j) = imf.Equals(obj1(i,j),obj2(i,j));
                    end
                end
            end
        end
        
        function r = lt(obj1, obj2)       % <
            if isnumeric(obj1) && length(obj1) == 1
                obj1 = obj1*ones(size(obj2));
            elseif isnumeric(obj2) && length(obj2) == 1
                obj2 = obj2*ones(size(obj1));
            end
            if size(obj1,1) ~= size(obj2,1) || size(obj1,2) ~= size(obj2,2)
                error('ERROR: Invalid imf.LessThan. Check your dimensions..');
            end
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.LessThan(obj1(i,j),obj2(i,j));
                end
            end
        end
        
        function r = le(obj1, obj2)       % <=
            if isnumeric(obj1) && length(obj1) == 1
                obj1 = obj1*ones(size(obj2));
            elseif isnumeric(obj2) && length(obj2) == 1
                obj2 = obj2*ones(size(obj1));
            end
            if size(obj1,1) ~= size(obj2,1) || size(obj1,2) ~= size(obj2,2)
                error('ERROR: Invalid imf.LessThanEqual. Check your dimensions..');
            end
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.LessThanEqual(obj1(i,j),obj2(i,j));
                end
            end
        end
        
        function r = gt(obj1, obj2)       % >
            if isnumeric(obj1) && length(obj1) == 1
                obj1 = obj1*ones(size(obj2));
            elseif isnumeric(obj2) && length(obj2) == 1
                obj2 = obj2*ones(size(obj1));
            end
            if size(obj1,1) ~= size(obj2,1) || size(obj1,2) ~= size(obj2,2)
                error('ERROR: Invalid imf.GreaterThan. Check your dimensions..');
            end
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.GreaterThan(obj1(i,j),obj2(i,j));
                end
            end
        end
        
        function r = ge(obj1, obj2)       % >=
            if isnumeric(obj1) && length(obj1) == 1
                obj1 = obj1*ones(size(obj2));
            elseif isnumeric(obj2) && length(obj2) == 1
                obj2 = obj2*ones(size(obj1));
            end
            if size(obj1,1) ~= size(obj2,1) || size(obj1,2) ~= size(obj2,2)
                error('ERROR: Invalid imf.GreaterThanEqual. Check your dimensions..');
            end
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.GreaterThanEqual(obj1(i,j),obj2(i,j));
                end
            end
        end
        
        function r = exp(obj1)            % exp
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.Exp(obj1(i,j));
                end
            end
        end
        
        function r = sqrt(obj1)            % sqrt
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.SquareRoot(obj1(i,j));
                end
            end
        end
        
        function r = acos(obj1)           % acos
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.Acos(obj1(i,j));
                end
            end
        end
        
        function r = asin(obj1)           % asin
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.Asin(obj1(i,j));
                end
            end
        end
        
        function r = atan(obj1)           % atan
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.Atan(obj1(i,j));
                end
            end
        end
        
        function r = cos(obj1)            % cos
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.Cos(obj1(i,j));
                end
            end
        end
        
        function r = sin(obj1)            % sin
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.Sin(obj1(i,j));
                end
            end
        end
        
        function r = tan(obj1)            % tan
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.Tan(obj1(i,j));
                end
            end
        end
        
        function r = log(obj1)            % log
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    r(i,j) = imf.Logarithm(obj1(i,j));
                end
            end
        end
        
        function s = toString(obj)
            if ~isempty(obj.expr)
                s = obj.expr.toString;
            else
                s = obj.name;
            end
        end
        
        function result = checkDoubleVectorMatrix(obj, r)
            
            if (isa(r, 'imf.Expression'))
                result = r;
                
            else
                [m n] = size(r);
                
                if( m == 1 && n == 1)
                    result = imf.DoubleConstant(r);
                elseif( (m == 1 && n >= 1) || (m >= 1 && n == 1) )
                    result = imf.Vector(r);
                else
                    result = imf.Matrix(r);
                end
            end
            
        end
        
        function C = vertcat(varargin)
            temp = varargin{1};
            for i = 1:size(temp,1)
                for j = 1:size(temp,2)
                    if isa(temp(i,j), 'numeric')
                        C(i,j) = imf.Expression(imf.DoubleConstant(temp(i,j)));
                    else
                        C(i,j) = imf.Expression(temp(i,j));
                    end
                end
            end
            for k = 2:nargin,
                temp = varargin{k};
                if isempty(varargin{1})
                    base = 0;
                else
                    base = size(C,1);
                end
                for i = 1:size(temp,1)
                    for j = 1:size(temp,2)
                        if isa(temp(i,j), 'numeric')
                            C(base+i,j) = imf.Expression(imf.DoubleConstant(temp(i,j)));
                        else
                            C(base+i,j) = imf.Expression(temp(i,j));
                        end
                    end
                end
            end
        end
        
        function C = horzcat(varargin)
            temp = varargin{1};
            for i = 1:size(temp,1)
                for j = 1:size(temp,2)
                    if isa(temp(i,j), 'numeric')
                        C(i,j) = imf.Expression(imf.DoubleConstant(temp(i,j)));
                    else
                        C(i,j) = imf.Expression(temp(i,j));
                    end
                end
            end
            for k = 2:nargin,
                temp = varargin{k};
                base = size(C,2);
                for i = 1:size(temp,1)
                    for j = 1:size(temp,2)
                        if isa(temp(i,j), 'numeric')
                            C(i,base+j) = imf.Expression(imf.DoubleConstant(temp(i,j)));
                        else
                            C(i,base+j) = imf.Expression(temp(i,j));
                        end
                    end
                end
            end
        end
        
        function display(x)
            fprintf('\n%s = \n\n', inputname(1));
            for i = 1:size(x,1)
                for j = 1:size(x,2)
                    fprintf('%s ', toString(x(i,j)));
                end
                fprintf('\n');
            end
            fprintf('\n');
        end
        
        function out = ctranspose(in)
            out = transpose(in);
        end
        
        function out = transpose(in)
            for i = 1:size(in,1)
                for j = 1:size(in,2)
                    out(j,i) = in(i,j);
                end
            end
        end
        
        function out = sum(in, varargin)
            if nargin == 1
                out = sum(in(:),1);
            elseif nargin == 2
                if varargin{1} == 1
                    for i = 1:size(in,2)
                        out(1,i) = imf.Expression(in(1,i));
                        for j = 2:size(in,1)
                            out(1,i) = imf.Expression(imf.Addition(out(1,i), in(j,i)));
                        end
                    end
                elseif varargin{1} == 2
                    for i = 1:size(in,1)
                        out(i,1) = imf.Expression(in(i,1));
                        for j = 2:size(in,2)
                            out(i,1) = imf.Expression(imf.Addition(out(i,1), in(i,j)));
                        end
                    end
                else
                    error('Unsupported use of the sum function in imf.Expression.');
                end
            else
                error('Unsupported use of the sum function in imf.Expression.');
            end
        end
        
        % vector 2-norm only
        function out = norm(in)
            if(size(in,1) > 1 && size(in,2) > 1)
                error('Unsupported use of the 2-norm function in imf.Expression.');
            end
            out = sqrt(sum(in.^2));
        end
        
        function out = MatrixDiff(in,var)
            [n,m] = size(var);
            if length(in) > 1
                error('Dimensions of the input expression not supported.');
            end
            for i = 1:n
                for j = 1:m
                    out(i,j) = jacobian(in,var(i,j));
                end
            end
        end
        
        function D = diag(in)
            if size(in,1) == 1 && size(in,2) == 1
                D = in;
            elseif size(in,1) == 1 || size(in,2) == 1
                for i = 1:length(in)
                    for j = 1:length(in)
                        D(i,j) = imf.Expression(imf.DoubleConstant(0));
                    end
                    D(i,i) = in(i);
                end
            elseif size(in,1) == size(in,2)
                for i = 1:size(in,1)
                    D(i,1) = in(i,i);
                end
            else
                error('Unsupported use of the diag function.')
            end
        end
        
        function out = trace(in)
            out = sum(diag(in));
        end
        
        function out = simplify(obj)
            for i = 1:size(obj,1)
                for j = 1:size(obj,2)
                    out(i,j) = simplifyOne(copy(obj(i,j)));
                end
            end
        end
        
        function out = simplifyOne(obj)
            if length(obj) ~= 1
                error('Unsupported use of the function simplifyOne !');
            end
            changed = 1;
            while(changed && ~obj.singleTerm)
                prevString = toString(obj);
                
                while isa(obj, 'imf.MultiOperator') && length(obj.objs) == 1 && ~obj.contra
                    obj = obj.objs{1};
                end
                obj = simplifyLocally(obj);
                if isa(obj, 'imf.UnaryOperator')
                    obj.obj1 = simplifyOne(obj.obj1);
                    
                elseif isa(obj, 'imf.BinaryOperator')
                    obj.obj1 = simplifyOne(obj.obj1);
                    obj.obj2 = simplifyOne(obj.obj2);
                    
                elseif isa(obj, 'imf.MultiOperator')
                    for k = 1:length(obj.objs)
                        obj.objs{k} = simplifyOne(obj.objs{k});
                    end
                elseif strcmp(class(obj), 'imf.Expression') || isa(obj, 'imf.IntermediateState')
                    obj.expr = simplifyOne(obj.expr);
                end
                
                changed = ~strcmp(toString(obj), prevString);
            end
            out = obj;
        end
        
        function out = simplifyLocally(obj)
            % NOTHING TO BE DONE AT THIS LEVEL
            out = obj;
        end
        
        function out = getExpression(obj)
            if strcmp(class(obj), 'imf.Expression')
                out = obj.expr;
            else
                out = obj;
            end
        end
        
        function jac = jacobian(obj, var)
            for i = 1:length(obj)
                for j = 1:length(var)
                    jac(i,j) = imf.Expression(jacobian(obj(i).getExpression, var(j).getExpression));
                end
            end
        end
        
        function out = is(obj)
            out = imf.Expression(imf.IntermediateState(obj));
        end
        
        function out = eval(obj, varargin) % x, u, z, dx, od, p, w, t
            global IMF_;
            if ~isempty(IMF_)
                t = []; x = []; z = []; dx = []; u = []; od = []; p = []; w = [];
                if nargin > 1
                    x = varargin{1};
                    if nargin > 2
                        u = varargin{2};
                        if nargin > 3
                            z = varargin{3};
                            if nargin > 4
                                dx = varargin{4};
                                if nargin > 5
                                    od = varargin{5};
                                    if nargin > 6
                                        p = varargin{6};
                                        if nargin > 7
                                            w = varargin{7};
                                            if nargin > 8
                                                t = varargin{8};
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                for i = 1:size(obj,1)
                    for j = 1:size(obj,2)
                        out(i,j) = evalin('base', obj(i,j).toString);
                    end
                end
            else
                error('Unsupported use of the eval function.');
            end
        end
        
        function out = functionalDerivative(obj, var)
            out = imf.Expression.empty(length(obj), 0);
            
            symsex = 'syms';
            for j = 1:length(var)
                symsex = [symsex ' ' var(j).expr.name '(t)'];
            end
            eval(symsex);
            
            for i = 1:length(obj)
                ex = obj(i).expr.toString;
                
                for j = 1:length(var)                   
                    ex = strrep(ex, ['dot(' var(j).expr.name ')'], ['diff(q' num2str(j) '(t), t)']);
                    ex = strrep(ex, var(j).expr.name, ['q' num2str(j)]);
                end
                
                ex = eval(ex);
                dex = diff(ex, t);
                
                d = char(dex);
                for j = 1:length(var)                    
                    d = strrep(d, ['diff(q' num2str(j) '(t), t)'], ['dot(q' num2str(j) '(t))']);
                    d = strrep(d, ['diff(q' num2str(j) '(t), t, t)'], ['ddot(q' num2str(j) '(t))']);
                    d = strrep(d, ['q' num2str(j) '(t)'], 'var(j)');
                end
                
                out(i) = eval(d);
            end
            out = eval(out);
        end
        
    end
    
end
