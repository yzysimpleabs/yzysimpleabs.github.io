---
layout: page
title: "首页"
---

<section class="hero-minimal">
  <p class="section-kicker">CS 背景产品经理</p>
  <h1 class="hero-title">用产品理解技术，用技术校准产品。</h1>
  <p class="hero-subtitle">这里先不堆太多信息，只保留一个清晰的入口。后续再逐步填充内容、栏目与个人介绍。</p>
</section>

<section class="home-grid">
  <div class="home-col-main">
    <h2 class="section-title">最近文章</h2>
    <div class="post-list-clean">
      {% for post in site.posts limit:4 %}
      <article class="post-row">
        <p class="post-meta-line">{{ post.date | date: "%Y-%m-%d" }}</p>
        <h3><a href="{{ post.url | relative_url }}">{{ post.title | escape }}</a></h3>
      </article>
      {% endfor %}
    </div>
    <p><a class="text-link" href="/blog/">查看全部文章</a></p>
  </div>

  <aside class="home-col-side">
    <div class="info-block">
      <p class="section-kicker">当前结构</p>
      <p>首页负责建立整体气质，博客页专门承接文章列表，关于页先保留为空白结构，等风格定稿后再填内容。</p>
    </div>
  </aside>
</section>
