---
layout: post
title: "Normal Transformation"
date: 2013-03-30 16:05
comments: true
categories:
cover: http://www.arcsynthesis.org/gltut/Illumination/CircleNormalScaling.svg
---
I was doing WebGL lighting which requires a special normal transformation matrix:

$$ (\mathbf{M}^{-1})^T $$

**``M``** is a matrix, usually the model view transform matrix. I was trying to understand how they come up this matrix. Here is my understanding, a brief explanation.

Below are some conditions for this problem:

Let ***``n``*** be the surface normal vector, ***``t``*** is a vector on the surface.

***``t'``*** is the vector transformed by **``M``**, the model view transform matrix. The mathmatics representation is:

$$ t' = \mathbf{M} * t $$

***``n'``*** is vector transformed by **``G``** which is the special normal transformation matrix we need to produce. The mathmatics representation is:

$$ n' = \mathbf{G} * n $$

If transformed normal vector ***``n'``*** is perpendicular to the surface, by definition there will be:

$$ n' \cdot t' = (\mathbf{G} * n) \cdot (\mathbf{M} * t) = 0 $$

Two vectors' dot product can be rewritten into multiplication by transposing one column vector (OpenGL use column vector) into a row vector. [Transpose of matrix, property 6](http://en.wikipedia.org/wiki/Transpose#Properties)

$$ (\mathbf{G} * n)^T * (\mathbf{M} * t) = 0 $$

*Seems like the vectors dot product can be treated as two one dimensional matrices multiplication.*

According to [Transpose of matrix, property 3](http://en.wikipedia.org/wiki/Transpose#Properties). The final equation is :

$$ n^T * \mathbf{G}^T * \mathbf{M} * t = 0 $$

Now, all we need to do is using this equation to produce the normal matrix (the inverse transpose of the model view matrix).

Look at the equation carefully, if **``M``** multiply transpose of **``G``** results an identity matrix **``I``**.

$$ \mathbf{G}^T * \mathbf{M} = \mathbf{I} $$

The equation can then be transform into

$$ n^T * t = n \cdot t = \|n\|\|t\|\cos(\frac{\pi}{2}) = 0 $$

This is obviously true, because ***``n``*** is perpendicular to ***``t``***.

$$ \mathbf{G}^T * \mathbf{M} = \mathbf{I} $$ becomes the key to solve the problem. Multiply both side by $$ \mathbf{M}^{-1} $$ finally we get the answer.

$$
\mathbf{G}^T (\mathbf{M}\mathbf{M}^{-1}) = \mathbf{I} \mathbf{M}^{-1} \Rightarrow\\

\mathbf{G}^T \mathbf{I} = \mathbf{M}^{-1}  \Rightarrow\\

\mathbf{G}^T = \mathbf{M}^{-1} \Rightarrow\\

\mathbf{G} = (\mathbf{M}^{-1})^T
$$

This inverse transpose model view matrix must be used for surface normal transformation in order to calculate the correct lighting.

This is because the model view matrix could cause the incorrect normal direction. Imagine you have a sphere, and scale 2 units only in **``x``** axis, the sphere will be stretched. If use the model view matrix, the normal points in **``y``** direction clearly will be unchanged, the length of normal in **``x``** direction is now 2 units, other normals will be incorrect as well.

