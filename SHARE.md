# Share LUNA NAV — plain-English guide

You do **not** need Python, a terminal, or a server to show the demo. Pick one of these.

## Option A — open it on your laptop (10 seconds)

1. Double-click **`LUNA-NAV.html`**.
2. It opens in Chrome or Edge.
3. Everything is inside that one file. No internet is needed.

Use this at the judging table. It cannot “refuse to connect” because there is no server.

## Option B — get a public web link in about two minutes (easiest)

1. Go to **https://app.netlify.com/drop**
2. Drag the **`LUNA-NAV-public`** folder onto the page.
3. Wait for the upload, then copy the link Netlify gives you.

That link works on any phone or laptop. No account is required for the basic drop.

## Option C — put it on GitHub (your partner’s suggestion)

1. Sign in to GitHub and click **New repository**.
2. Name it `luna-nav-demo`, choose **Public**, click **Create repository**.
3. Click **Add file → Upload files**.
4. Drag **`index.html`** from the `LUNA-NAV-public` folder into the page.
5. Click **Commit changes**.
6. Open **Settings → Pages**.
7. Under “Build and deployment”, choose **Deploy from a branch**, branch **main**, folder **/(root)**, click **Save**.
8. Wait about a minute. Your link is:

   `https://YOUR-GITHUB-NAME.github.io/luna-nav-demo/`

That is the link to share with judges, friends, or your partner. GitHub Pages serves it for free.

## Option D — the full live version (date changes, custom points)

1. Install Python 3.12 from python.org (one time).
2. Open the `luna-nav` folder.
3. Double-click **`LUNA-NAV.bat`** (Windows) or run **`./run.sh`** (Mac/Linux).
4. Wait for “API ready”, then the browser opens at `http://127.0.0.1:8010`.

`LUNA-NAV.bat` bypasses the PowerShell script-policy error and waits for the server before opening the browser, so the “refused to connect” screen is gone. Keep the window open while demoing.

This version can change dates, evaluate custom coordinates and recompute SPICE. It is not needed for the public demo.

## Other places you can put it

These all host the **static** console (fixed date) with no coding:

| Service | Effort | Notes |
|---|---|---|
| **Netlify Drop** | drag a folder | Instant URL, no account for a basic drop |
| **GitHub Pages** | upload `index.html` | Free permanent URL, works with the public repo |
| **Cloudflare Pages** | upload folder | Fast, free, good for a custom domain |
| **Vercel** | upload folder | Free hobby tier, instant URL |

You can also **embed** the hosted link in Google Sites, Notion, WordPress or a QR code. Any of those just needs the URL from the table above.

The full live version (changing dates, custom coordinates) cannot run on those static hosts. It needs a Python host such as Render, Railway or Fly.io, or `LUNA-NAV.bat` on your own laptop.

## What to send to whom

| Audience | Send |
|---|---|
| Judges at the table | `LUNA-NAV.html` (double-click) or the Netlify/GitHub link |
| Partner reviewing code | `LUNA-NAV-source.zip` |
| Someone who wants the full app | the `LUNA-NAV` folder + `run.ps1` |

## If Edge shows a blank page or refuses to connect

1. **Extract the zip first.** Do not double-click the HTML from inside the zip preview.
2. Right-click `LUNA-NAV.html` → **Properties** → tick **Unblock** → **Apply**.
3. Double-click **`OPEN-IN-EDGE.bat`** (it clears the block and opens Edge).
4. If it still fails, copy the file to `C:\LUNA-NAV\` and open it there.
5. Or use the GitHub Pages / Netlify link, which avoids local-file restrictions entirely.

The file is tested in Chromium and in Microsoft Edge 157. A blank page in Edge is almost always the “file from another computer” block or opening from inside a zip/OneDrive preview, not the app.

## If the link “refuses to connect”

That only happens with the local server version when its terminal window is closed. The one-file HTML and the Netlify/GitHub link have no local server, so they do not have that problem.
