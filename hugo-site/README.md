# Hugo Site (local development)

Prerequisites
- Install Hugo extended: https://gohugo.io/getting-started/installing

Local preview

```bash
# serve the site from the hugo-site directory
hugo server -D -s .
```

Build

```bash
# from hugo-site directory
hugo --minify -d public
```

Notes
- Replace `[YOUR_GITHUB_PAGES_URL]` in `hugo.toml` with your GitHub Pages URL, e.g. `https://username.github.io/repo-name/`.
- Place your actual PDF files in `static/pdfs/` if you want them available in the documentation center.
