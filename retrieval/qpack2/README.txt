#############################################################################
###   Qpack2
#############################################################################

Scope
-
Qpack2 shall handle:
1. Batch inversions of 1D cases (only single spectra cases, but handling
"double" observation modes such as beam switching and frequency switching).
2. Produce spectra matching the a priori assumptions.

Option 2 is triggered by setting all spectra (Y.y) to be empty.

Quality checks are not hanlded by qpack2. For example, there is no
check that the frequencies of the measurements are as expected
(Q.F_BACKEND). This for efficiency reasons and the fact that such
checks are hard to make in a totally general manner. Some checks can
be performed by accompanying functions, such as qp2_check_f. 

Beside the settings below, some general atmlab settings are used. This 
includes
ARTS_PATH
ARTS_INCLUDES
EXTRAP
FMODEL_VERBOSITY
VERBOSITY
WORK_AREA

A calculation run could like this:

>> Q = q_h2o;
>> Y = get_onsala_Y( 'h2o', date1, date2 );
>> qp2_check_f( Q, Y, 1e3 );
>> Y = rmfield( Y, 'f' );
>> P = qp2_oem( Q, Y );





#############################################################################
### Y : Measurement data
#############################################################################

The measurements are provided to qpack2 as an array of structures. 
Mandatory fields are:

Y.y
-
The spectrum. All spectra in the array must have the same length.

Y.year
Y.month
Y.day
-
The time of the measurement. All three fields are numeric. This
information is primarily used to extract data from the climatology
database provided.

Y.zenith_angle
- 
Line of-sight zenith angle for the measurement. A scalar value.

Y.tnoise_si
-
Magnitude of thermal noise (1 std). A scalar or a vector having the
same length as y. If a scalar, the value is applied for all
spectrometer channels.

Y.hse_p
Y.hse_z
-
The reference point when enforcing hydrostatic equilibrium. The
geometrical altitude (hse_z) is given for one presssure (hse_p).


Optional fields are:

Y.f
-
Frequency for each y value. Selected frequency should match Q.F_BACKEND.

Y.hour
Y.minute
Y.second
-
Allowing a more detailed specification of measurement time.

Y.latitude
Y.longitude
-
The geographical position of the measurement. If not given, the 
position is taken from Q.PLATFORM_LAT and Q.PLATFORM_LON.

An example:

>> Y(3)

ans = 

            year: 2002
           month: 3
             day: 3
            hour: 11
          minute: 57
          second: 58.0000
    zenith_angle: 65
           hse_p: 10000
           hse_z: 16000
       tnoise_si: 0.0243
               y: [800x1 double]





#############################################################################
### Q : Forward model and retrieval data
#############################################################################

All fields are described and set to default/dummy values in
qpack2.m. Use qinfo to obtain the information. For everything:

qinfo( @qpack2 )

To read about a specific field, such as POLYFIT_SI:

qinfo( @qpack2, 'POLYFIT_SI' )





#############################################################################
### P : Result and auxiliary data of retrieval
#############################################################################

A structure array. The following fields are always returned

P.latitude
P.longitude
-
Geographical position.

P.year
P.month
P.day
P.hour
P.minute
P.second
-
Measurement time. 

P.tnoise_si
-
Mean of assumed thermal noise (a direct averaging, no weighting 
with channel widths).

P.cost
P.cost_y
P.cost_x
-
"Cost" values of retrieval, normalised with length of measurement
vector. For some more information: help oem





P.converged

P.f
P.y
P.yf

P.p
P.t
P.z
