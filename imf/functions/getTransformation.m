function [ T ] = getTransformation( from, to )
global IMF_;

T = nan;

for i=1:length(IMF_.transformations)
    t = IMF_.transformations(i);
    if t.from == from && t.to == to
        T = t;
        return;
    elseif t.from == to && t.to == from
        T = t';
        return;
    end
end

% there was no direct transformation, try to find a chain
chain = imf.Transformation.empty;
while isempty(chain) || chain(end).from ~= from
    
    if ~isempty(chain)
        curto = chain(end).from;
        
        for i=1:length(IMF_.transformations)
            t = IMF_.transformations(i);
            % make sure to prevent circular dependencies
            % therefore don't add transformations resulting in something
            % already in the chain
            if t.to == curto && t.from ~= chain(end).to
                chain(end+1) = t;
            elseif t.from == curto && t.to ~= chain(end).to
                chain(end+1) = t';
            end
            
            if chain(end).from == from
                break;
            end
        end
        
    else
        
        for i=1:length(IMF_.transformations)
            t = IMF_.transformations(i);
            if t.to == to
                chain(end+1) = t;
                break;
            elseif t.from == to
                chain(end+1) = t';
                break;
            end
        end
        
        if isempty(chain)
            break;
        end
        
    end
end

if ~isempty(chain)
    T = imf.TransformationChain(chain(end).from, chain(1).to);   
    T.transformations = chain;
end

if ~isobject(T) && isnan(T)
    error(['No transformation from ' from.name ' to ' to.name ' could be found.']);
end
end