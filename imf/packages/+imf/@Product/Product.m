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
classdef Product < imf.MultiOperator
    properties(SetAccess='private')
        
    end
    
    methods
        function obj = Product(varargin)
            i = 1;
            one = nargin > 0;
            while i <= nargin
               if isa(varargin{i}, 'numeric')
                   varargin{i} = imf.DoubleConstant(varargin{i});
               end
               varargin{i} = getExpression(varargin{i});
               obj.concatenate(varargin{i});
               
               if varargin{i}.zero
                    obj.zero = 1;
               end
               if ~varargin{i}.one
                    one = 0;
               end
               i = i+1;
            end
            obj.one = one;
            if nargin == 1
                obj.singleTerm = varargin{1}.singleTerm;
            end
        end
        
        function out = copy(obj)
            if isempty(obj.objs)
                out = imf.Product;
            else
                if obj.contra(1)
                    out = 1/copy(obj.objs{1});
                else
                    out = copy(obj.objs{1});
                end
                for i = 2:length(obj.objs)
                    if obj.contra(i)
                        out = out/copy(obj.objs{i});
                    else
                        out = out*copy(obj.objs{i});
                    end
                end
            end
        end
        
        function s = toString(obj)
            strings = obj.sortObjects;
            if obj.zero
                s = '0';
            elseif obj.one
                s = '1';
            else
                num = 1;
                s = '';
                for i = 1:length(obj.objs)
                    if ~isa(obj.objs{i}, 'imf.EmptyWrapper') && ~obj.objs{i}.one
                        if num == 1
                            if obj.contra(i)
                                s = sprintf('1/%s', strings{i});
                            else
                                s = sprintf('%s', strings{i});
                            end
                        else
                            if obj.contra(i)
                                s = [s sprintf('/%s', strings{i})];
                            else
                                s = [s sprintf('*%s', strings{i})];
                            end
                        end
                        num = num+1;
                    end
                end
            end
        end
        
        function jac = jacobian(obj, var)
            if ~isvector(obj)
                error('A jacobian can only be computed of a vector function.');
            end
            for i = 1:length(obj)
                if obj(i).zero || obj(i).one
                    jac(i,:) = zeros(1,length(var));
                else
                    num = 1;
                    for j = 1:length(obj(i).objs)
                        if ~isa(obj(i).objs{j}, 'imf.EmptyWrapper') && ~obj(i).objs{j}.one
                            minus = 0;
                            if obj(i).contra(j)
                                tmpTerm = imf.Expression(jacobian(obj(i).objs{j}, var)./(obj(i).objs{j}*obj(i).objs{j}));
                                minus = 1;
                            else
                                tmpTerm = imf.Expression(jacobian(obj(i).objs{j}, var));
                            end
                            for k = 1:length(obj(i).objs)
                                if k ~= j
                                    if obj(i).contra(k)
                                        tmpTerm = imf.Expression(tmpTerm/obj(i).objs{k});
                                    else
                                        tmpTerm = imf.Expression(tmpTerm*obj(i).objs{k});
                                    end
                                end
                            end
                            if num == 1 && minus
                                jac(i,:) = imf.Expression(-tmpTerm);
                            elseif num == 1
                                jac(i,:) = imf.Expression(tmpTerm);
                            elseif minus
                                jac(i,:) = imf.Expression(jac(i,:) - tmpTerm);
                            else
                                jac(i,:) = imf.Expression(jac(i,:) + tmpTerm);
                            end
                            num = num+1;
                        end
                    end
                end
            end
        end
        
        function out = simplifyLocally(obj)
            obj = eliminatePowers(obj);
            terms = {};
            times = [];
            for i = 1:length(obj.objs)
                found = 0;
                for j = 1:length(terms)
                   if strcmp(terms{j}.toString, obj.objs{i}.toString)
                      found = 1;
                      if obj.contra(i)
                            times(j) = times(j)-1; 
                      else
                            times(j) = times(j)+1; 
                      end
                   end
                end
                if ~found
                   terms{length(terms)+1} = obj.objs{i}.getExpression;
                   times = [times 1-2*obj.contra(i)];
                end
            end
            I = find(times~=0);
            terms = terms(I);
            times = times(I);
            if length(terms) > 1
                out = imf.Product;
                for i = 1:length(terms)
                    if ~isa(terms{i}, 'imf.EmptyWrapper') && ~terms{i}.one
                        if abs(times(i)) ~= 1
                            out = out*simplifyLocally(terms{i}^times(i));
                        else
                            if times(i) > 0
                                out = out*terms{i};
                            else
                                out = out/terms{i};
                            end
                        end
                    end
                end
                out = computeConstants(out.getExpression);
                if isa(out, 'imf.MultiOperator') && length(out.objs) == 1 && ~out.contra
                    out = simplifyLocally(out.objs{1});
                elseif isa(out, 'imf.Product')
                    out = checkDistributivity(out);
                end
            elseif ~isempty(terms)
                if times == 1
                   out = terms{1};
                else
                   out = terms{1}^times;
                end
                out = simplifyLocally(out);
            else
                if isempty(obj.objs)
                    out = imf.DoubleConstant(0);
                else
                    out = imf.DoubleConstant(1);
                end
            end
        end
        
        function out = computeConstants(obj)
           terms = {};
           contra = [];
           constant = 1;
           for i = 1:length(obj.objs)
               if isa(obj.objs{i}, 'imf.DoubleConstant')
                   if obj.contra(i)
                       constant = constant/obj.objs{i}.val;
                   else
                       constant = constant*obj.objs{i}.val;
                   end
               else
                   terms{length(terms)+1} = obj.objs{i}.getExpression;
                   contra = [contra obj.contra(i)];
               end
           end
           if ~isempty(terms)
                out = imf.Product;
                out.objs = terms;
                out.contra = contra;
                if constant ~= 1
                    out.objs{length(out.objs)+1} = imf.DoubleConstant(constant);
                    out.contra = [out.contra 0];
                end
                
                out.zero = obj.zero;
                out.one = obj.one;
                if length(out.objs) == 1
                    out.singleTerm = out.objs{1}.singleTerm;
                end
            else
                out = imf.DoubleConstant(constant);
            end
        end
        
        function out = checkDistributivity(obj)
            add = 0;
            single = 1;
            for i = 1:length(obj.objs)
                if isa(obj.objs{i},'imf.Addition') && ~add
                    add = i;
                else
                    single = single*(obj.objs{i}.singleTerm);
                end
            end
            
            if add && single && length(obj.objs) >= 2
                out = copy(obj.objs{add});
                out = out.getExpression;
                for i = 1:length(obj.objs{add}.objs)
                    for j = 1:length(obj.objs)
                        if j ~= add && obj.contra(j)
                            out.objs{i} = out.objs{i}/obj.objs{j};
                        elseif j ~= add
                            out.objs{i} = out.objs{i}*obj.objs{j};
                        end
                    end
                end
            else
                out = obj;
            end
        end
        
        function sign = eliminateSign(obj)
            sign = 0;
            for i = 1:length(obj.objs)
                if isa(obj.objs{i}, 'imf.DoubleConstant')
                    if obj.objs{i}.val < 0
                        setToAbsoluteValue(obj.objs{i});
                        sign = sign+1;
                    end
                end
            end
        end
        
        function out = eliminatePowers(obj)
            out = obj;
            keep = ones(1,length(obj.objs));
            extra = {};
            times = [];
            contra = [];
            for i = 1:length(obj.objs)
                if isa(obj.objs{i}, 'imf.Power') && isa(obj.objs{i}.obj2, 'imf.DoubleConstant') && (round(obj.objs{i}.obj2.val) == obj.objs{i}.obj2.val)
                    keep(i) = 0;
                    extra{length(extra)+1} = obj.objs{i}.obj1;
                    times = [times abs(obj.objs{i}.obj2.val)];
                    contra = [contra mod(obj.contra(i)+(obj.objs{i}.obj2.val < 0),2)];
                end
            end
            out.objs = obj.objs(find(keep));
            out.contra = obj.contra(find(keep));
            for i = 1:length(extra)
                for j = 1:times(i)
                    out.objs{length(out.objs)+1} = extra{i};
                    out.contra = [out.contra contra(i)];
                end
            end
        end
    end
    
end

