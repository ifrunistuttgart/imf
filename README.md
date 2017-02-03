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
*external:* Pass an [imf.Force](#imfforce), [imf.Moment](#imfmoment) or [imf.Body](#imfbody) which is then added to the model and automatically transformed into an expression in the inertial frame. If an [imf.Body](#imfbody) is added when gravity is defined, an equivalent [imf.Force](#imfforce) is automatically added.

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

#### imf.Body ####

##### Constructor #####
```matlab
Mass(name, value, positionVector, [inertia], [attitudeVector])
```
*name:* A name for this external used by the visualize function.

*value:* A scalar value or an [imf.Parameter](#imfparameter) defining the mass of a mass point.

*positionVector:* An [imf.PositionVector](#imfpositionvector) defining the position vector of the force induced by the mass and the [imf.Gravity](#imfgravity).

*inertia:* (optional) An [imf.Inertia](#imfinertia) giving the moment of inertia tensor.

*angularVector:* (optional) An [imf.AttitudeVector](#imfattitudevector) describing the attitude of the system or an [imf.AngularVelocity](#imfangularvelocity).

#### imf.Force ####

##### Constructor #####
```matlab
Force(name, value, positionVector)
```
*name:* A name for this external used by the visualize function.

*value:* An [imf.Vector](#imfvector) defining the magnitude and the direction of a force.

*positionVector:* An [imf.PositionVector](#imfpositionvector) describing the position vector of the force *value*.

#### imf.Moment ####

##### Constructor #####
```matlab
Moment(name, value, attitudeVector, origin)
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

```matlab
symbolic
```
Returns an vector of MATLAB's symbolic objects.

#### imf.Transformation ####
##### Constructor #####
```matlab
Transformation(from, to, [rotation], [rotation], [rotation], [rotation|translation]*)
```  
(*) You need to define at least one rotation or translation and not more than three roations and one translation.
*name:* A name for this external used by the visualize function.

*value:* An [imf.Vector](#imfvector) defining the magnitude and the axis of a moment.

*rotation:* (optional) An [imf.RotationMatrix](#imfrotationmatrix) describing rotation from *from* to *to*.

*translation:* (optional) An [imf.Vector](#imfvector) describing translational offset of both coordinate systems.

#### imf.Vector ####
A vector is only rotated when transformed.
##### Constructor #####
```matlab
Vector(value, coordinateSystem)
```  
*value:* An vector or an [imf.Vector](#imfvector) defining the value in *coordinateSystem*.
*coordinateSystem:* An [imf.CoordinateSystem](#imfcoordinateSystem) the *value* is given in.
  
#### imf.PositionVector ####
A position vector is rotated and translated when transformed.
##### Constructor #####
```matlab
PositionVector(value, coordinateSystem)
```  
*value:* An vector or an [imf.Vector](#imfvector) defining the value in *coordinateSystem*.
*coordinateSystem:* An [imf.CoordinateSystem](#imfcoordinateSystem) the *value* is given in.

#### imf.AttitudeVector ####
An attitude vector can not be transformed at the moment. It is only used to derive the angular velocity.
##### Constructor #####
```matlab
AttitudeVector(value, coordinateSystem)
```  
*value:* An vector or an [imf.Vector](#imfvector) defining the value in *coordinateSystem*.
*coordinateSystem:* An [imf.CoordinateSystem](#imfcoordinateSystem) the *value* is given in.

#### imf.AngularVelocity ####
An angular velocity is transformed using the rotational sequences provided by the transformation.
##### Constructor #####
```matlab
AngularVelocity(value, coordinateSystem)
```  
*value:* An vector or an [imf.Vector](#imfvector) defining the value in *coordinateSystem*.
*coordinateSystem:* An [imf.CoordinateSystem](#imfcoordinateSystem) the *value* is given in.

#### imf.Matrix ####
An matrix is transformed by rotation.
##### Constructor #####
```matlab
Matrix(value, coordinateSystem)
```  
*value:* An vector or an [imf.Vector](#imfvector) defining the value in *coordinateSystem*.
*coordinateSystem:* An [imf.CoordinateSystem](#imfcoordinateSystem) the *value* is given in.

#### imf.RotationMatrix ####

##### Constructor #####
```matlab
RotationMatrix(value, [axis], [generalizedCoordinate])
```  
*value:* A matrix or an [imf.Expression](#imfexpression) defining the value.
*axis:* (optional) A numeric scalar providing the axis which the turn is performed around.
*generalizedCoordinate:* (optional) The [imf.GeneralizedCoordinate](#imfgeneralizedcoordinate) giving the angle for the rotation.

#### imf.CoordinateSystem ####

##### Constructor #####
```matlab
CoordinateSystem(name)
```  
*name:* A name for the coordinate system.

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
m.Add(imf.Body('b1', m1, imf.PositionVector([sin(q1)*l,-cos(q1)*l,0]', I)));
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

### Step-by-Step ###

For this example we are going to model a two-mass pendulum and all steps will be explained. For an illustration of the coordinates chosen, see *documents/two_mass_pendulum.ai*.

For convenience, the Header will be skipped at this point.

1. Define the generalized coordinates, coordinate systems and model parameters
```matlab
GeneralizedCoordinate q1 q2
CoordinateSystem I c1
Parameter m1 m2 l
```
Coordinate q1 describes the angle between the first pole and the inertial coordinate *I* system's z axis.  
Coordinate q2 describes the angle between the second pole and the *c1* coordinate system's z axis.  
In this example the pendulum rotates around the y axis of each system and the right-hand rule applies.   Therefore counter-clockwise rotation is positive.  
The mass of the first pole is described by a point mass at the end of the pole with the free model parameter *m1*. The mass of the second pole is described by *m2*. The length of each pole is *l*.

2. The transformation between coordinate system c1 and I must be defined if any vector is given in a non-inertial coordinate system. Otherwise, the framework would be unable to transform them into the inertial system. A transformation is defined as follows:
```matlab
T21 = imf.Transformation(I, c1, imf.RotationMatrix.T2(q1), imf.Vector([0;0;-l], c1));
```
It is not necessary to store this transformation into a workspace variable as the transformation is stored internally, too.  
The above code defines a transformation from I to c1 by rotating around the 2-axis (y axis) with q1 (in radians). T1 and T3 are also available as predefined rotations.  
Additionally, a translational offset between those two systems is defined by the fourth parameter. The offset can be described in the most convenient coordinate system. 
3. The next step creates a model object which stores all relevant information concerning the dynamic system to be modelled:  
```matlab
m = imf.Model(I);
```
4. As we are going to add masses to the model, we need a gravitational acceleration to have forces acting on these masses.
```matlab
g = [0;0;9.81];
m.gravity = imf.Gravity(g, I);
```
5. Now we are ready to define the masses of the poles (as point masses).
```matlab
m.Add(imf.Body('b1', m1, imf.PositionVector([sin(q1)*l,0,cos(q1)*l]', I)));
m.Add(imf.Body('b2', m2, imf.PositionVector([sin(q2)*l,0,cos(q2)*l]', c1)));
```
You just need to define a name (for visualization), the mass (either symbolic of numerical value) and the point of application of this mass in any coordinate system you like.
6. As a last step, you can now compile the model and export MATLAB functions to files named filenameM.m and filenameF.m resulting in equations in the form of M*x' = F. 
```matlab
model = m.Compile();
model.matlabFunction('filename');
```
