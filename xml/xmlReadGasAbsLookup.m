% Reads a GasAbsLookup table from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
%    Calls *xmlReadTag* for every member of the GasAbsLookup structure.
%
% FORMAT   result = xmlReadGasAbsLookup(fid, attrlist)
%
% OUT   result     GasAbsLookup table
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
                                                                                                                               
% 2002-11-28   Created by Oliver Lemke.

function result = xmlReadGasAbsLookup(fid, attrlist)

  result.species            = xmlReadTag(fid);
  result.nonlinear_species  = xmlReadTag(fid);
  result.f_grid             = xmlReadTag(fid);
  result.p_grid             = xmlReadTag(fid);
  result.vmrs_ref           = xmlReadTag(fid);
  result.t_ref              = xmlReadTag(fid);
  result.t_pert             = xmlReadTag(fid);
  result.nls_pert           = xmlReadTag(fid);
  result.abs                = xmlReadTag(fid);

