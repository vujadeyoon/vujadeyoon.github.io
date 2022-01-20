---
layout: page
title: Publications
permalink: /publications/
description: Publications by categories in reversed chronological order.
years: [2021, 2020, 2019, 2018, 2015]
nav: true
---
<!-- _pages/publications.md -->
<div class="publications">

{%- for y in page.years %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f papers -q @*[year={{y}}]* %}
{% endfor %}

</div>
