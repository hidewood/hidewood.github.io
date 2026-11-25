# hidewood's blog

Hugo + PaperMod 个人技术博客，目标地址：https://hidewood.github.io/ 。

网站界面、首页介绍和 About 页面使用英文。文章可以用中文或英文编写，保留 CJK 字数统计支持；无需为中文文章另外设置中文站点语言。

## 本地预览

在项目根目录执行 `.\.tools\hugo\hugo.exe server`，打开 http://localhost:1313/ 。
`.tools` 为已校验的本地 Hugo 工具，不提交到仓库。
换电脑后可安装 Hugo 0.170.1，并使用 `hugo server`。

## 写文章

执行 `.\.tools\hugo\hugo.exe new content posts/my-note.md`。
编辑生成的 Markdown，准备发布时设置 `draft: false`。
图片放到 `static/images/`，文章用 `/images/文件名` 引用。
文章日期不要设在未来，否则默认不发布。

## 首次部署

1. 本机运行 `gh auth login --hostname github.com --git-protocol https --web --scopes workflow`，登录 hidewood。
2. 运行 `powershell -ExecutionPolicy Bypass -File scripts/deploy.ps1`。
3. 在 GitHub Actions 等待 Publish blog 成功，然后检查 https://hidewood.github.io/ 。

脚本会检查账号、构建站点、创建公开仓库、配置 Pages、提交并推送。
检测到已存在的目标仓库或 origin 时会停止，需先检查再继续，不会覆盖已有站点。

## 更新网站

先本地预览，再运行：

```powershell
git add .
git commit -m "Update blog"
git push
```

推送到 main 会自动部署，不需要提交 public 目录。

## 配置位置

- 名称、介绍、导航：`hugo.yaml`
- 个人介绍：`content/about.md`
- 文章：`content/posts/`
- 额外样式：`assets/css/extended/custom.css`

起始文章用于检查排版，正式发布前可替换。数学公式尚未配置。
PaperMod 是子模块，重新克隆时使用 `git clone --recurse-submodules`。
