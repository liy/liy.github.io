---
layout: post
title: "Octopress to Jekyll"
date: 2013-11-23 21:41
comments: true
cover: http://jekyllrb.com/img/octojekyll.png
categories: 
---
Try to get a new theme for my blog. I'm not very satisfied with Octopress' slow update cycle, I decided to switch to the Jekyll.(Although Octopress is built on top of Jekyll) Since I'm not proficient in Ruby, it turned out to be a quite difficult job for me.

Github pages does not support certain plugins probably because of security reason. I have to generate the static site locally and push it to the master branch of my blog repository.(For some reason this repository use master branch for github page, usually should be gh-pages) This means I need to maintain two branches, manually. One for the source of my blog, one for the actual html site, which is not ideal.

I copied some rake task from internet and Octopress rake file for handling site generateion, deployment, post creation.

It do the jobs for now. Till next time, hopefully I'll have some proper notes for graphics programming.