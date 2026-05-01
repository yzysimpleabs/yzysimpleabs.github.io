---
layout: page
title: "首页"
---

<section class="hero-card">
  <p class="hero-eyebrow">CS 背景产品经理</p>
  <h1 class="hero-title">用产品视角理解技术，用技术视角校准产品。</h1>
  <p class="hero-subtitle">这里记录我对产品方法论、AI、用户研究、增长、技术趋势与个人学习过程的长期思考。</p>
  <div class="hero-actions">
    <a class="button-primary" href="/blog/">进入博客</a>
    <a class="button-secondary" href="/about/">关于我</a>
  </div>
</section>

## 我会写什么

<div class="feature-grid">
  <div class="feature-card">
    <h3>产品方法论</h3>
    <p>记录产品认知、需求分析、增长、用户洞察与组织协同的理解。</p>
  </div>
  <div class="feature-card">
    <h3>技术与 AI</h3>
    <p>从产品经理视角理解 AI、工程实现、工具链与技术趋势。</p>
  </div>
  <div class="feature-card">
    <h3>读书与笔记</h3>
    <p>持续输出读书笔记、模型拆解、框架整理与可复用的方法。</p>
  </div>
</div>

## 最近文章

<div class="post-list-enhanced">
  {% for post in site.posts limit:3 %}
  <article class="post-card">
    <p class="post-meta-line">{{ post.date | date: "%Y-%m-%d" }}</p>
    <h3><a href="{{ post.url | relative_url }}">{{ post.title | escape }}</a></h3>
    {% if post.excerpt %}
    <p>{{ post.excerpt | strip_html | truncate: 120 }}</p>
    {% endif %}
  </article>
  {% endfor %}
</div>

<p><a class="button-secondary" href="/blog/">查看全部文章</a></p>
