---
layout: post
title: "OpenGL Transformations"
date: 2013-06-02 09:29
comments: true
categories: OpenGL WebGL
---
Below are the common operations happened during the OpenGL rendering pipeline.

1. Model transform, apply model matrix.
2. View transform, apply View matrix.
3. Projection, apply projection matrix.
4. Divide ``W``
5. Viewport transform, apply viewport interpolation.

The model and view transforms sometimes be combined into one ModelView transform.

### Model Transform
Model matrix will be constructed. The matrix transform vertex from ``local space`` into ``world space`` coordinate.

For example, in order to create a car, you usually need a car body and 2 wheels (2D, for simplicity reason). I come from a Adobe Flash background, a display list or scene graph will be used.

That means you position everything relate to something else. The 4 wheels' position will be positioned relate to the car itself, at(2, 0) and (5, 0). The car body will be also placed related to the car at (1, 1).

The positions above are all related to their parent, the car. I usually treat it as a ``local space``, this space only concern the object itself but related to its parent.

Finally, we position the car at 100 metres away at (100, 0), which "group" the body and wheels and position them at (100 + 1, 0 + 1), (100 + 2, 0 + 0) and (100 + 5, 0 + 0).

Now the car's body and wheels are in the ``world space``, the root, since I do not simulate earth rotation and orbit around the sum.

### View transform
Just like take a picture, you can move the camera around, **or** you can move the objects around! 所谓的摆拍。

Move camera to the right is the same as to move all the objects in the scene to the left. Rotate camera 60 degree is the same as make all the objects orbit the camera position -60 degree.

The view matrix is actually the inverse of the camera's position and rotation matrix.

Apply this view matrix to the model matrix, you end up a ModelView matrix which transform objects into ``eye space`` coordinate.

### Projection
Projection matrix transform ``eye space`` coordinate into ``clip space`` coordinate, Where view frustum clip will be performed. Vertex outside the view frustum will be discarded and new vertex will be added to construct new triangles. Range, [-1, 1].

The result is still a homogeneous coordinates.

### W division
Divide the 4th component of the homogeneous coordinate tuple results a ``normalized device coordinates``, ``ndc`` for short. The coordinate system ranges from [-1, 1]

### Viewport transform
Convert ``ndc`` into ``screen space``.

Simple linear interpolation. [-1, 1] will be interpolated into [left, right], [bottom, top], [near, far]

### Summary
A vertex is transformed as following sequence:

1. model matrix transform to ``world space``
2. view matrix transform to ``eye space``
3. projection matrix transform to ``clip space``
4. Divide **W** transform to ``normalized device coordinate``
5. viewport transform results ``screen space``

### Other information

#### Homogeneous coordinates
I've no idea what does **homogeneous** mean. But I just need an intuition.

Say, you have a point at infinite position far far away, how to represent it, (∞, ∞)? Completely useless, since I don't know how to add or substract ∞.

But remember the school teacher always said that, ***never divide a number by 0***.

It acutally make sense in this situation, if we append a new component 0 to the 2D tuple. Say (1, 1, 0), this means a infinite point. Because (1/0, 1/0) => (∞, ∞).

This is call ``Homogeneous coordinates``. Quite intuitive.

In OpenGL, the 3D vector usually represented as a 4 dimentional tuple, with the last element to be **0**, an infinite location. Which make sense, vector does not have position, just direction. You can add two vectors and results a new vector, since the 4th components addtion also results 0.

For 3D point, vertex position in OpenGL. The 4th component will be **1**. (x, y, z, 1), divide by 4th component 1 still results (x, y, z) represent a physical location. But it does not make sense to add up two points together, since it 4th component become 2, an invalid tuple. Checking last component to be 2 or not can be used as a validation.