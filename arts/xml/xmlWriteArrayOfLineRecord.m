% Writes an ARTS catalog to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteArrayOfLineRecord(fid, fidb, data, type, precision, attrlist)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       Array
% IN    type       Data type as string
% IN    precision  Precision for floats
% IN    attrlist   Attribute list

% 2016-12-13  Created by Oliver Lemke.

function xmlWriteArrayOfLineRecord(fid, fidb, data, type, precision, attrlist)


if ~isfield(data, 'version') || data(1).version ~= 5
    error('atmlab:xml:WriteArrayOfLineRecord', ...
        'Input variable is not an ARTSCAT-5');
end

if (nargin < 6)
    attrlist = [];
end
attrlist = xmlAddAttribute (attrlist, 'version', 'ARTSCAT-5');
attrlist = xmlAddAttribute (attrlist, 'nelem', sprintf ('%d', length(data)));
xmlWriteTag (fid, 'ArrayOfLineRecord', attrlist);

LM_error_msg = 'Error in catalog line %d. Line mixing tag %s expects %d parameters.';
PB_error_msg = 'Error in catalog line %d. Pressure broadening tag %s expects %d parameters.';

lnum = 0;
for line = data
    lnum = lnum + 1;
    fprintf (fid, '@ %s %0.15g %1.15g %1.15g %1.15g %1.15g %1.15g %1.15g', ...
        line.name, line.f, line.i0, line.t_i0, line.elow, ...
        line.a, line.gupper, line.glower);
    
    % Pressure broadening values
    if line.PB_type
        if ~strcmp(line.PB_type, 'N2') ...
                && ~strcmp(line.PB_type, 'WA') ...
                && ~strcmp(line.PB_type, 'AP') ...
                && ~strcmp(line.PB_type, 'SD-AIR') ...
                && ~strcmp(line.PB_type, 'NA')
            error('atmlab:xml:writearrayoflinerecord', ...
                'Error in catalog line %d. Unknown pressure broadening type %s.', ...
                lnum, line.PB_type);
        end
        if strcmp(line.PB_type, 'N2') && length(line.PB_values) ~= 10
            error('atmlab:xml:writearrayoflinerecord', ...
                PB_error_msg, lnum, 'N2', 10);
        elseif strcmp(line.PB_type, 'WA') && length(line.PB_values) ~= 9
            error('atmlab:xml:writearrayoflinerecord', ...
                PB_error_msg, lnum, 'WA', 9);
        elseif strcmp(line.PB_type, 'AP') && length(line.PB_values) ~= 20
            error('atmlab:xml:writearrayoflinerecord', ...
                PB_error_msg, lnum, 'AP', 20);
        elseif strcmp(line.PB_type, 'SD-AIR') && length(line.PB_values) ~= 8
            error('atmlab:xml:writearrayoflinerecord', ...
                PB_error_msg, lnum, 'SD-AIR', 8);
        elseif strcmp(line.PB_type, 'NA') && ~isempty(line.PB_values)
            error('atmlab:xml:writearrayoflinerecord', ...
                PM_error_msg, lnum, 'NA', 0);
        end
        fprintf(fid, ' PB %s', line.PB_type);
        fprintf(fid, ' %3.15g', line.PB_values);
    end
    % Quantum numbers
    if line.QN
        fprintf(fid, ' QN %s', strtrim(line.QN));
    end
    % Line mixing values
    if line.LM_type
        if ~strcmp(line.LM_type, 'LL') ...
                && ~strcmp(line.LM_type, 'NR') ...
                && ~strcmp(line.LM_type, 'L2') ...
                && ~strcmp(line.LM_type, 'L1') ...
                && ~strcmp(line.LM_type, 'BB') ...
                && ~strcmp(line.LM_type, 'NA')
            error('atmlab:xml:writearrayoflinerecord', ...
                'Error in catalog line %d. Unknown line mixing type %s.', ...
                lnum, line.LM_type);
        end
        if strcmp(line.LM_type, 'LL') && length(line.LM_values) ~= 12
            error('atmlab:xml:writearrayoflinerecord', ...
                LM_error_msg, lnum, 'LL', 12);
        elseif strcmp(line.LM_type, 'NR') && length(line.LM_values) ~= 1
            error('atmlab:xml:writearrayoflinerecord', ...
                LM_error_msg, lnum, 'NR', 1);
        elseif strcmp(line.LM_type, 'L2') && length(line.LM_values) ~= 10
            error('atmlab:xml:writearrayoflinerecord', ...
                LM_error_msg, lnum, 'L2', 10);
        elseif strcmp(line.LM_type, 'L1') && length(line.LM_values) ~= 3
            error('atmlab:xml:writearrayoflinerecord', ...
                LM_error_msg, lnum, 'L1', 3);
        elseif strcmp(line.LM_type, 'BB') && length(line.LM_values) ~= 1
            error('atmlab:xml:writearrayoflinerecord', ...
                LM_error_msg, lnum, 'BB', 1);
        elseif strcmp(line.LM_type, 'NA') && ~isempty(line.LM_values)
            error('atmlab:xml:writearrayoflinerecord', ...
                LM_error_msg, lnum, 'NA', 0);
        end
        
        fprintf(fid, ' LM %s', line.LM_type);
        fprintf(fid, ' %3.15g', line.LM_values);
    end
    % Partition function values
    if line.PF_type
        if ~strcmp(line.PF_type, 'CN') ...
                && ~strcmp(line.PF_type, 'NA')
            error('atmlab:xml:writearrayoflinerecord', ...
                'Error in catalog line %d. Unknown partition function type %s.', ...
                lnum, line.PF_type);
        end
        if strcmp(line.PF_type, 'CN') && isempty(line.PF_values)
            error('atmlab:xml:writearrayoflinerecord', ...
                ['Error in catalog line %d. ', ...
                'Number of partition function coefficients cannot be 0 for type CN.'], ...
                lnum);
        elseif strcmp(line.PF_type, 'NA') && ~isempty(line.PF_values)
            error('atmlab:xml:writearrayoflinerecord', ...
                ['Error in catalog line %d. ', ...
                'Number of partion function coefficients should be 0 for type NA.'], ...
                lnum);
        end
        fprintf(fid, ' PF %s %d ', line.PF_type, length(line.PF_values));
        fprintf(fid, ' %1.15g', line.PF_values);
    end
    fprintf(fid, '\n');
end

xmlWriteCloseTag (fid, 'ArrayOfLineRecord');

return
