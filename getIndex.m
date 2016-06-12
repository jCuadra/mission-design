function [varargout] = getIndex(varargin)

switch nargin
    
    case 7
        
        ind_1 = varargin{1};
        ind_2 = varargin{2};
        ind_3 = varargin{3};
        ind_4 = varargin{4};
        n = varargin{5};
        n3 = varargin{6};
        t2_ind = varargin{7};
        
        x_ind1 = n*n3*(ind_1-1);
        x_ind2 = n3*(ind_2-1);
        x_ind3 = sum(t2_ind(1:ind_3-1));
        x_ind4 = ind_4;
        
        varargout{1} = x_ind1+x_ind2+x_ind3+x_ind4;
        
    case 4
        
        x_ind = varargin{1};
        n = varargin{2};
        n3 = varargin{3};
        t2_ind = varargin{4};
        
        % Define time vector used for GetIndex
        % find more efficient scan
        t2_sum = zeros(size(t2_ind));
        for sum_c = 1:length(t2_ind)
            t2_sum(sum_c) = sum(t2_ind(1:sum_c));
        end
        
        x_ind1 = n*n3;
        ind_1 = fix((x_ind-1)/x_ind1);
        x_ind = x_ind-ind_1*x_ind1;
        
        x_ind2 = n3;
        ind_2 = fix((x_ind-1)/x_ind2);
        x_ind = x_ind-ind_2*x_ind2;
        
        ind_3 = find(x_ind>t2_sum,1,'last');
        if isempty(ind_3)
            ind_3 = 0;
        else
            x_ind = x_ind-t2_sum(ind_3);
        end
        
        ind_4 = x_ind;
        
        varargout{1} = ind_1+1;
        varargout{2} = ind_2+1;
        varargout{3} = ind_3+1;
        varargout{4} = ind_4;
        
end


end