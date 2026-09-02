# beatforge-site

Static marketing site for [BeatForge](https://github.com/RepousiosJim/beatforge-site), an AI-assisted desktop DAW for Windows by Gemelon Studios. Plain HTML/CSS/JS, no build step — deployed as-is to Cloudflare Pages.

Releases published on this repo also serve as the electron-updater feed the BeatForge app polls for new versions. Never delete `latest.yml` from a release, and don't remove or rename published release assets — doing so breaks auto-update for everyone on an older version.
