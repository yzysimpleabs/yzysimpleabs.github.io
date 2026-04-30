# yzysimpleabs.github.io

这份 README 记录本站从 0 搭建到可持续写作发布的踩坑总结与 SOP（Windows + GitHub Pages + Jekyll + Obsidian）。

## 1. 站点基础结构（Jekyll + minima）

仓库根目录关键文件/目录：

- `_config.yml`：站点配置（主题、网址、时区、永久链接等）
- `index.md`：首页（minima 的 `home` 布局会自动列出最新文章）
- `_posts/`：文章目录，文件名必须是 `YYYY-MM-DD-xxx.md`
- `_includes/head-custom.html`：给主题扩展 head（这里用于 MathJax）
- `assets/img/`：发布时自动收纳图片
- `publish.ps1`：把 Obsidian Markdown 发布成 Jekyll 文章的脚本

## 2. 写作与发布 SOP（Obsidian → Jekyll）

你的 Obsidian 目录示例：

- Vault/写作目录：`C:\Users\28564\Documents\Obsidian Vault\Mypages001`
- Markdown 与图片在同一目录

### 2.1 推荐的 Obsidian 写法约定

- 图片尽量用 Obsidian 语法：`![[图片名.png]]`
- 双链用：`[[笔记]]` 或 `[[笔记|别名]]`
- 标签可以在正文写 `#tag`，也可以写在 YAML 的 `tags:` 里
- 数学用 `$...$`（行内）和 `$$...$$`（块级）

### 2.2 发布单篇文章（最常用）

1. 在仓库根目录运行发布脚本：

```powershell
cd D:\mypage
.\publish.ps1 -Source "C:\Users\28564\Documents\Obsidian Vault\Mypages001\我的新文章.md"
```

1. 生成结果：

- 新文章会出现在：`D:\mypage\_posts\YYYY-MM-DD-<slug>.md`
- 图片会自动复制到：`D:\mypage\assets\img\`
- Obsidian 图片语法 `![[xxx.png]]` 会被替换为网页可用的 `![](/assets/img/xxx.png)`
- `[[双链]]` 若能匹配到已发布文章，会转成站内链接；匹配不到会在终端列出未解析列表

1. 提交并推送上线：

```powershell
cd D:\mypage
git add .
git commit -m "发布新文章"
git push
```

### 2.3 一次发布多篇（每周发几篇）

对每篇文章都执行一次发布命令，然后只提交推送一次即可：

```powershell
cd D:\mypage
.\publish.ps1 -Source "C:\Users\28564\Documents\Obsidian Vault\Mypages001\文章A.md"
.\publish.ps1 -Source "C:\Users\28564\Documents\Obsidian Vault\Mypages001\文章B.md"

git add .
git commit -m "批量发布文章"
git push
```

## 3. 踩坑总结

### 3.1 SSH 认证相关    

- `Key is invalid`：通常是没有从 `*.pub` 原样复制整行，或复制时被截断/换行；必须粘贴 `id_ed25519_github.pub` 的整行内容
- `Permission denied (publickey)`：通常是 GitHub 没加对应公钥，或 Git/SSH 没用到那把 key；先用 `ssh -i ... -T git@github.com` 验证
- `ssh-agent` 启不起来：可以不依赖 agent，直接用 `ssh -i ...` 验证与推送；配置 `~/.ssh/config` 更稳

### 4.2 图片裂图（文件名有空格/中文）

症状：文章里图片显示为裂图。

原因：图片文件名包含空格（如 `Pasted image 20260430160833.png`），如果链接里不做 URL 编码，浏览器请求路径会 404。

解决：

- 发布脚本已对图片路径做 URL 编码（空格会变成 `%20`）
- 如果你手动写图片链接，确保写成：

```md
![](/assets/img/Pasted%20image%2020260430160833.png)
```

## 5. 常用命令速查

```powershell
# 查看当前状态
git status

# 查看提交历史（简版）
git log --oneline -n 20

# 拉取远端更新并合并
git fetch origin
git pull origin main

# 发布一篇 Obsidian 文章
cd D:\mypage
.\publish.ps1 -Source "C:\Users\28564\Documents\Obsidian Vault\Mypages001\我的新文章.md"
```

