function [y,J] = arts_oem( Q, R, x, iter, do_y, do_j )


[y,dy,J,jq,ji] = arts_y( Q );