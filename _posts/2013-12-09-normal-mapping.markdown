---
layout: post
title: "Normal Mapping"
date: 2013-11-23 22:54
comments: true
categories: 
cover: images/2013-11-23-normal-mapping/per_fragment_normal_map.jpg
captions:
    - Normal map
    - Tangent space specular
    - Tangent space normal map
    - Tangent space to model space transformation
    - Basis projection
---

The normal map generated from 3D computer graphics software is usually in tangent space. It encodes the normal vector in object face's local coordinate.
{% figure 1 %}
![Normal map](/images/2013-11-23-normal-mapping/brick_texture_small.jpg)
{% endfigure %}
This means that if the normal vector is perpendicular to the object surface, its value will be [0.5, 0.5, 1] which creates the bluish colour. One advantage of tangent space normal map texture is that we can transform the normal if the object's orientation is changed.

I did quite a lot of search on the internet. Most of them encourage to do the normal mapping and lighting in tangent space(I guess they use forward shading). This involves transform light and view vector into tangent space in vertex shader. For some reason, I have difficulty to visualize the tangent space(tangent coordinate system). It causes a lot of troubles during implementation and the final result is not very satisfied.
{% figure 2 %}
![Tangent space specular](/images/2013-11-23-normal-mapping/tangent_space_specular.jpg)
{% endfigure %}
Figure 2 is the lighting calculated in tangent space. You can see the specular light(using half angle) is bended. This is because I normalized view vector of tangent space in vertex shader.

The way I understand is that after vertex shader, rasterisation process uses [barycentric interpolation][1]. It actually does give you correct value when you interpolate positions across three vertices. But for any non-spatial attributes such as color and direction the approach simply does not work in some cases.

[1]:http://www.scratchapixel.com/lessons/3d-basic-lessons/lesson-9-ray-triangle-intersection/barycentric-coordinates/

View and light direction are used for specular lighting. They are calculated by subtracting eye and light position by the vertex position. Although it is a directional vector, but it does depends on the physical location. Vector normalization process actually changed the position from the original location, in this case produces a bended specular.

More information please refers to this article: [correctly interpolating view/light vectors on large triangles][2]

[2]:http://interplayoflight.wordpress.com/2013/05/17/correctly-interpolating-viewlight-vectors-on-large-triangles/

{% figure 3 %}
![Tangent space normal map](/images/2013-11-23-normal-mapping/tangent_space_normal_map.jpg)
{% endfigure %}
But if we enable normal map in tangent space, it is actually not too bad at least you won't notice the bended specular. It is very easy to miss this rendering bug.

Considering the deferred shading, however, requires the normal to be calculated in world or eye space anyway. Unless you want to encode the transformation matrix in the texture(every face has different transformation matrix) which transform eye and light vector into tangent space. 

I decided to do the normal mapping in eye space, in fragment shader. I just like placing many lights in the scene, plus I feel much easier to visualize and understand the process in eye space.

# Tangent Space
>As far as the name goes, tangent space is also known as texture space in some cases.
>
>Tangent space is just another such coordinate system, with it’s own origin. This is the coordinate system in which the texture coordinates for a face are specified. The tangent space system will most likely vary for any two faces.
>
><cite>[Siddharth Hegde, Messing with Tangent Space][3]</cite>

[3]:http://www.gamasutra.com/view/feature/1515/messing_with_tangent_space.php

I also like to treat the tangent space as a coordinate system before model space, the model's vertex starts in the 2D texture space(texture coordinate system) which describes how the texture pixel should be mapped to the model. Then we assign another 3D position value to the vertex defines its location in the model, which brings it into model space.

We just need to construct a matrix that transform vertex from texture space into model space. From there we are free to apply other matrix which transform to world or eye space.

# Calculate Tangent space to Model space Matrix using basis
Before doing the calculation, let's defines $$ \bigl[ \begin{smallmatrix} U \\ V \\ 1 \end{smallmatrix} \bigr] $$ which describes the vertex is mapped to the texture pixel at point $ \scriptsize ( U, V ) $ in texture space, and $$ \bigl[ \begin{smallmatrix} X \\ Y \\ Z \end{smallmatrix} \bigr] $$ to be the vertex's actual position in model space. We also have the basis of tangent space: $T$, $B$ and $N$ named **tangent**, **bitangent** and **normal**. These basis are also unit vector. Now we can create a linear relationship between tangent space and model space.

{% figure 4 %}
$$
\left[ \begin{matrix} 
T_x & B_x & N_x \\ 
T_y & B_y & N_y \\ 
T_z & B_z & N_z
\end{matrix} \right]
\times
\left[ \begin{array}{c} 
U \\ 
V \\
1 
\end{array} \right]
= 
\left[ \begin{array}{c} 
X \\ 
Y \\
Z 
\end{array} \right]
$$
{% endfigure %}

It is not obvious why the transform matrix consists of basis $$T$$, $$B$$ and $$N$$ **in model space**, the subscript $x$, $y$ and $z$ represents the basis projection onto the model space axis. In essence, the matrix transform is just description of a linear relationship between two vectors: how vector in model space changes while we change the vector in texture space.
{% figure 5 %}
![basis projection](/images/2013-11-23-normal-mapping/axis_2.jpg)
{% endfigure %}
{% fig_to 5 %} describe the process. All the basis of tangent space are projected onto the model space axis $$X$$. It is exactly the first row of the matrix: $ \scriptsize [ T_x  B_x  N_x ] $. The multiplication to the the vector $$ \bigl[ \begin{smallmatrix} U \\ V \\ 1 \end{smallmatrix} \bigr] $$ in texture space in fact describes the linear relationship between two spaces, producing a vector lies on $$X$$ axis in model space. It is easy to understand and produce the other two vectors lies on $$Y$$ and $$Z$$ axis, results the final model space vector.

# Calculate Tangent, Bitangent

Although we know $N$ which is the surface normal, $T$ and $B$ are still unknown vectors. We need to have 6 equations to solve $T$ and $B$. {% fig_to 4 %} can be used to construct the equations. Imagine a triangle $$ \triangle P_0 P_1 P_2 $$. At each point, it has corresponding texture coordinate $$(U_0,V_0), (U_1,V_1), (U_2,V_2)$$.

We are only interested in edges of the triangle. $\Delta U, \Delta V$ are the two components of the edge in texture space. We need two equations to solve 6 unknowns. Therefore we need two edges definitions, subscript represents the different edge.

$$
\Delta U_1 = U_1 - U_0 \quad \Delta V_1 = V_1 - V_0 \\
\Delta U_2 = U_2 - U_0 \quad \Delta V_2 = V_2 - V_0
$$

As previously described, $ T_x, B_x $ describes a ratio. How changing in tangent space causes changes in model space. $U, V$ are projection of the edge on $T B$ axis. By multiplying $U, V$ by corresponding $T_x, T_y, T_z, B_x, B_y, B_z$ the final model space vector can be calculated.

$$
(T_x*U_1 + B_x*V_1,\quad  T_y*U_1 + B_y*V_1,\quad  T_z*U_1 + B_z*V_1) = (X_1, Y_1, Z_1) \\
(T_x*U_2 + B_x*V_2,\quad  T_y*U_2 + B_y*V_2,\quad  T_z*U_2 + B_z*V_2) = (X_2, Y_2, Z_2)
$$

Combine two edge calculations, and simply it using matrix form.

$$
\left[ \begin{matrix} 
T_x & B_x \\ 
T_y & B_y \\ 
T_z & B_z
\end{matrix} \right]
\left[ \begin{matrix} 
U_1 & U_2 \\
V_1 & V_2
\end{matrix} \right]
=
\left[ \begin{matrix} 
X_1 & X_2 \\ 
Y_1 & Y_2 \\ 
Z_1 & Z_2
\end{matrix} \right]
$$

Multiply both side by $$ \left[ \begin{smallmatrix} U_1 & U_2 \\ V_1 & V_2 \end{smallmatrix} \right]^{-1} $$, [inverse of the matrix][4].

[4]: http://en.wikipedia.org/wiki/Invertible_matrix#Inversion_of_2.C3.972_matrices

$$
\left[ \begin{matrix} 
T_x & B_x \\ 
T_y & B_y \\ 
T_z & B_z
\end{matrix} \right]
=
\left[ \begin{matrix} 
X_1 & X_2 \\ 
Y_1 & Y_2 \\ 
Z_1 & Z_2
\end{matrix} \right]
*
\left[ \begin{matrix} 
U_1 & U_2 \\
V_1 & V_2
\end{matrix} \right]^{-1}

\\
\left[ \begin{matrix} 
T_x & B_x \\ 
T_y & B_y \\ 
T_z & B_z
\end{matrix} \right]
=
\left[ \begin{matrix} 
X_1 & X_2 \\ 
Y_1 & Y_2 \\ 
Z_1 & Z_2
\end{matrix} \right]
\scriptsize \frac{1}{U_1*V_2-U_2*V_1}
\normalsize \left[ \begin{matrix} 
V_2 & -U_2 \\
-V_1 & U_1
\end{matrix} \right]
$$

The $T$ and $B$ can now be easily calculated. Final tangent space to model space matrix can be constructed.

# WebGL JavaScript code
Tangent and Bitangent vector needs to be calculated for every vertex. Some tangent space normal mapping tutorial does not pass bitangent vector as an attribute. Instead, they restore the bitangent vector by doing cross product of vertex normal and tangent. This approach also requires an extra *handedness* value to be calculated and pass to the vertex shader attribute(usually stored in $w$ component of tangent vector). The *handedness* is required because some model is symmetric, in order to save memory only half side of the normal map is used, other side of normal map is mirrored. In this case, the cross product of normal and tangent vector will produce a bitangent vector with opposite direction.

Because I only concerns about deferred rendering, it is also definitely not ideal to calculate bitangent vector in fragment shader on every fragment. With a bit cost of memory providing the bitangent vector to the shader will solve all the problems mentioned above.

Below is the code for calculating tangent and bitangent. Just like calculating face's normal, accumulate the tangent and bitangent. Final normalization averages all the vectors.

It is per model operation, so should be placed in you Model class. So it only processes once. Treat them as an attributes of vertex in a model, just like normal and texture coordinate of the vertex. It is straightforward to understand.

{% highlight javascript linenos %}
// calculate tangent by accumulate the tangent vector just like calculating the face normal
this.tangents = Array.apply(null, new Array(72)).map(Number.prototype.valueOf, 0);
this.bitangents = Array.apply(null, new Array(72)).map(Number.prototype.valueOf, 0);
for(var i=0; i<12; ++i){
    // get the vertex index
    var i0 = this.indices[i*3];
    var i1 = this.indices[i*3+1];
    var i2 = this.indices[i*3+2];

    // edge 1 in model space
    var x1 = this.vertices[i1*3] - this.vertices[i0*3];
    var y1 = this.vertices[i1*3+1] - this.vertices[i0*3+1];
    var z1 = this.vertices[i1*3+2] - this.vertices[i0*3+2];
    // edge 2 in model space
    var x2 = this.vertices[i2*3] - this.vertices[i0*3];
    var y2 = this.vertices[i2*3+1] - this.vertices[i0*3+1];
    var z2 = this.vertices[i2*3+2] - this.vertices[i0*3+2];

    // edge in texture space
    var u1 = this.texCoords[i1*2] - this.texCoords[i0*2];
    var v1 = this.texCoords[i1*2+1] - this.texCoords[i0*2+1];
    var u2 = this.texCoords[i2*2] - this.texCoords[i0*2];
    var v2 = this.texCoords[i2*2+1] - this.texCoords[i0*2+1];

    // determinant of the 2x2 matrix
    var det = 1/(u1*v2 - u2*v1);

    // the linear relationship between model space and tangent space.
    var Tx = det * (v2*x1 - v1*x2);
    var Ty = det * (v2*y1 - v1*y2);
    var Tz = det * (v2*z1 - v1*z2);
    var Bx = det * (u1*x2 - u2*x1);
    var By = det * (u1*y2 - u2*y1);
    var Bz = det * (u1*z2 - u2*z1);

    // accumulate the tangent vector and bitangent vector
    // you will need to normalize the vectors in the end.(averaging)
    this.tangents[i0*3] += Tx;
    this.tangents[i0*3+1] += Ty;
    this.tangents[i0*3+2] += Tz;
    this.tangents[i1*3] += Tx;
    this.tangents[i1*3+1] += Ty;
    this.tangents[i1*3+2] += Tz;
    this.tangents[i2*3] += Tx;
    this.tangents[i2*3+1] += Ty;
    this.tangents[i2*3+2] += Tz;

    this.bitangents[i0*3] += Bx;
    this.bitangents[i0*3+1] += By;
    this.bitangents[i0*3+2] += Bz;
    this.bitangents[i1*3] += Bx;
    this.bitangents[i1*3+1] += By;
    this.bitangents[i1*3+2] += Bz;
    this.bitangents[i2*3] += Bx;
    this.bitangents[i2*3+1] += By;
    this.bitangents[i2*3+2] += Bz;
}

// normalize the accumulated tangent and bitangent vectors.
// It averages all the vectors.
for(var i=0; i<this.vertices.length/3; ++i){
    var n = vec3.fromValues(this.normals[i*3], this.normals[i*3+1], this.normals[i*3+2]);
    var t = vec3.fromValues(this.tangents[i*3], this.tangents[i*3+1], this.tangents[i*3+2]);
    var b = vec3.fromValues(this.bitangents[i*3], this.bitangents[i*3+1], this.bitangents[i*3+2]);

    vec3.normalize(t, t);
    this.tangents[i*3] = t[0];
    this.tangents[i*3+1] = t[1];
    this.tangents[i*3+2] = t[2];

    vec3.normalize(b, b);
    this.bitangents[i*3] = b[0];
    this.bitangents[i*3+1] = b[1];
    this.bitangents[i*3+2] = b[2];
}
{% endhighlight %}

Vertex shader
{% highlight glsl %}
v_Tangent = u_ModelViewMatrixInverseTranspose * a_Tangent;
v_Bitangent = u_ModelViewMatrixInverseTranspose * a_Bitangent;
{% endhighlight %}

Fragment shader
{% highlight glsl %}
vec3 calculateNormal(){
  // decode normal map
  vec3 normal = normalize(texture2D(normalTexture, v_TexCoord) * 2.0 - 1.0).xyz ;

  vec3 N = normalize(v_Normal);
  vec3 T = normalize(v_Tangent);
  vec3 B = normalize(v_Bitangent);
  // transform from tangent space into eye space
  // T,B,N corresponds to first, second and third COLUMN
  mat3 TBN = mat3(T, B, N);

  return TBN * normal;
}
{% endhighlight %}

This is the final result, without adding specular and gloss map.

![Per fragment normal map](/images/2013-11-23-normal-mapping/per_fragment_normal_map.jpg)

Also notice that the normal map texture is in the range of [0, 1], which has to be multiplied by 2 and minus 1 in order to map to the real normal range [-1, 1]. 