import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Container, Text, Spacer } from "@earendil-works/pi-tui";

const ASCII_MOMBE = [
  "███╗   ███╗ ██████╗ ███╗   ███╗██████╗ ███████╗",
  "████╗ ████║██╔═══██╗████╗ ████║██╔══██╗██╔════╝",
  "██╔████╔██║██║   ██║██╔████╔██║██████╔╝█████╗  ",
  "██║╚██╔╝██║██║   ██║██║╚██╔╝██║██╔══██╗██╔══╝  ",
  "██║ ╚═╝ ██║╚██████╔╝██║ ╚═╝ ██║██████╔╝███████╗",
  "╚═╝     ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═════╝ ╚══════╝",
];

const ASCII_090 = [
  " ██████╗  █████╗  ██████╗ ",
  "██╔═══██╗██╔══██╗██╔═══██╗",
  "██║   ██║╚██████║██║   ██║",
  "██║   ██║ ╚═══██║██║   ██║",
  "╚██████╔╝  ████╔╝╚██████╔╝",
  " ╚═════╝   ╚═══╝  ╚═════╝ ",
];

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    await ctx.ui.custom<void>((_tui, theme, _kb, done) => {
      const root = new Container();

      root.addChild(new Spacer(1));

      for (const line of ASCII_MOMBE) {
        root.addChild(new Text(theme.fg("accent", line), 2, 0));
      }

      for (const line of ASCII_090) {
        root.addChild(new Text(theme.fg("borderAccent", line), 4, 0));
      }

      root.addChild(new Spacer(1));

      root.addChild(
        new Text(
          theme.fg("accent", theme.bold("  Hi Mombe, happy vibing! 🤙")),
          2,
          0
        )
      );

      root.addChild(new Spacer(1));

      root.addChild(
        new Text(theme.fg("dim", "  Press any key to continue…"), 2, 0)
      );

      root.addChild(new Spacer(1));

      return {
        render: (width: number): string[] => {
          const divider = theme.fg("accent", "─".repeat(width > 0 ? width : 60));
          return [divider, ...root.render(width), divider];
        },
        invalidate: () => root.invalidate(),
        handleInput: (_data: string) => done(undefined),
      };
    });
  });
}
