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

const trim = (value: string | undefined) => value?.trim() ?? "";

const exec = async (
  pi: ExtensionAPI,
  cmd: string,
  args: string[],
  ctx: ExtensionContext,
): Promise<ExecResult | undefined> =>
  pi
    .exec(cmd, args, { cwd: ctx.cwd, timeout: 3_000 })
    .catch(() => undefined) as Promise<ExecResult | undefined>;

const isJjRepo = async (pi: ExtensionAPI, ctx: ExtensionContext) => {
  const result = await exec(pi, "jj", ["root", "--quiet"], ctx);
  return result?.code === 0;
};

const jj = async (pi: ExtensionAPI, ctx: ExtensionContext, args: string[]) => {
  const result = await exec(
    pi,
    "jj",
    ["--ignore-working-copy", "--color", "never", ...args],
    ctx,
  );

  return result?.code === 0 ? trim(result.stdout) : "";
};

const currentChange = async (pi: ExtensionAPI, ctx: ExtensionContext) =>
  jj(pi, ctx, [
    "log",
    "--no-graph",
    "--revisions",
    "@",
    "--template",
    '"change: " ++ change_id.shortest(8) ++ "\n" ++ "commit: " ++ commit_id.shortest(12) ++ "\n" ++ "description: " ++ if(description, description.first_line(), "(no description set)") ++ "\n" ++ "bookmarks: " ++ if(bookmarks, bookmarks.join(", "), "-") ++ "\n" ++ "empty: " ++ if(empty, "yes", "no") ++ "\n" ++ "conflict: " ++ if(conflict, "yes", "no") ++ "\n"',
  ]);

const stackChanges = async (pi: ExtensionAPI, ctx: ExtensionContext) =>
  jj(pi, ctx, [
    "log",
    "--revisions",
    "latest(::@ & immutable(), 1)..@ | latest(::@ & immutable(), 1)",
    "--template",
    'change_id.shortest(8) ++ " " ++ if(current_working_copy, "@ ", "  ") ++ if(description, description.first_line(), "(no description set)") ++ if(bookmarks, " [" ++ bookmarks.join(", ") ++ "]", "") ++ "\n"',
  ]);

const bookmarks = async (pi: ExtensionAPI, ctx: ExtensionContext) =>
  jj(pi, ctx, [
    "bookmark",
    "list",
  ]);

const status = async (pi: ExtensionAPI, ctx: ExtensionContext) => {
  const result = await exec(pi, "jj", ["status", "--color", "never"], ctx);
  return result?.code === 0 ? trim(result.stdout) : "";
};

const section = (title: string, body: string) =>
  body ? `## ${title}\n\n${body}` : "";

const buildContext = async (pi: ExtensionAPI, ctx: ExtensionContext) => {
  if (!(await isJjRepo(pi, ctx))) return "";

  const [current, stack, mark, stat] = await Promise.all([
    currentChange(pi, ctx),
    stackChanges(pi, ctx),
    bookmarks(pi, ctx),
    status(pi, ctx),
  ]);

  return [
    "# JJ repository context",
    "This context is automatically injected before each agent run. Use it to avoid editing the wrong jj change.",
    section("Active change", current),
    section("Stack", stack),
    section("Status", stat || "The working copy appears clean/empty."),
    section("Bookmarks", mark),
    "## Agent guidance\n\n- Treat the active jj change as the edit target unless the user explicitly says otherwise.\n- If the active change does not match the requested slice, stop and ask before editing.\n- Do not run interactive jj commands; use `-m` for commands like `jj new`, `jj describe`, and `jj squash`.",
  ]
    .filter(Boolean)
    .join("\n\n");
};

export default function jjContext(pi: ExtensionAPI) {
  pi.on("before_agent_start", async (_event, ctx) => {
    const content = await buildContext(pi, ctx);
    if (!content) return;

    return {
      message: {
        customType: "jj-context",
        content,
        display: false,
      },
    };
  });

  pi.registerCommand("jj-context", {
    description: "Show the jj context that is injected into agent runs",
    handler: async (_args, ctx) => {
      const content = await buildContext(pi, ctx);
      ctx.ui.notify(content || "No jj repository detected.", "info");
    },
  });
}
