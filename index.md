---
layout: default
title: Home
---

<div id="posts-home">
    {% for post in site.posts %}
        <h2 class="entry-title post-title">
            <a href="{{ post.url }}" rel="bookmark">{{ post.title }}</a>
        </h2>
        <p> {% include post_date_time_br.html %} </p>
    {% endfor %}
</div>





