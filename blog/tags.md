---
layout: page
title: Tags
---

{% for tag in site.tags %}
  <h2 class='tag-header' id="{{ tag[0] }}-ref">{{ tag[0] }}</h2>
  <ul>
    {% assign pages_list = tag[1] %}

    {% for node in pages_list %}
      {% if node.title != null %}
        {% if group == null or group == node.group %}
          {% if page.url == node.url %}
          <li class="active"><a href="{{page.url}}" class="active">{{node.title}}</a></li>
          {% else %}
          <li><a href="{{page.url}}">{{node.title}}</a></li>
          {% endif %}
        {% endif %}
      {% endif %}
    {% endfor %}

    {% assign pages_list = nil %}
    {% assign group = nil %}
  </ul>
{% endfor %}
