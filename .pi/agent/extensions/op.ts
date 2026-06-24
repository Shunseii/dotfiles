import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { execFile } from "node:child_process";

const MAX_OUTPUT = 20_000;

// Read-only allowlist. Command must match one of these exact subcommand
// prefixes; anything else (create/edit/delete/signout/user/...) is rejected.
const ALLOWED = new Set([
  "read",
  "item get",
  "item list",
  "vault get",
  "vault list",
  "account get",
  "account list",
  "document get",
]);

const runOp = ({
  args,
  signal,
}: {
  args: string[];
  signal: AbortSignal;
}): Promise<{ stdout: string; stderr: string; code: number }> =>
  new Promise((resolve) => {
    execFile(
      "op",
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
    name: "op",
    label: "1Password",
    description:
      "Run the 1Password CLI (read-only). `command` is one of: read, item get, " +
      "item list, vault get, vault list, account get, account list, document get. " +
      "`args` are the remaining CLI args (e.g. a secret ref 'op://Vault/Item/field' " +
      "for read, or an item name/id for 'item get'). Returns secret material — only " +
      "fetch what is needed.",
    parameters: Type.Object({
      command: Type.String({
        description:
          "Read-only subcommand: read | item get | item list | vault get | " +
          "vault list | account get | account list | document get.",
      }),
      args: Type.Optional(
        Type.Array(Type.String(), {
          description: "Remaining CLI args, e.g. ['op://Vault/Item/password'].",
        }),
      ),
      account: Type.Optional(
        Type.String({ description: "Account shorthand/URL to target." }),
      ),
    }),
    async execute(_toolCallId, params, signal) {
      const command = params.command.trim().replace(/\s+/g, " ");
      if (!ALLOWED.has(command)) {
        return {
          content: [
            {
              type: "text",
              text: `[blocked] '${command}' is not a read-only command. Allowed: ${[...ALLOWED].join(", ")}.`,
            },
          ],
          details: { command, blocked: true },
          isError: true,
        };
      }

      const args = [
        ...command.split(" "),
        ...(params.args ?? []),
        ...(params.account ? ["--account", params.account] : []),
      ];

      const { stdout, stderr, code } = await runOp({ args, signal });
      const body = stdout.trim() || stderr.trim() || "(no output)";
      const prefix = code === 0 ? "" : `[exit ${code}]\n`;

      return {
        content: [{ type: "text", text: truncate(prefix + body) }],
        details: { command, exitCode: code },
        isError: code !== 0,
      };
    },
  });
}
