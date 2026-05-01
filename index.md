---
layout: page
title: "首页"
---

<div class="home-shell">
  <aside class="intro-column">
    <h1 class="intro-name">yzysimpleabs</h1>
    <p class="intro-role">CS 背景的产品经理</p>
    <p class="intro-note">先用一个更克制的结构把站点骨架定下来，再逐步填充内容。</p>
    <nav class="mini-nav">
      <a href="/blog/">Blog</a>
      <a href="/about/">About</a>
    </nav>
  </aside>

  <section class="content-column">
    <div class="content-section">
      <p class="section-kicker">Overview</p>
      <h2 class="section-heading">用产品理解技术，用技术校准产品。</h2>
      <p class="section-text">这个博客会逐步整理我对产品方法论、AI、技术趋势、读书笔记与知识管理的思考。当前先确定页面结构与整体气质，再填具体内容。</p>
    </div>

    <div class="content-section">
      <div class="section-head-row">
        <h2 class="section-heading">Recent Posts</h2>
        <a class="text-link" href="/blog/">View all</a>
      </div>
      <div class="post-list-minimal">
        {% for post in site.posts limit:4 %}
        <article class="post-item-minimal">
          <a class="post-item-title" href="{{ post.url | relative_url }}">{{ post.title | escape }}</a>
          <p class="post-item-meta">{{ post.date | date: "%Y-%m-%d" }}</p>
        </article>
        {% endfor %}
      </div>
    </div>
  </section>
</div>
