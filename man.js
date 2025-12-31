(() => {
  const frame = document.getElementById(
    location.hash === "#paranoia" ? "paranoia" : "iamanaws",
  );
  const progress = document.getElementById("progress");
  const overlay = document.getElementById("help-overlay");
  const win = () => frame.contentWindow;

  const updateProgress = () => {
    const w = win(), doc = w?.document.documentElement;
    if (!doc) return progress.textContent = "0%";
    const top = doc.scrollTop, max = doc.scrollHeight - w.innerHeight;
    progress.textContent = max <= 0 || top >= max ? "(END)" : `${Math.round(top / max * 100)}%`;
  };

  const handleKey = (e) => {
    if (e.target.matches("input,textarea") || e.ctrlKey || e.metaKey || e.altKey) return;

    const hide = () => overlay.classList.remove("visible");
    if (overlay.classList.contains("visible"))
      return /^(Escape|[qh?])$/.test(e.key) && (hide(), e.preventDefault());

    const w = win(), h = w?.innerHeight ?? innerHeight;
    const scroll = { j: 60, ArrowDown: 60, k: -60, ArrowUp: -60, d: h / 2, u: -h / 2, " ": h - 50, b: 50 - h };

    const action = {
      h: () => overlay.classList.add("visible"),
      "?": () => overlay.classList.add("visible"),
      q: () => history.length > 1 ? history.back() : location.href = "./index.html",
      g: () => w?.scrollTo(0, 0),
      G: () => w?.scrollTo(0, w.document.documentElement.scrollHeight),
    }[e.key] ?? (scroll[e.key] != null && (() => w?.scrollBy(0, scroll[e.key])));

    action && (action(), e.preventDefault());
  };

  document.addEventListener("keydown", handleKey);
  overlay.addEventListener("click", (e) => e.target === overlay && overlay.classList.remove("visible"));

  frame.addEventListener("load", () => {
    win()?.addEventListener("scroll", updateProgress, { passive: true });
    win()?.document.addEventListener("keydown", handleKey);
    updateProgress();
  });
})();
