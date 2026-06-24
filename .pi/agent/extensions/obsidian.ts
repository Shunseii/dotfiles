import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { execFile } from "node:child_process";

const MAX_OUTPUT = 30_000;

const runObsidian = ({
  args,
  signal,
}: {
  args: string[];
  signal: AbortSignal;
}): Promise<{ stdout: string; stderr: string; code: number }> =>
  new Promise((resolve) => {
    execFile(
      "obsidian",
      args,
      { signal, maxBuffer: 10 * 1024 * 1024 },
      (error, stdout, stderr) => {
        const code =
          error && typeof (error as { code?: number }).code === "number"
            ? (error as { code: number }).code
            : error
              ? 1
              : 0;
        resolve({ stdout, stderr, code });
      },
    );
  });

const truncate = (text: string): string =>
  text.length > MAX_OUTPUT
    ? `${text.slice(0, MAX_OUTPUT)}\n…[truncated ${text.length - MAX_OUTPUT} chars]`
    : text;

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "obsidian",
    label: "Obsidian",
    description: [
      "Interact with the Obsidian vault via the `obsidian` CLI.",
      "Pass the subcommand in `command` and its parameters in `args` as `key=value` strings (or bare flags).",
      "Conventions: `file=<name>` resolves by name like a wikilink; `path=<folder/note.md>` is exact.",
      "Quote values with spaces, e.g. `name=My Note`. Use \\n for newline in `content`.",
      "",
      "Common commands:",
      "  read file=Note            — read a note's contents",
      "  search query=term         — full-text search the vault",
      "  search:context query=term — search with matching line context",
      "  create path=folder/x.md content=...  — create a note",
      "  append file=Note content=...         — append to a note",
      "  prepend file=Note content=...        — prepend to a note",
      "  files / folders / tags / properties  — list vault structure",
      "  links file=Note / backlinks file=Note — link graph",
      "  daily:read / daily:append content=... — daily note",
      "  tasks / task                          — tasks",
      "Run `command=help` to list every subcommand.",
    ].join("\n"),
    parameters: Type.Object({
      command: Type.String({
        description: "The obsidian subcommand, e.g. 'read', 'search', 'create'.",
      }),
      args: Type.Optional(
        Type.Array(Type.String(), {
          description: "Arguments as 'key=value' strings or bare flags.",
        }),
      ),
      vault: Type.Optional(
        Type.String({ description: "Target a specific vault by name." }),
      ),
    }),
    async execute(_toolCallId, params, signal) {
      const args = [params.command, ...(params.args ?? [])];
      if (params.vault) args.push(`vault=${params.vault}`);

      const { stdout, stderr, code } = await runObsidian({ args, signal });
      const body = stdout.trim() || stderr.trim() || "(no output)";
      const prefix = code === 0 ? "" : `[exit ${code}]\n`;

      return {
        content: [{ type: "text", text: truncate(prefix + body) }],
        details: { command: params.command, exitCode: code },
        isError: code !== 0,
      };
    },
  });
}
