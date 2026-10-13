# Static buildlog

The public site is built from this directory with GitHub Pages' Jekyll action.
It uses the existing Tailwind/daisyUI styles. Rails remains available for rollback
until the production cutover has been verified.

## Publish an entry

Create `_entries/9.md` (or the next unused number):

```markdown
---
date: "2026-10-13T15:00:00+02:00"
permalink: /entries/9/
link: https://example.com
---
What shipped, what broke, or what I learned.
```

The reference link is optional. Keep an entry's permalink once published and use
an ISO 8601 date with an explicit timezone. Entry bodies support Markdown.
Commit and push the entry; merging to `main` publishes it after the static check.
The build publishes the newest 50 entries in the feed; older entry pages remain.

The initial eight entries came from the existing public RSS feed and entry
pages on 2026-10-13. No production database or credentials were accessed.

## Preview and check

From the repository root:

```sh
npm ci
bundle exec tailwindcss -i app/assets/tailwind/application.css -o site/assets/style.css --minify
cp public/icon.svg public/icon.png public/og-image.png public/robots.txt site/
docker run --rm --entrypoint jekyll -v "$PWD/site:/site" -v "$PWD/_site:/output" ghcr.io/actions/jekyll-build-pages:v1.0.13 build --source /site --destination /output
cp _site/feed.xml _site/feed
bundle exec ruby script/check_static_site.rb
python3 -m http.server 8080 --directory _site
```

Open `http://localhost:8080`. The static workflow also uploads a preview artifact
on pull requests without deploying it.

## Production cutover — requires owner approval

1. Verify a backup of the existing Buildlog database outside the VPS. Keep it
   private: the database contains author authentication records as well as posts.
2. Check whether any new entries were posted after the eight-entry export.
   Copy additional public entries before changing the author workflow.
3. Enable **Settings → Pages → Source: GitHub Actions** in `ozzgio/buildlog`.
   Set the custom domain to `log.ozzo.blog` and verify the domain under the
   account's Pages settings.
4. Merge the static-site change and confirm that the Pages deployment succeeds.
5. Replace only the `log` DNS record with a DNS-only CNAME to `ozzgio.github.io`.
   Leave the apex blog, One Nil and other app records unchanged. Enable Enforce
   HTTPS once GitHub has issued the certificate.
6. Verify the homepage, every `/entries/1` through `/entries/8` URL, `/entries`,
   `/feedback`, `/feed.xml`, and `/feed` on the public domain. Confirm that the
   legacy feed returns XML, including its HTTP content type, in an RSS reader.
7. With explicit approval, stop only Buildlog's application container. Keep its
   storage and backup during the rollback period; other VPS apps continue running.

The static site intentionally has no author login, password-reset endpoints or
web posting form. Publishing now happens through Markdown and Git.

Rollback: point the `log` record back to the VPS and start the original Buildlog
container. Keep its deployment files and database until the cutover is accepted.
