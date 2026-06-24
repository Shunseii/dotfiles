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
    description:
      "Run the Obsidian CLI. `command` is the subcommand, `args` are `key=value` strings. " +
      "For subcommand syntax see the `obsidian` skill or run `command=help`.",
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
