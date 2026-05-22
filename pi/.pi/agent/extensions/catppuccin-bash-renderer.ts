import type { BashToolDetails, ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { createBashTool, keyHint } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

type ThemeLike = {
	fg: (color: any, text: string) => string;
	bold: (text: string) => string;
};

const PREVIEW_LINES = 10;
const EXPANDED_LINES = 60;

function shorten(text: string, max = 140): string {
	return text.length > max ? `${text.slice(0, max - 3)}...` : text;
}

function styleInlineValue(value: string, theme: ThemeLike): string {
	const trimmed = value.trim();
	if (!trimmed) return value;
	if (/^(true|false|null)$/i.test(trimmed)) return theme.fg("syntaxNumber", value);
	if (/^-?\d+(\.\d+)?$/.test(trimmed)) return theme.fg("syntaxNumber", value);
	if ((trimmed.startsWith("[") && trimmed.endsWith("]")) || (trimmed.startsWith("{") && trimmed.endsWith("}"))) {
		return theme.fg("syntaxVariable", value);
	}
	if (trimmed.startsWith("/") || trimmed.startsWith("~/") || trimmed.includes("/")) {
		return theme.fg("mdLink", value);
	}
	return theme.fg("syntaxString", value);
}

function styleYamlishLine(line: string, theme: ThemeLike): string | undefined {
	const match = /^(\s*(?:-\s+)??)([A-Za-z0-9_.\/-]+:)(\s*)(.*)$/.exec(line);
	if (!match) return undefined;
	const [, indent, key, gap, value] = match;
	if (!value) {
		return `${theme.fg("dim", indent)}${theme.fg("syntaxKeyword", key)}`;
	}
	return `${theme.fg("dim", indent)}${theme.fg("syntaxKeyword", key)}${gap}${styleInlineValue(value, theme)}`;
}

function styleDiffishLine(line: string, theme: ThemeLike): string | undefined {
	if (line.startsWith("+++") || line.startsWith("---") || line.startsWith("@@")) {
		return theme.fg("toolDiffContext", line);
	}
	if (line.startsWith("+")) return theme.fg("toolDiffAdded", line);
	if (line.startsWith("-")) return theme.fg("toolDiffRemoved", line);
	return undefined;
}

function styleLogLine(line: string, theme: ThemeLike): string {
	if (!line.trim()) return "";

	const diffish = styleDiffishLine(line, theme);
	if (diffish) return diffish;

	const yamlish = styleYamlishLine(line, theme);
	if (yamlish) return yamlish;

	if (/^\s*(error|fatal|failed|panic|exception)\b/i.test(line) || /\b(error|fatal|failed|panic|exception)\b/i.test(line)) {
		return theme.fg("error", line);
	}
	if (/\b(warn|warning|deprecated)\b/i.test(line)) {
		return theme.fg("warning", line);
	}
	if (/^\s*(✔|✓|success|created|updated|deleted|applied|done)\b/i.test(line)) {
		return theme.fg("success", line);
	}
	if (/^\s*(>|\$)\s/.test(line)) {
		return theme.fg("accent", line);
	}
	if (/^(#|==|--\s)/.test(line)) {
		return theme.fg("mdHeading", line);
	}
	if (/^\s*(apiVersion|kind|metadata|spec|status):\b/.test(line)) {
		return styleYamlishLine(line, theme) ?? theme.fg("toolOutput", line);
	}
	if (/[~/.][A-Za-z0-9_.\/-]+/.test(line) || /\b([A-Za-z0-9_.-]+\/[A-Za-z0-9_.\/-]+)/.test(line)) {
		return theme.fg("mdLink", line);
	}
	return theme.fg("toolOutput", line);
}

function renderOutput(text: string, theme: ThemeLike, expanded: boolean): string {
	const lines = text.replace(/\r/g, "").split("\n");
	const maxLines = expanded ? EXPANDED_LINES : PREVIEW_LINES;
	const shown = lines.slice(0, maxLines);
	let rendered = shown.map((line) => styleLogLine(line, theme)).join("\n");

	if (!expanded && lines.length > PREVIEW_LINES) {
		rendered += `\n${theme.fg("muted", `... ${lines.length - PREVIEW_LINES} more lines (${keyHint("app.tools.expand", "to expand")})`)}`;
	} else if (expanded && lines.length > EXPANDED_LINES) {
		rendered += `\n${theme.fg("muted", `... ${lines.length - EXPANDED_LINES} more lines`)}`;
	}

	return rendered;
}

export default function catppuccinBashRenderer(pi: ExtensionAPI) {
	const cwd = process.cwd();
	const originalBash = createBashTool(cwd);

	pi.registerTool({
		name: "bash",
		label: "bash",
		description: originalBash.description,
		parameters: originalBash.parameters,

		async execute(toolCallId, params, signal, onUpdate) {
			return originalBash.execute(toolCallId, params, signal, onUpdate);
		},

		renderCall(args, theme, context) {
			const text = (context.lastComponent as Text | undefined) ?? new Text("", 0, 0);
			const command = String(args.command ?? "");
			const firstWord = command.trim().split(/\s+/)[0] ?? "bash";
			const preview = shorten(command.slice(firstWord.length).trim(), 110);
			let content = theme.fg("bashMode", "$ ");
			content += theme.fg("syntaxFunction", theme.bold(firstWord));
			if (preview) {
				content += " ";
				content += theme.fg("toolOutput", preview);
			}
			if (args.timeout) {
				content += theme.fg("dim", `  timeout ${args.timeout}s`);
			}
			text.setText(content);
			return text;
		},

		renderResult(result, { expanded, isPartial }, theme, context) {
			const text = (context.lastComponent as Text | undefined) ?? new Text("", 0, 0);
			const details = result.details as BashToolDetails | undefined;
			const output = result.content.find((item) => item.type === "text")?.text ?? "";
			const cleanOutput = output.trim();
			const meaningfulLines = cleanOutput ? cleanOutput.split("\n").filter((line) => line.trim()).length : 0;

			let header = "";
			if (isPartial) {
				header = theme.fg("warning", "running...");
			} else if (context.isError) {
				header = theme.fg("error", "command failed");
			} else {
				header = theme.fg("success", "command finished");
			}
			header += theme.fg("dim", `  ${meaningfulLines} lines`);

			if (details?.truncation?.truncated) {
				header += theme.fg("warning", "  [truncated]");
			}
			if (details?.fullOutputPath) {
				header += `\n${theme.fg("muted", "full output: ")}${theme.fg("mdLink", details.fullOutputPath)}`;
			}

			if (!cleanOutput) {
				text.setText(header);
				return text;
			}

			const renderedOutput = renderOutput(cleanOutput, theme, expanded);
			text.setText(`${header}\n\n${renderedOutput}`);
			return text;
		},
	});
}
