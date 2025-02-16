
function [X,A,B,RMSE] = MOD_2D(Y,a,b,iter,sparsity,A0,B0)

%==========================================================================
%   INPUTS:
%   Y:                      2D Training Data
%   a:                      Atom numbers of A
%   b:                      Atom numbers of B
%   iter:                   Algorithm iterations
%   Sparsity:               Target sparsity     
%==========================================================================
%==========================================================================
%   OUTPUTS:  (All saved w.r.t each iteraion)
%   X:                      Sparse Representation
%   A:                      Left  Dictionary 
%   B:                      Right Dictionary
%   D:                      Kronecker dictionary
%   time:                   Time
%==========================================================================

[m,n,T]  = size(Y);
% A0       = randn(m,a);
% A0       = normc(A0);
% B0       = randn(n,b);
% B0       = normc(B0);
lambda   = 1e-3;
A        = zeros(m,a,iter);
B        = zeros(n,b,iter);
X        = zeros(a,b,T);
RMSE     = zeros(1,iter);
Res      = zeros(m,n,T);

for it = 1:iter
    % Step 1 : Sparse Coding (OMP_2D)
    
    C1       = A0'*A0;
    C2       = B0'*B0;   
    parfor i = 1:T
           X(:,:,i) = OMP_2D_Sp(Y(:,:,i),A0,B0,sparsity,C1,C2);  
    end  
    
    % Compute RMSE
    for i=1:T
        Res(:,:,i) = Y(:,:,i)-A0*X(:,:,i)*B0';
    end
    error        = sum(Res(:).^2);
    RMSE(it)     = sqrt(error/(m*n*T));
        
    % Step2 : computing dictionary A
    
    sig1  = zeros(m,a);
    sig2  = zeros(a,a);
    for i = 1:T
        temp = B0*(X(:,:,i)');
        tmp1 = Y(:,:,i)*temp;
        tmp2 = temp'*temp;
        sig1 = sig1 + tmp1;
        sig2 = sig2 + tmp2;
    end
    A0 = sig1/(sig2+lambda*eye(size(sig2)));
    A0 = normc(A0);
    
    % Step3 : computing dictionary B
    
    sig3  = zeros(n,b);
    sig4  = zeros(b,b);
    for i = 1:T
        temp = A0*X(:,:,i);
        tmp3 = (Y(:,:,i)')*temp;
        tmp4 = temp'*temp;
        sig3 = sig3 + tmp3;
        sig4 = sig4 + tmp4;
    end
    B0 = sig3/(sig4+lambda*eye(size(sig4)));
    B0 = normc(B0);
    
    A(:,:,it)    = A0;
    B(:,:,it)    = B0;
    
    
end  
end

