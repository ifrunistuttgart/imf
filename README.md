# iMF - iFR Modelling Framework #

## Purpose ##

## Usage ##
### Important Classes ###
#### imf.Model ####

##### Constructor #####
    Model(interialSystem)

*inertialSystem:* Pass an imf.CoordinateSystem, defining the inertial system in which the equations of motion will be expressed.

##### Methods #####
    Add(external)
*external:* Pass an imf.Force, imf.Moment, imf.Inertia or imf.Mass which is then added to the model and automatically transformed into an expression of the inertial frame. If an imf.Mass is added when gravity is defined, an equivalent imf.Force is automatically added.

##### Variables #####


#### imf.Gravity ####
#### imf.Mass ####
#### imf.Force ####
#### imf.Inertia ####
#### imf.Moment ####

## Examples ##
### Pendulum ###

    GeneralizedCoordinate q1
    CoordinateSystem I
    Variable m1 l

    m = imf.Model(I);
    m.gravity = imf.Gravity(g, I);
    m.Add(imf.Mass(m1, [sin(q1)*l,-cos(q1)*l,0]', I));

### Torsion Pendulum ###
This is a simple model to show the functionality of rotational motion modelling.

    GeneralizedCoordinate q1
    CoordinateSystem I
    Variable k Izz

    m = imf.Model(I);
    m.Add(imf.Inertia([0 0 0;0 0 0;0 0 Izz], [0 0 q1]', I));
    % Be aware of the sign of the Moment induced by the spring
    m.Add(imf.Moment([0 0 -k*q1]', [0 0 q1]', I)); 