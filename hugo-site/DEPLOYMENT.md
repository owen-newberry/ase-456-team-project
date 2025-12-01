# Deployment to GitHub Pages

1. Update `hugo-site/hugo.toml`:
   - Set `baseURL` to your GitHub Pages URL with a trailing slash, e.g. `https://username.github.io/repo-name/`
   - Set `params.githubRepo` to your repository URL.

2. Commit and push the `hugo-site/` directory and this workflow.

3. GitHub Actions will build the site and deploy automatically on push to `main` when files in `hugo-site/` change.

4. Replace the placeholder PDFs in `hugo-site/static/pdfs/` with your real PDFs.

Notes
- All internal links are generated using `absURL` so the site will work when hosted under a repository subpath.
