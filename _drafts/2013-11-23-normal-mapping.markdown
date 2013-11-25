---
layout: post
title: "Normal Mapping"
date: 2013-11-23 22:54
comments: true
categories: 
cover: images/2013-11-23-normal-mapping/per_fragment_normal_map.jpg
---

The normal map generated from 3D computer graphics software is usually in tangent space. It encodes the normal vector in object face's local coordinate. 
![Normal map](/images/2013-11-23-normal-mapping/brick_texture_small.jpg)This means that if the normal vector is perpendicular to the object surface, its value will be [0.5, 0.5, 1] which creates the bluish colour. One advantage of tangent space normal map texture is that we can transform the normal if the object's orientation is changed.

I did quite a lot of search on the internet. Most of them encourage to do the normal mapping and lighting in tangent space(I guess they use forward shading). This involves transform light and view vector into tangent space in vertex shader. For some reason, I have difficulty to visualize the tangent space(tangent coordinate system). It causes a lot of troubles during implementation and the final result is not very satisfied.

![Tangent space specular](/images/2013-11-23-normal-mapping/tangent_space_specular.jpg)
Above is the lighting calculated in tangent space. You can see the specular light(using half angle) is bended. As I said, I cannot get my head around when doing lighting in tangent space. There might be some minor issues with my calculation. I doubt the tangent space view and light vector auto interpolation after vertex shader will give the "physically" correct result.

![Tangent space normal map](/images/2013-11-23-normal-mapping/tangent_space_normal_map.jpg)
But if we enable normal map in tangent space, it is actually not too bad at least you won't notice the bended specular. It is easy to fool the human eyes on a rough surface.

Considering the deferred shading, however, requires the normal to be calculated in world or eye space anyway. Unless you want to encode the transformation matrix in the texture(every face has different transformation matrix) which transform eye and light vector into tangent space. 

I decided to do the normal mapping in eye space, in fragment shader. I just like placing many lights in the scene, plus I feel much easier to visualize and understand the process in eye space.

# Tangent Space
>As far as the name goes, tangent space is also known as texture space in some cases.
>
>Tangent space is just another such coordinate system, with it’s own origin. This is the coordinate system in which the texture coordinates for a face are specified. The tangent space system will most likely vary for any two faces.
>
><cite>[Siddharth Hegde, Messing with Tangent Space][1]</cite>

[1]:http://www.gamasutra.com/view/feature/1515/messing_with_tangent_space.php

I also like to treat the tangent space as a coordinate system before model space, the model's vertex starts in the 2D texture space(texture coordinate system) which describes how the texture pixel should be mapped to the model. Then we assign another 3D position value to the vertex defines its location in the model, which brings it into model space.

We just need to construct a matrix that transform vertex from texture space into model space. From there we are free to apply other matrix which transform to world or eye space.

# Basis in rotation matrix
Let's defines $$\left[ \begin{array}{c} U \\ V \\ 1 \end{array} \right]$$ which describes the vertex is mapped to the texture pixel at point $$[U, V]$$ in texture space, and $$\left[ \begin{array}{c} X \\ Y \\ Z \end{array} \right]$$ to be the vertex's actual position in model space. We also have the basis of tangent space(unit vector): $$T$$, $$B$$ and $$N$$ named **tangent**, **bitangent** and **normal**. Now we can create a linear relation using matrix form:

$$
\left[ \begin{array}{c} 
T_x & B_x & N_x \\ 
T_y & B_y & N_y \\ 
T_z & B_z & N_z
\end{array} \right]
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

It is strange to see the transform matrix is consists of basis of tangent space $$T$$, $$B$$ and $$N$$ **in relation to the model space**. 

In essence, the matrix transform is just description of a linear relationship between two vectors: how vector in model space changes while we change the vector in texture space.
![Axis](/images/2013-11-23-normal-mapping/axis_2.jpg)
The picture above describe the process. All the basis of tangent space are projected onto the model space axis $$X$$. It is exactly the first row of the matrix $$\left[ \begin{array}{c} T_x & B_x & N_x \end{array} \right]$$. The multiplication to the the vector $$\left[ \begin{array}{c} U \\ V \\ 1 \end{array} \right]$$ in texture space in fact describes the linear relationship between two spaces, producing a vector lies on $$X$$ axis in model space. It is easy to understand and produce the other two vectors lies on $$Y$$ and $$Z$$ axis, results the final model space vector.

# Calculate Tangent, Bitangent


# Basis Axis in 2D
![Axis](/images/2013-11-23-normal-mapping/axis.jpg)
$$\vec{X}$$ and $$\vec{Y}$$ are the axis of model coordinate system, $$\vec{T}$$ and $$\vec{B}$$ are axis of tangent space coordinate system. $$\vec{p}$$ is a vector in tangent space. $$p_{t}$$ and $$p_{b}$$ are the projection of $$\vec{p}$$ on the axis, scalar value.

In $$\vec{T}\vec{B}$$ tangent space

$$ \vec{p} = p_{t}\vec{T} + p_{b}\vec{B} $$

$$\vec{T}$$ and $$\vec{B}$$ axis can be projected onto $$\vec{X}$$ and $$\vec{Y}$$ axis in model space, results $$T_{x}$$, $$T_{y}$$, $$B_{x}$$ and $$B_{y}$$. Because $$\vec{X}$$ and $$\vec{Y}$$ are basis vector, unit vector, we have

$$
\vec{T} = T_{x}\vec{X} + T_{y}\vec{Y} = T_{x} + T_{y}\\
\vec{B} = B_{x}\vec{X} + B_{y}\vec{Y} = B_{x} + B_{y}
$$

Let $$ \vec{p}_{model\,space} $$ to be the same vector $$\vec{p}$$ but in model space.

$$
\vec{p}_{model\,space} = p_{t}(T_{x} + T_{y}) + p_{b}(B_{x} + B_{y})
$$

Now, we've successfully transformed $$ \vec{p} $$ into model space $$\vec{p}_{model\,space}$$. The last step is to represent the linear equations in matrix form.

$$
\left[ \begin{array}{c} 
p_x \\ 
p_y 
\end{array} \right] 
= 
\begin{bmatrix} 
T_x & B_x \\ 
T_y & B_y 
\end{bmatrix} 
\times 
\left[ \begin{array}{c} 
p_t \\ 
p_b 
\end{array} \right]
$$

It is obvious that $$ \begin{bmatrix} T_x & B_x \\ T_y & B_y \end{bmatrix} $$ is the matrix we want which transforms tangent space into model space. Multiply both side by the $$ \left[ \begin{array}{c} p_t \\ p_b \end{array} \right]^{-1} $$ gives you the matrix.

$$
\left[ \begin{array}{c} 
p_x \\ 
p_y 
\end{array} \right] 
\times 
\left[ \begin{array}{c} p_t \\ p_b \end{array} \right]^{-1}
= 
\begin{bmatrix} 
T_x & B_x \\ 
T_y & B_y 
\end{bmatrix} 
\times 
\left[ \begin{array}{c} 
p_t \\ 
p_b 
\end{array} \right]
\times 
\left[ \begin{array}{c} p_t \\ p_b \end{array} \right]^{-1}
=
\begin{bmatrix} 
T_x & B_x \\ 
T_y & B_y 
\end{bmatrix} 
$$

Note that $$p_t$$ and $$p_b$$ can be actually treated as a vector, a vector from origin $$O$$ of the tangent space. This leads to a generalization.

$$
\left[ \begin{array}{c} p_t - q_t \\ p_b - q_b \end{array} \right]^{-1}
$$


Generalize to 3D

# Tangent Space to Eye Space

Construct the matrix transform from tangent to eye(world) space

# Normal decoding

{% highlight glsl %}
vec3 permuted = normalize(texture2D(bumpTexture, v_TexCoord) * 2.0 - 1.0).xyz;
{% endhighlight %}


![Per fragment normal map](/images/2013-11-23-normal-mapping/per_fragment_normal_map.jpg)
