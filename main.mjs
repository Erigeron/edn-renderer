import mermaid from "mermaid";
import * as echarts from "echarts";
import { CalcitTag, CalcitSliceList, listToArray } from "@calcit/procs";
import { main_$x_ } from "./js-out/app.main.mjs";

function ednToJs(v) {
  if (v === null || v === undefined) return null;
  if (typeof v === "number" || typeof v === "boolean") return v;
  if (typeof v === "string") return v;
  if (v instanceof CalcitTag) return v.value;
  if (v instanceof CalcitSliceList) return listToArray(v).map(ednToJs);
  if (v && v.constructor && v.constructor.name === "CalcitSliceMap") {
    const obj = {};
    for (const [k, val] of v.pairs()) {
      const key = k instanceof CalcitTag ? k.value : String(k);
      obj[key] = ednToJs(val);
    }
    return obj;
  }
  return String(v);
}

function buildEchartsOption({ kind, title, series }) {
  const base = {
    animation: false,
    tooltip: {},
    ...(title ? { title: { text: title } } : {}),
  };
  const names = (series || []).map((s) => s.label);
  const values = (series || []).map((s) => s.value);
  switch (kind) {
    case "line":
      return {
        ...base,
        xAxis: { type: "category", data: names },
        yAxis: { type: "value" },
        series: [{ type: "line", data: values }],
      };
    case "pie":
      return {
        ...base,
        series: [
          {
            type: "pie",
            data: (series || []).map((s) => ({
              name: s.label,
              value: s.value,
            })),
          },
        ],
      };
    case "scatter":
      return {
        ...base,
        xAxis: { type: "category", data: names },
        yAxis: { type: "value" },
        series: [{ type: "scatter", data: values }],
      };
    default:
      return {
        ...base,
        xAxis: { type: "category", data: names },
        yAxis: { type: "value" },
        series: [{ type: "bar", data: values }],
      };
  }
}

window.renderEcharts = (el, seriesCalcit, kindCalcit, titleCalcit) => {
  try {
    const series = ednToJs(seriesCalcit);
    const kind = ednToJs(kindCalcit);
    const title = ednToJs(titleCalcit);
    const option = buildEchartsOption({ kind, title, series });
    let chart = echarts.getInstanceByDom(el);
    if (!chart) chart = echarts.init(el);
    chart.setOption(option, true);
  } catch (e) {
    console.error("ECharts render error:", e);
  }
};

window.disposeEcharts = (el) => {
  const chart = echarts.getInstanceByDom(el);
  if (chart) chart.dispose();
};

window.addEventListener("resize", () => {
  for (const host of document.querySelectorAll(".echarts-host")) {
    const chart = echarts.getInstanceByDom(host);
    if (chart) chart.resize();
  }
});

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
  if (!(node instanceof Element)) return false;
  return (
    node.matches(".mermaid-host") ||
    node.querySelector(".mermaid-host") !== null
  );
};

const mermaidObserver = new MutationObserver((mutations) => {
  for (const mutation of mutations) {
    if (mutation.type !== "childList" || mutation.addedNodes.length === 0) {
      continue;
    }

    for (const node of mutation.addedNodes) {
      if (containsMermaidHost(node)) {
        scheduleRenderMermaidBlocks();
        return;
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
