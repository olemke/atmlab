% Writes a GasAbsLookup table to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteGasAbsLookup(fid, data)
%
% IN    fid    File descriptor
% IN    data   GasAbsLookup table
                                                                                                                               
% 2002-12-16  Created by Oliver Lemke.

function xmlWriteGasAbsLookup(fid, data)

xmlWriteTag (fid, 'GasAbsLookup', []);

xmlWriteArrayOfArrayOf (fid, data.species, 'SpeciesTag');
xmlWriteArrayOf (fid, data.nonlinear_species, 'Index');
xmlWriteVector (fid, data.f_grid);
xmlWriteVector (fid, data.p_grid);
xmlWriteMatrix (fid, data.vmrs_ref);
xmlWriteVector (fid, data.t_ref);
xmlWriteVector (fid, data.t_pert);
xmlWriteVector (fid, data.nls_pert);
xmlWriteTensor4 (fid, data.xsec);

xmlWriteCloseTag (fid, 'GasAbsLookup');

