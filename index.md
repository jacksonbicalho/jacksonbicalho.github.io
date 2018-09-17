---
layout: default
title: Home
---

<div id="posts-home">
    {% for post in site.posts %}
        <h2 class="entry-title post-title">
            <a href="{{ post.url }}" rel="bookmark">{{ post.title }}</a>
        </h2>
<p>{{ ((post.content | split:'<!--excerpt.start-->' | last) | split: '<!--excerpt.end-->' | first) | strip_html | truncatewords: 50 }}
    {% endfor %}
</p>




