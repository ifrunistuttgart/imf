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
Mass(name, value, positionVector)
```
*name:* A name for this external used by the visualize function.

*value:* A scalar value or an [imf.Parameter](#imfparameter) defining the mass of a mass point.

*positionVector:* An [imf.PositionVector](#imfpositionvector) defining the position vector of the force induced by the mass and the [imf.Gravity](#imfgravity).

#### imf.Force ####

##### Constructor #####
```matlab
Force(name, value, positionVector)
```
*name:* A name for this external used by the visualize function.

*value:* An [imf.Vector](#imfvector) defining the magnitude and the direction of a force.

*positionVector:* An [imf.PositionVector](#imfpositionvector) describing the position vector of the force *value*.

#### imf.Inertia ####

##### Constructor #####
```matlab
Inertia(name, value, attitudeVector)
```
*name:* A name for this external used by the visualize function.

*value:* An [imf.Matrix](#imfmatrix) giving the moment of inertia tensor w.r.t. the origin.

*attitudeVector:* An [imf.Vector](#imfvector) describing the attitude of the system w.r.t. the generalized coordinates.

#### imf.Moment ####

##### Constructor #####
```matlab
Moment(name, value, attitudeVector)
```
*name:* A name for this external used by the visualize function.

*value:* An [imf.Vector](#imfvector) defining the magnitude and the axis of a moment.

*attitudeVector:* An [imf.Vector](#imfvector) describing the attitude of the system w.r.t. the generalized coordinates.

#### imf.Expression ####

The class is the base for every symbolic formulation. It defines a lot of arithmetic functions like sin, cos, multiplication, etc. which will not be explained here.
 
##### Methods #####
```matlab
matlabFunction(filename)
```
Reduces the order of the differential function and generates two files *filenameM* and *filenameF* giving a first order differential equation in mass-matrix form M*xdot = F

#### imf.Transformation ####
#### imf.Vector ####
#### imf.PositionVector ####
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
- 'revz': A switch to reverse the z and y axis.

```matlab
% EXAMPLE USAGE:  
visualize(m, {q1, q2, m1, m2, l}, [ysol(i,1), ysol(i,2), m1v, m2v, lv], 'axis', [-2 2 -2 2 -.5 4], 'view', [0 0], 'revz', 1)
```


## Examples ##

You find more complex and complete examples packaged with the framework. Those examples start with *test_*. 

### Header ###
This is the recommended way of adding the framework to your PATH variable.

```matlab
if ~exist('BEGIN_IMF','file'),
    addpath( genpath([pwd filesep 'imf']) )
    if ~exist('BEGIN_IMF','file'),
        error('Unable to find the BEGIN_IMF function. Make sure to have' + ...
            'the library as a sub folder of the current working directory.');
    end
end

%%
BEGIN_IMF

%%
% >>> Your code goes here <<<
%%

END_IMF
```

### Pendulum ###
```matlab
GeneralizedCoordinate q1
CoordinateSystem I
Variable m1 l

m = imf.Model(I);
m.gravity = imf.Gravity(g, I);
m.Add(imf.Mass('m1', m1, imf.PositionVector([sin(q1)*l,-cos(q1)*l,0]', I)));
```

### Torsion Pendulum ###
This is a simple model to show the functionality of rotational motion modelling.

```matlab
GeneralizedCoordinate q1
CoordinateSystem I
Variable k Izz

m = imf.Model(I);
m.Add(imf.Inertia('I', imf.Matrix([0 0 0;0 0 0;0 0 Izz], I), imf.Vector([0 0 q1]', I)));
% Be aware of the sign of the Moment induced by the spring
m.Add(imf.Moment('M1', imf.Vector([0 0 -k*q1]', I), imf.Vector([0 0 q1]', I))); 
```