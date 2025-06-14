function [output] = weighted_mean(typeMean,varargin)
%WEIGHTED_MEAN  Calculates weighted means of input value and weight vectors.
%   [output] = weighted_mean(typeMean,varargin)
%
%   This function calculates three types of weighted means: arithmetic,
%   geometric, and harmonic.  It differes from the built-in MATLAB function
%   'mean' in that the individual values are weighted differently than 1.
%   Also, this function can take the mean across a number of input arrays
%   of arbitrary dimensions.
%
%   There are two modes of operation:
%   1) If there is only one input array and weight array, the user can
%   optionally specify the dimension across which to take the weighted mean.
%   If none is specified, it is assumed to be "1".  Alternately, by specifying
%   the option 'all', the arrays are flattened, and a scalar value is returned.
%   For example, an array of size (mxnxo) is input.  This array is flattened into
%   size (1,m*n*o), and then the weighted mean taken across the 2nd
%   dimension.  The input value and weight array can be of completely
%   arbitrary dimension.
%
%   2)If there are N (mxn) size values arrays are input along with N (mxn) 
%   size weight arrays.  The output will be of size (mxn) with each element
%   representing the weighted mean of all the N
%   cells in that position across the input arrays.  Another way to think
%   of this is that the input arrays are turned into a single array of size
%   (mxnxN) and the weighted mean is taken across the third dimension.
%   This is, in fact, what the code does.  The arrays can be of completely
%   aribtrary dimension.
%
%   It is not necessary that the sum of the weights equal one, as the
%   formula used here performs the normalization.  The weights must,
%   however be nonnegative and at least one must be greater than 0.
%
%   Note, for the geometric mean, values must be > 0.
%
%   Descriptions of Input Variables:
%   typeMean: a string with values 'geometric','arithmetic', or 'harmonic'
%       specifying the type of geometric mean to be calculated.
%   varargin: contains vectors of values and weights to calculate means.
%       Mode 1: varargin={val1, val2, option}.  Val1 and Val2 are vectors of
%           equal size and arbitrary dimension.  Option is either a scalar
%           value declaring the dimension across which the mean will be calculated,
%           or the string 'all' specifying that the arrays will be flattened prior to
%           calculating the weighted mean.
%       Mode 2: varargin={val1, val2, ..., valN, weight1, weight2,
%           ...,weightN}
%           All must have identical dimension or the code will result in an
%           error.
%
%   Descriptions of Output Variables:
%   output: 
%       Mode 1: either a scalar value or a single array with size
%           determined by the dimension specified to sum across
%       Mode 2: an array with size equal to the input value and weight
%           arrays
%
%   Example(s):
%   Mode 1:
%   >> scalarMean = weighted_mean('harmonic',[1 2 3],[0.2, 0.3, 0.2]); %the
%   output is single scalar value
%   >> scalarMean = weighted_mean('arithmetic',[1 2 3],[0.2, 0.3, 0.2],1);
%   %the output is a vector of size (3x1)
%   Mode 2:
%   >> arrayMean =
%   weighted_mean('geometric',[1,2,3],[4,5,6],[0.2,0.3,0.2],[0.2,0.1,0.1]);
%   %the output is a vector of size (1x3)
%
%   See also:

% Author: Anthony Kendall
% Contact: anthony [dot] kendall [at] gmail [dot] com
% Created: 2008-03-11
% Copyright 2008 Michigan State University.

%Check to make sure that the mean type is specified, and that both weights
%and values are provided
assert(ischar(typeMean),'The first argument must specify the type of weighted mean');

%Check if the last argument specifies the dimension across which the
%calculate the weighted mean, this only operates if there is a single input
%value vector and weight vector
if ((nargin - 1) == 3) || ((nargin - 1) == 2) %Mode 1
    sizeArray = size(varargin{1});
    numArrays = 1;
    vals = varargin{1};
    weights = varargin{2};
    meanDim = 1; %the default dimension to sum across is 1
    if ischar(varargin{end}) %specify a weighted mean across all dimensions
        if strcmpi(varargin{end},'all')
            meanDim = 2;
            vals = reshape(vals,1,prod(sizeArray));
            weights = reshape(weights,1,prod(sizeArray));
        else
            error('Unrecognized option')
        end
    elseif isscalar(varargin{end}) %option: use a scalar to specify the dimension to sum across
        meanDim = varargin{end};
    end
else %Mode 2
    numArrays = (nargin - 1) / 2;
    assert(mod(numArrays,1)==0,'A weight array must be specified for each input value array')
    sizeArray = size(varargin{1});
    meanDim = numel(sizeArray) + 1;
    sizeArray = [sizeArray , numArrays]; %The concatenated array will have an additional dimension of size numArrays
    vals = cat(meanDim, varargin{1:numArrays});
    weights = cat(meanDim, varargin{numArrays+1:end});
end

%Check that the sizes of the input value and weight arrays match
assert(all(size(vals)==size(weights)),'Input value and weight arrays must be the same size');
%Check that weights are nonnegative, and that at least one value is >0
assert(all(reshape(weights>=0,prod(sizeArray),1)),'Weights must be non-negative');
assert(all(reshape(any(weights>0,meanDim),prod(sizeArray)/sizeArray(meanDim),1)),'At least one weight must be non-zero');
    
switch lower(typeMean)
    case 'arithmetic'
        output = sum(weights.*vals, meanDim) ./ sum(weights, meanDim);
    case 'harmonic'
        output = sum(weights, meanDim) ./ sum(weights./vals, meanDim);
    case 'geometric'
        assert(all(reshape(vals>0,prod(sizeArray),1)),'Input values must be greater than 0');
        output = exp(sum(weights.*log(vals), meanDim) ./ sum(weights, meanDim));
    otherwise
        error('Unrecognized mean type specified')
end
end