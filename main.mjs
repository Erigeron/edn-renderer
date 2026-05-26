import * as echarts from "echarts";
import { main_$x_ } from "./js-out/app.main.mjs";

window.addEventListener("resize", () => {
  for (const host of document.querySelectorAll(".echarts-host")) {
    const chart = echarts.getInstanceByDom(host);
    if (chart) chart.resize();
  }
});

main_$x_();

if (import.meta.hot) {
  import.meta.hot.accept("./js-out/app.main.mjs", (main) => {
    main.reload_$x_();
  });
}
