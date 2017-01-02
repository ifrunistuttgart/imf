# iMF - iFR Modelling Framework #

## Purpose ##

The iFR Modelling Framework (iMF) shall help the user to model mechanic multi-body systems. It uses the formulation according to d’Alembert. The user defines generalized coordinates, coordinate systems with transformations (rotations and translations), symbolic system parameters, masses, frorces, moments and moments of inertia. The framework then computes the system's equations of motion in an symbolic form and generates MATLAB functions in mass-matrix form.

A huge part of the framework is adopted from the [ACADO Toolkit](https://acado.github.io/ "ACADO Toolkit") which is licensed unter the GNU Lesser General Public License (GLPL).

## Usage ##
### Important Classes ###

The following classes are of particular interest for using the framework.

#### imf.Model ####

##### Constructor #####
    Model(interialSystem)

*inertialSystem:* Pass an *imf.CoordinateSystem*, defining the inertial system in which the equations of motion will be expressed.

##### Methods #####
    Add(external)
*external:* Pass an *imf.Force*, *imf.Moment*, *imf.Inertia* or *imf.Mass* which is then added to the model and automatically transformed into an expression of the inertial frame. If an *imf.Mass* is added when gravity is defined, an equivalent *imf.Force* is automatically added.

	Compile
*return value*: Calculates the jacobians and derivatives needed for the formulation of the equations of motion and computes and returns them symbolically as an array of *imf.Expression*. 

##### Variables #####
	gravity
Sets the gravity for the model as an *imf.Gravity*.


#### imf.Gravity ####

##### Constructor #####
    Gravity(value, coordinateSystem)

*value:* An vector or an imf.Vector - typically [0;0;9.81] given in *coordinateSystem*.

*coordinateSystem:* An *imf.CoordinateSystem* the *value* is given in.

#### imf.Mass ####

##### Constructor #####
    Mass(value, positionVector, coordinateSystem)

*value:* A scalar value or an *imf.Variable* defining the mass of a mass point.

*positionVector:* An vector or an *imf.Vector* defining the position vector of the force induced by the mass and the *imf.Gravity* given in *coordinateSystem*.

*coordinateSystem:* An *imf.CoordinateSystem* the *positionVector* is given in.

#### imf.Force ####

##### Constructor #####
    Force(value, positionVector, coordinateSystem)

*value:* A vector or an *imf.Vector* defining the magnitude and the direction of a force given in *coordinateSystem*.

*positionVector:* An vector or an *imf.Vector* describing the position vector of the force *value* given in *coordinateSystem*.

*coordinateSystem:* An *imf.CoordinateSystem* the *value* and *positionVector* are given in.

#### imf.Inertia ####

##### Constructor #####
    Inertia(value, attitudeVector, coordinateSystem)

*value:* A matrix or an *imf.Matrix* giving the moment of inertia tensor w.r.t. the origin and in the axes of *coordinateSystem*.

*attitudeVector:* An vector or an *imf.Vector* describing the attitude of the system w.r.t. the generalized coordinates given in *coordinateSystem*.

*coordinateSystem:* An *imf.CoordinateSystem* the *value* and *attitudeVector* are given in.

#### imf.Moment ####

##### Constructor #####
    Moment(value, attitudeVector, coordinateSystem)

*value:* A vector or an *imf.Vector* defining the magnitude and the axis of a moment given in *coordinateSystem*.

*attitudeVector:* An vector or an *imf.Vector* describing the attitude of the system w.r.t. the generalized coordinates given in *coordinateSystem*.

*coordinateSystem:* An *imf.CoordinateSystem* the *value* and *attitudeVector* are given in.

#### imf.Expression ####

The class is the base for every symbolic formulation. It defines a lot of arithmetic functions like sin, cos, multiplication, etc. which will not be explained here.
 
##### Methods #####
    matlabFunction(filename)
Reduces the order of the differential function and generates two files *filenameM* and *filenameF* giving a first order differential equation in mass-matrix form M*xdot = F

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