# iMF - iFR Modelling Framework #

## Purpose ##

The iFR Modelling Framework (iMF) shall help the user to model mechanic multi-body systems. It uses the formulation according to d’Alembert. The user defines generalized coordinates, coordinate systems with transformations (rotations and translations), symbolic system parameters, masses, frorces, moments and moments of inertia. The framework then computes the system's equations of motion in an symbolic form and generates MATLAB functions in mass-matrix form.

A huge part of the framework is adopted from the [ACADO Toolkit](https://acado.github.io/ "ACADO Toolkit") which is licensed unter the GNU Lesser General Public License (GLPL).

## Usage ##
### Important Classes ###

The following classes are of particular interest for using the framework.

#### imf.Model ####

##### Constructor #####
```matlab
Model(interialSystem)
```
*inertialSystem:* Pass an [imf.CoordinateSystem](#imfcoordinateSystem), defining the inertial system in which the equations of motion will be expressed.

##### Methods #####
```matlab
Add(external)
```
*external:* Pass an [imf.Force](#imfforce), [imf.Moment](#imfmoment), [imf.Inertia](#imfinertia) or [imf.Mass](#imfmass) which is then added to the model and automatically transformed into an expression of the inertial frame. If an [imf.Mass](#imfmass) is added when gravity is defined, an equivalent [imf.Force](#imfforce) is automatically added.

```matlab
Compile
```
*return value*: Calculates the jacobians and derivatives needed for the formulation of the equations of motion and computes and returns them symbolically as an array of [imf.Expression](#imfexpression). 

##### Variables #####
```matlab
gravity
```
Sets the gravity for the model as an [imf.Gravity](#imfgravity).


#### imf.Gravity ####

##### Constructor #####
```matlab
Gravity(value, coordinateSystem)
```
*value:* An vector or an [imf.Vector](#imfvector) - typically [0;0;9.81] given in *coordinateSystem*.

*coordinateSystem:* An [imf.CoordinateSystem](#imfcoordinateSystem) the *value* is given in.

#### imf.Mass ####

##### Constructor #####
```matlab
Mass(name, value, positionVector, coordinateSystem)
```
*name:* A name for this mass, which is used for visualization.

*value:* A scalar value or an [imf.Parameter](#imfparameter) defining the mass of a mass point.

*positionVector:* An vector or an [imf.Vector](#imfvector) defining the position vector of the force induced by the mass and the [imf.Gravity](#imfgravity) given in *coordinateSystem*.

*coordinateSystem:* An [imf.CoordinateSystem](#imfcoordinateSystem) the *positionVector* is given in.

#### imf.Force ####

##### Constructor #####
```matlab
Force(name, value, positionVector, coordinateSystem)
```
*name:* A name for this mass, which is used for visualization.

*value:* A vector or an [imf.Vector](#imfvector) defining the magnitude and the direction of a force given in *coordinateSystem*.

*positionVector:* An vector or an [imf.Vector](#imfvector) describing the position vector of the force *value* given in *coordinateSystem*.

*coordinateSystem:* An [imf.CoordinateSystem](#imfcoordinateSystem) the *value* and *positionVector* are given in.

#### imf.Inertia ####

##### Constructor #####
```matlab
Inertia(value, attitudeVector, coordinateSystem)
```
*value:* A matrix or an [imf.Matrix](#imfmatrix) giving the moment of inertia tensor w.r.t. the origin and in the axes of *coordinateSystem*.

*attitudeVector:* An vector or an [imf.Vector](#imfvector) describing the attitude of the system w.r.t. the generalized coordinates given in *coordinateSystem*.

*coordinateSystem:* An [imf.CoordinateSystem](#imfcoordinateSystem) the *value* and *attitudeVector* are given in.

#### imf.Moment ####

##### Constructor #####
```matlab
Moment(value, attitudeVector, coordinateSystem)
```
*value:* A vector or an [imf.Vector](#imfvector) defining the magnitude and the axis of a moment given in *coordinateSystem*.

*attitudeVector:* An vector or an [imf.Vector](#imfvector) describing the attitude of the system w.r.t. the generalized coordinates given in *coordinateSystem*.

*coordinateSystem:* An [imf.CoordinateSystem](#imfcoordinateSystem) the *value* and *attitudeVector* are given in.

#### imf.Expression ####

The class is the base for every symbolic formulation. It defines a lot of arithmetic functions like sin, cos, multiplication, etc. which will not be explained here.
 
##### Methods #####
```matlab
matlabFunction(filename)
```
Reduces the order of the differential function and generates two files *filenameM* and *filenameF* giving a first order differential equation in mass-matrix form M*xdot = F

#### imf.Vector ####
#### imf.Matrix ####
#### imf.CoordinateSystem ####

### Important Functions ###
#### visualize ####
```matlab
visualize(model, variables, values, varargin)
```
*model:* The [imf.Model](#imfmodel) holding all masses, forces, etc. which will be displayed

*variables:* The variables which need to be substituded by numeric *values*. The variables need to be passed in a cell array.

*values:* The numeric values for *variables* in the same order as *variables*.

*varargin:*
 
- 'axis': Axis limits for x, y and z axis passed as a vector.
- 'view': View angles for azimuth and elevation as a vector.
- 'scale': A scalar scale value to adjust arrow lengths (not fully tested).
- 'revz': A switch to reverse the z axis.

```matlab
% EXAMPLE USAGE:  
visualize(m, {q1, q2, m1, m2, l}, [ysol(i,1), ysol(i,2), m1v, m2v, lv], 'axis', [-2 2 -2 2 -.5 4], 'view', [0 0], 'revz', 1)
```


## Examples ##
### Pendulum ###
```matlab
GeneralizedCoordinate q1
CoordinateSystem I
Variable m1 l

m = imf.Model(I);
m.gravity = imf.Gravity(g, I);
m.Add(imf.Mass(m1, [sin(q1)*l,-cos(q1)*l,0]', I));
```

### Torsion Pendulum ###
This is a simple model to show the functionality of rotational motion modelling.

```matlab
GeneralizedCoordinate q1
CoordinateSystem I
Variable k Izz

m = imf.Model(I);
m.Add(imf.Inertia([0 0 0;0 0 0;0 0 Izz], [0 0 q1]', I));
% Be aware of the sign of the Moment induced by the spring
m.Add(imf.Moment([0 0 -k*q1]', [0 0 q1]', I)); 
```