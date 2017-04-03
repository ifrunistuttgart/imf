%  Licence:
%    This file is part of iFR Modelling Framework  - (http://www.ifr.uni-stuttgart.de)
%
%    IMF -- A framework for modelling dynamic mechanical systems in MATLAB.
%    Copyright (C) 2016-2017 by Pascal Gross <pascal.gross@ifr.uni-stuttgart.de>.
%    Developed within the Flight Mechanics and Controls Lab of the
%    University of Stuttgart. All rights reserved.
%
%    IMF is free software; you can redistribute it and/or
%    modify it under the terms of the GNU Lesser General Public
%    License as published by the Free Software Foundation; either
%    version 3 of the License, or (at your option) any later version.
%
%    IMF is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%    Lesser General Public License for more details.
%
%    You should have received a copy of the GNU Lesser General Public
%    License along with ACADO Toolkit; If not, see <http://www.gnu.org/licenses/>.
%
%    Author: Pascal Gross <pascal.gross@ifr.uni-stuttgart.de>
%    Date: 2017

%    This File contains modified source code from the ACADO Toolkit.

%  Licence:
%    This file is part of ACADO Toolkit  - (http://www.acadotoolkit.org/)
%
%    ACADO Toolkit -- A Toolkit for Automatic Control and Dynamic Optimization.
%    Copyright (C) 2008-2009 by Boris Houska and Hans Joachim Ferreau, K.U.Leuven.
%    Developed within the Optimization in Engineering Center (OPTEC) under
%    supervision of Moritz Diehl. All rights reserved.
%
%    ACADO Toolkit is free software; you can redistribute it and/or
%    modify it under the terms of the GNU Lesser General Public
%    License as published by the Free Software Foundation; either
%    version 3 of the License, or (at your option) any later version.
%
%    ACADO Toolkit is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%    Lesser General Public License for more details.
%
%    You should have received a copy of the GNU Lesser General Public
%    License along with ACADO Toolkit; if not, write to the Free Software
%    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
%
%    Author: David Ariens, Rien Quirynen
%    Date: 2012
%
classdef Expression < handle
    properties
        name;
        
        zero = 0;
        one = 0;
        
        singleTerm = 0;
        
        expr;
    end
    
    properties(GetAccess = 'private')
        cache@imf.Cache = imf.Cache();
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
                    if strcmp(class(obj1(i,j)), 'imf.Expression')
                        r(i,j) = imf.Dot(obj1(i,j).expr);
                    elseif strcmp(class(obj1(i,j)), 'imf.GeneralizedCoordinate')
                        r(i,j) = imf.Dot(obj1(i,j));
                    end
                end
            end
        end
        
        function r = ddot(obj1, b, dim)
            for i = 1:size(obj1,1)
                for j = 1:size(obj1,2)
                    if isa(obj1(i,j), 'imf.Expression')
                        r(i,j) = imf.Ddot(obj1(i,j).expr);
                    elseif isa(obj1(i,j), 'imf.GeneralizedCoordinate')
                        r(i,j) = imf.Ddot(obj1(i,j));
                    end
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
                    error('ERROR: Invalid imf.Product. Check your dimensions.');
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
                    error('ERROR: Invalid imf.Product. Check your dimensions.');
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
        
        function out = eq(a,b)
            if size(a) ~= size(b)
                error('ERROR: check your dimensions');
            end
            
            if length(a) > 1 || length(b) > 1
                for i=1:size(a,1)
                    for j=1:size(a,2)
                        if a(i,j) ~= b(i,j)
                            out = 0;
                            return;
                        else
                            out = 1;
                        end
                    end
                end
            end
            
            out = strcmp(strtrim(a.toString), strtrim(b.toString));
        end
        
        function out = ne(a,b)
            if size(a) ~= size(b)
                error('ERROR: check your dimensions');
            end
            
            if length(a) > 1 || length(b) > 1
                for i=1:size(a,1)
                    for j=1:size(a,2)
                        if a(i,j) == b(i,j)
                            out = 0;
                            return;
                        else
                            out = 1;
                        end
                    end
                end
            end
            
            out = ~strcmp(strtrim(a.toString), strtrim(b.toString));
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
        
        function out = isempty(obj)
            out = 0;
            
            if length(obj) == 0
                out = 1;
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
                for i=1:size(obj, 1)
                    for j=1:size(obj, 2)
                        out(i,j) = obj(i,j).expr;
                    end
                end
            else
                out = obj;
            end
        end
        
        function jac = jacobian(obj, var)
            
            jac = imf.Expression.empty(length(obj), 0);
            for i = 1:length(obj)
                
                if obj(i).cache.contains('jacobian')
                    jac(i,:) = obj(i).cache.get('jacobian');
                    continue;
                end
                
                for j = 1:length(var)
                    jac(i,j) = imf.Expression(jacobian(obj(i).getExpression, var(j).getExpression));
                end
                
                obj(i).cache.insertOrUpdate('jacobian', jac(i,:));
            end
        end
        
        function out = is(obj)
            out = imf.Expression(imf.IntermediateState(obj));
        end
        
        function out = eval(obj, ws)
            global IMF_;
            if ~isempty(IMF_)
                
                if nargin < 2
                    ws = 'base';
                end
                
                for i = 1:size(obj,1)
                    for j = 1:size(obj,2)
                        tmp = evalin(ws, obj(i,j).toString);
                        %                        if ~isa(tmp, 'imf.Expression')
                        %                            tmp = imf.Expression(tmp);
                        %                        end
                        out(i,j) = tmp;
                    end
                end
            else
                error('Unsupported use of the eval function.');
            end
        end
        
        function [ex, vars, params] = symbolic(obj)
            global IMF_
            
            vars = sym.empty(0, 1);
            for i = 1:length(IMF_.helper.x)
                eval(['syms imf_q' IMF_.helper.x{i}.name '(t)']);
                eval(['vars(i,1) = imf_q' IMF_.helper.x{i}.name ';']);
            end
            
            params = sym.empty(0, 1);
            for i = 1:length(IMF_.helper.param)
                eval(['syms imf_p' IMF_.helper.param{i}.name]);
                eval(['params(i,1) = imf_p' IMF_.helper.param{i}.name ';']);
            end
            
            tmp = [];
            for i = 1:length(obj)
                tmp{i} = obj(i).expr.toString;
                
                for j = 1:length(IMF_.helper.x)
                    tmp{i} = regexprep(tmp{i}, ['(?<!(?:[a-zA-Z0-9\_]))(ddot\(' IMF_.helper.x{j}.name '\))(?!(?:[a-zA-Z0-9]+))'], ['diff(imf_q' IMF_.helper.x{j}.name '(t), t, t)']);
                    tmp{i} = regexprep(tmp{i}, ['(?<!(?:[a-zA-Z0-9\_]))(dot\(' IMF_.helper.x{j}.name '\))(?!(?:[a-zA-Z0-9]+))'], ['diff(imf_q' IMF_.helper.x{j}.name '(t), t)']);
                    tmp{i} = regexprep(tmp{i}, ['(?<!(?:[a-zA-Z0-9\_]))(' IMF_.helper.x{j}.name ')(?!(?:[a-zA-Z0-9]+))'], ['imf_q' IMF_.helper.x{j}.name]);
                end
                
                for j = 1:length(IMF_.helper.param)
                    % replace variable if it does not have a leading or
                    % trailing alphanumeric symbol
                    tmp{i} = regexprep(tmp{i}, ['(?<!(?:[a-zA-Z0-9\_]))(' IMF_.helper.param{j}.name ')(?!(?:[a-zA-Z0-9]+))'], ['imf_p' IMF_.helper.param{j}.name]);
                end
            end
            
            for i=1:length(tmp)
                ex(i,1) = eval(tmp{i});
            end
        end
        
        function out = functionalDerivative(obj, var)
            out = imf.Expression.empty(length(obj), 0);
            
            global IMF_
            
            symsex = 'syms t';
            for j = 1:length(var)
                %symsex = [symsex ' ' var(j).expr.name '(t)'];
                symsex = [symsex ' imf_q' num2str(j) '(t)'];
            end
            eval(symsex);
            
            symsex = 'syms';
            for j = 1:length(IMF_.helper.param)
                symsex = [symsex ' imf_p' num2str(j)];
            end
            eval(symsex);
            
            for i = 1:length(obj)
                ex = obj(i).expr.toString;
                
                for j = 1:length(var)
                    ex = regexprep(ex, ['(?<!(?:[a-zA-Z0-9\_]))(dot\(' var(j).expr.name '\))(?!(?:[a-zA-Z0-9]+))'], ['diff(imf_q' num2str(j) '(t), t)']);
                    ex = regexprep(ex, ['(?<!(?:[a-zA-Z0-9\_]))(' var(j).expr.name ')(?!(?:[a-zA-Z0-9]+))'], ['imf_q' num2str(j)]);
                end
                
                for j = 1:length(IMF_.helper.param)
                    % replace variable if it does not have a leading or
                    % trailing alphanumeric symbol
                    ex = regexprep(ex, ['(?<!(?:[a-zA-Z0-9\_]))(' IMF_.helper.param{j}.name ')(?!(?:[a-zA-Z0-9]+))'], ['imf_p' num2str(j)]);
                end
                
                ex = eval(ex);
                dex = diff(ex, t);
                
                d = char(dex);
                for j = 1:length(var)
                    d = strrep(d, ['diff(imf_q' num2str(j) '(t), t)'], ['dot(imf_q' num2str(j) '(t))']);
                    d = strrep(d, ['diff(imf_q' num2str(j) '(t), t, t)'], ['ddot(imf_q' num2str(j) '(t))']);
                    d = strrep(d, ['imf_q' num2str(j) '(t)'], ['var(' num2str(j) ')']);
                end
                
                for j = 1:length(IMF_.helper.param)
                    d = strrep(d, ['imf_p' num2str(j)], ['IMF_.helper.param{' num2str(j) '}']);
                end
                
                d = regexprep(d, '(?<!(?:[a-zA-Z0-9]))(t)(?!(?:[a-zA-Z0-9]+))', 'IMF_.t');
                out(i) = eval(d);
            end
            
            if size(obj, 1) > size(obj, 2)
                out = out';
            end
        end
        
        function matlabFunction(obj, filename)
            
            [eqs, vars, params] = obj.symbolic;
            [newEqs, newVars] = reduceDifferentialOrder(eqs, vars);
            newEqs = simplify(newEqs);
            [M, F] = massMatrixForm(newEqs, newVars);
            odeFunction(M, newVars, params, 'File', [filename 'M']);
            odeFunction(F, newVars, params, 'File', [filename 'F']);
            
            disp('======================== DONE =========================')
            disp('Generation for MATLAB function completed.')
            disp(['Two functions have been created: @' [filename 'M'] '(t,q,params) and @' [filename 'F'] '(t,q,params).'])
            disp('The states are:')
            for i=1:length(newVars)
                disp(['  Parameter ' num2str(i) ': ' regexprep(char(newVars(i)), '(imf\_.)', '')]);
            end
            disp('The function parameters are:')
            for i=1:length(params)
                disp(['  Parameter ' num2str(i) ': ' regexprep(char(params(i)), '(imf\_.)', '')]);
            end
            disp('=======================================================')
            
        end
    end
    
end
