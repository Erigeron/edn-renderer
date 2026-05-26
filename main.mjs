import mermaid from "mermaid";
import { main_$x_ } from "./js-out/app.main.mjs";

mermaid.initialize({
  startOnLoad: false,
  securityLevel: "loose",
  theme: "neutral",
});

let mermaidRenderQueued = false;

const renderMermaidBlocks = async () => {
  const hosts = document.querySelectorAll(".mermaid-host");

  for (const [index, host] of hosts.entries()) {
    const source = host.getAttribute("title") || "";
    const output = host.querySelector(".mermaid-output");
    if (!output) continue;

    if (!source.trim()) {
      output.textContent = "";
      continue;
    }

    if (host.dataset.renderedSource === source) continue;

    try {
      const graphId = `mermaid-${index}-${source.length}`;
      const { svg, bindFunctions } = await mermaid.render(
        graphId,
        source,
        output,
      );
      output.innerHTML = svg;
      bindFunctions?.(output);
      host.dataset.renderedSource = source;
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      output.textContent = `Mermaid render failed:\n${message}\n\n${source}`;
      host.dataset.renderedSource = "";
    }
  }
};

const scheduleRenderMermaidBlocks = () => {
  if (mermaidRenderQueued) return;
  mermaidRenderQueued = true;
  queueMicrotask(async () => {
    mermaidRenderQueued = false;
    await renderMermaidBlocks();
  });
};

const containsMermaidHost = (node) => {
  if (!(node instanceof Element)) return false
  return node.matches(".mermaid-host") || node.querySelector(".mermaid-host") !== null
}

const mermaidObserver = new MutationObserver((mutations) => {
  for (const mutation of mutations) {
    if (mutation.type !== "childList" || mutation.addedNodes.length === 0) {
      continue
    }

    for (const node of mutation.addedNodes) {
      if (containsMermaidHost(node)) {
        scheduleRenderMermaidBlocks()
        return
      }
    }
  }
});

window.renderMermaidBlocks = renderMermaidBlocks;

main_$x_();
mermaidObserver.observe(document.body, { childList: true, subtree: true });
scheduleRenderMermaidBlocks();

if (import.meta.hot) {
  import.meta.hot.accept("./js-out/app.main.mjs", (main) => {
    main.reload_$x_();
    scheduleRenderMermaidBlocks();
  });
}
