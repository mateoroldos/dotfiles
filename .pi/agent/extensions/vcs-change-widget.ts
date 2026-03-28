import type {
  ExtensionAPI,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";

type ExecResult = {
  stdout: string;
  stderr: string;
  code: number;
  killed: boolean;
};

type Segment = {
  text: string;
  role:
    | "muted"
    | "dim"
    | "bookmark"
    | "distance"
    | "success"
    | "error"
    | "warning"
    | "text";
};

type VcsState = {
  kind: "jj" | "git" | "none";
  line: string;
  segments: Segment[];
};

const widgetKey = "vcs-change";
const refreshMs = 3_000;
const fallback = "· no jj/git repo";

const trim = (value: string | undefined) => value?.trim() ?? "";

const text = (value: string, role: Segment["role"] = "text"): Segment => ({
  text: value,
  role,
});

const exec = async (
  pi: ExtensionAPI,
  cmd: string,
  args: string[],
  ctx: ExtensionContext,
): Promise<ExecResult | undefined> =>
  pi
    .exec(cmd, args, { cwd: ctx.cwd, timeout: 2_000 })
    .catch(() => undefined) as Promise<ExecResult | undefined>;

const isJjRepo = async (pi: ExtensionAPI, ctx: ExtensionContext) => {
  const result = await exec(pi, "jj", ["root", "--quiet"], ctx);
  return result?.code === 0;
};

const isGitRepo = async (pi: ExtensionAPI, ctx: ExtensionContext) => {
  const result = await exec(
    pi,
    "git",
    ["rev-parse", "--is-inside-work-tree"],
    ctx,
  );
  return result?.code === 0 && trim(result.stdout) === "true";
};

const jjNearestBookmark = async (pi: ExtensionAPI, ctx: ExtensionContext) => {
  const above = await exec(
    pi,
    "jj",
    [
      "log",
      "--ignore-working-copy",
      "--no-graph",
      "--color",
      "never",
      "--limit",
      "1",
      "--revisions",
      "descendants(@, 10) & bookmarks() & ~@",
      "--template",
      'change_id.shortest(4) ++ "|" ++ local_bookmarks.join(",") ++ "\\n"',
    ],
    ctx,
  );
  const below = await exec(
    pi,
    "jj",
    [
      "log",
      "--ignore-working-copy",
      "--no-graph",
      "--color",
      "never",
      "--limit",
      "1",
      "--revisions",
      "trunk()::@ & bookmarks() & ~@",
      "--template",
      'change_id.shortest(4) ++ "|" ++ local_bookmarks.join(",") ++ "\\n"',
    ],
    ctx,
  );
  const found = trim(above?.stdout)
    ? { dir: "-", line: trim(above?.stdout) }
    : { dir: "+", line: trim(below?.stdout) };
  if (!found.line) return "·";

  const [id, name] = found.line.split("|");
  const count = await exec(
    pi,
    "jj",
    [
      "log",
      "--ignore-working-copy",
      "--no-graph",
      "--color",
      "never",
      "--revisions",
      found.dir === "-" ? `@..${id}` : `${id}..@`,
      "--template",
      'change_id ++ "\\n"',
    ],
    ctx,
  );
  const distance = trim(count?.stdout).split("\n").filter(Boolean).length;
  return `${name}${found.dir}${distance}`;
};

const jjState = async (
  pi: ExtensionAPI,
  ctx: ExtensionContext,
): Promise<VcsState | undefined> => {
  const result = await exec(
    pi,
    "jj",
    [
      "log",
      "--ignore-working-copy",
      "--no-graph",
      "--color",
      "never",
      "--revisions",
      "@",
      "--template",
      'change_id.shortest(6) ++ "|" ++ description.first_line() ++ "|" ++ bookmarks.join(",") ++ "|" ++ if(empty, "∅") ++ "|" ++ if(conflict, "⚡conflict") ++ "|" ++ if(divergent, "~divergent") ++ "\\n"',
    ],
    ctx,
  );

  const line = trim(result?.stdout);
  if (!line) return undefined;

  const [id, rawDesc, rawBookmarks, empty, conflict, divergent] =
    line.split("|");
  const desc = rawDesc && rawDesc.length > 0 ? rawDesc : "(no description)";
  const bookmarks =
    rawBookmarks && rawBookmarks.length > 0
      ? rawBookmarks
      : await jjNearestBookmark(pi, ctx);
  const distance = bookmarks.match(/([+-]\d+)$/)?.[1];
  const bookmark = distance ? bookmarks.slice(0, -distance.length) : bookmarks;
  const segments = [
    text("jj ", "muted"),
    text(id, "dim"),
    text(" @ ", "muted"),
    text(bookmark, "bookmark"),
    ...(distance ? [text(distance, "distance")] : []),
    text(" — ", "muted"),
    text(desc, rawDesc && rawDesc.length > 0 ? "text" : "dim"),
  ];

  if (empty) segments.push(text(" · ", "muted"), text(empty, "success"));
  if (conflict) segments.push(text(" · ", "muted"), text(conflict, "error"));
  if (divergent)
    segments.push(text(" · ", "muted"), text(divergent, "warning"));

  return {
    kind: "jj",
    line: segments.map((segment) => segment.text).join(""),
    segments,
  };
};

const gitText = async (pi: ExtensionAPI, ctx: ExtensionContext) => {
  const branchResult = await exec(pi, "git", ["branch", "--show-current"], ctx);
  const branch = trim(branchResult?.stdout) || "detached";
  const statusResult = await exec(pi, "git", ["status", "--porcelain"], ctx);
  const dirty = trim(statusResult?.stdout).length > 0 ? "dirty" : "clean";

  const segments = [
    text("git ", "muted"),
    text(branch, "bookmark"),
    text(" · ", "muted"),
    text(dirty, dirty === "clean" ? "success" : "warning"),
  ];

  return {
    kind: "git" as const,
    line: segments.map((segment) => segment.text).join(""),
    segments,
  };
};

const readState = async (
  pi: ExtensionAPI,
  ctx: ExtensionContext,
): Promise<VcsState> => {
  if (await isJjRepo(pi, ctx)) {
    return (
      (await jjState(pi, ctx)) ?? {
        kind: "jj",
        line: "jj · unknown change",
        segments: [text("jj · unknown change", "muted")],
      }
    );
  }

  if (await isGitRepo(pi, ctx)) {
    return await gitText(pi, ctx);
  }

  return { kind: "none", line: fallback, segments: [text(fallback, "muted")] };
};

const color = (ctx: ExtensionContext, state: VcsState) => {
  const theme = ctx.ui.theme;
  const paint = (segment: Segment) => {
    if (segment.role === "bookmark") return theme.fg("warning", segment.text);
    if (segment.role === "distance")
      return theme.fg("dim", theme.fg("warning", segment.text));
    if (segment.role === "success") return theme.fg("success", segment.text);
    if (segment.role === "error") return theme.fg("error", segment.text);
    if (segment.role === "warning") return theme.fg("warning", segment.text);
    if (segment.role === "muted") return theme.fg("muted", segment.text);
    if (segment.role === "dim") return theme.fg("dim", segment.text);
    return segment.text;
  };

  return state.segments.map(paint).join("");
};

export default function vcsChangeWidget(pi: ExtensionAPI) {
  let timer: ReturnType<typeof setInterval> | undefined;
  let lastLine = "";

  const stop = () => {
    if (!timer) return;
    clearInterval(timer);
    timer = undefined;
  };

  const refresh = async (ctx: ExtensionContext) => {
    if (!ctx.hasUI) return;
    const state = await readState(pi, ctx);
    if (state.line === lastLine) return;
    lastLine = state.line;
    ctx.ui.setWidget(widgetKey, [color(ctx, state)], {
      placement: "aboveEditor",
    });
  };

  pi.on("session_start", (_event, ctx) => {
    void refresh(ctx);
    stop();
    timer = setInterval(() => void refresh(ctx), refreshMs);
  });

  pi.on("tool_execution_end", (_event, ctx) => {
    void refresh(ctx);
  });

  pi.on("session_shutdown", () => {
    stop();
  });

  pi.registerCommand("vcs-refresh", {
    description: "Refresh the VCS change widget",
    handler: async (_args, ctx) => {
      lastLine = "";
      await refresh(ctx);
    },
  });
}
