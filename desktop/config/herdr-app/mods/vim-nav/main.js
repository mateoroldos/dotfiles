// ctrl+h/j/k/l: in vim, pass the key on (vim crosses into the next pane at
// its own edge, see nvim's keymaps.lua); anywhere else, move pane focus.
// Keys reach only a shown copy: layouts/personal.json holds a 1px block of it.

import { View, div } from "gpui-kit";
import { focused, hc, nextCommand, panes, run } from "herdr";

const KEYS = { left: "ctrl+h", down: "ctrl+j", up: "ctrl+k", right: "ctrl+l" };
const VIMS = ["nvim", "vim"];

export default class VimNav extends View {
  init(_props, cx) {
    cx.spawn(async () => {
      for (;;) {
        const dir = await nextCommand();
        if (!KEYS[dir]) continue;

        const f = focused();
        const pane = panes().find((p) => p.pane === f?.pane);

        if (f?.terminal && VIMS.includes(pane?.program.key)) await hc(["keys", f.terminal, KEYS[dir]]);
        else run("pane.go", { direction: dir });
      }
    });
  }

  render() {
    return div();
  }
}
