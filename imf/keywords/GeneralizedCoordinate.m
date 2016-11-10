function GeneralizedCoordinate( varargin )
%GENERALIZEDCOORDINATE Summary of this function goes here
%   Detailed explanation goes here

if ~iscellstr( varargin ),
    error( 'Syntax is: DifferentialState x' );
    
else
    
    for k = 1 : nargin,
        [name N M] = readVariable(varargin{k});
        
        for i = 1:N
            for j = 1:M
                if N > 1
                    VAR_NAME = strcat(name,num2str(i));
                else
                    VAR_NAME = name;
                end
                if M > 1
                    VAR_NAME = strcat(VAR_NAME,num2str(j));
                end
                VAR_ASSIGN = imf.GeneralizedCoordinate(VAR_NAME);
                var(i,j) = VAR_ASSIGN;
                
                assignin( 'caller', VAR_NAME, VAR_ASSIGN );
            end
        end
        assignin( 'caller', name, var );
        var = VAR_ASSIGN;
    end
    
end

end