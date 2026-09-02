const FALLBACK = { version: "v0.1.0", date: "", size: "" };

async function loadRelease() {
  const versionEls = document.querySelectorAll("[data-release-version]");
  const metaEls = document.querySelectorAll("[data-release-meta]");
  try {
    const res = await fetch("https://api.github.com/repos/RepousiosJim/beatforge-site/releases/latest");
    if (!res.ok) throw new Error("no release yet");
    const data = await res.json();
    const asset = (data.assets || []).find(a => a.name.endsWith(".exe")) || data.assets?.[0];
    const version = data.tag_name || FALLBACK.version;
    const date = data.published_at ? new Date(data.published_at).toLocaleDateString("en-US", { year: "numeric", month: "short", day: "numeric" }) : "";
    const size = asset ? `${(asset.size / (1024 * 1024)).toFixed(0)} MB` : "";
    versionEls.forEach(el => (el.textContent = version));
    metaEls.forEach(el => (el.textContent = [version, date, size].filter(Boolean).join(" · ")));
  } catch {
    versionEls.forEach(el => (el.textContent = FALLBACK.version));
    metaEls.forEach(el => (el.textContent = FALLBACK.version));
  }
}

loadRelease();

document.querySelectorAll("[data-copy]").forEach((btn) => {
  btn.addEventListener("click", async () => {
    await navigator.clipboard.writeText(document.getElementById(btn.dataset.copy).textContent);
    btn.textContent = "Copied";
    setTimeout(() => (btn.textContent = "Copy"), 1500);
  });
});
