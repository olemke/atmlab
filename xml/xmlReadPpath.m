% Reads a Ppath from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
%    Calls *xmlReadTag* for every member of the Ppath structure.
%
% FORMAT   result = xmlReadPpath(fid, attrlist)
%
% OUT   result     Ppath
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
                                                                                                                               
% 2003-01-09   Created by Oliver Lemke.

function result = xmlReadPpath(fid, attrlist)

  result.dim          = xmlReadTag(fid);
  result.np           = xmlReadTag(fid);
  result.refraction   = xmlReadTag(fid);
  result.method       = xmlReadTag(fid);
  result.constant     = xmlReadTag(fid);
  result.pos          = xmlReadTag(fid);
  result.z            = xmlReadTag(fid);
  result.l_step       = xmlReadTag(fid);
  result.gp_p         = xmlReadTag(fid);
  result.gp_lat       = xmlReadTag(fid);
  result.gp_lon       = xmlReadTag(fid);
  result.los          = xmlReadTag(fid);
  result.background   = xmlReadTag(fid);
  result.tan_pos      = xmlReadTag(fid);
  result.geom_tan_pos = xmlReadTag(fid);

