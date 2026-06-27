import { tool } from "@opencode-ai/plugin"
import fs from "node:fs/promises"
import path from "node:path"

export default tool({
  description: "Write a plan into .plans/ as Markdown or HTML. Only accepts a leaf filename.",
  args: {
    name: tool.schema.string().describe("Leaf filename, with or without .md/.html"),
    format: tool.schema.enum(["md", "html"]).describe("Output format"),
    content: tool.schema.string().describe("Plan content"),
  },

  async execute(args, context) {
    let name = args.name.trim()
    const ext = `.${args.format}`

    if (name.includes("/") || name.includes("\\") || name === "." || name === "..") {
      throw new Error("name must be a leaf filename only")
    }

    name = name.replace(/\.(md|html)$/i, "")
    name += ext

    if (!/^[a-zA-Z0-9._-]+\.(md|html)$/.test(name)) {
      throw new Error("invalid plan filename")
    }

    const root = context.worktree ?? context.directory
    const dir = path.join(root, ".plans")
    const file = path.join(dir, name)

    const resolvedDir = path.resolve(dir)
    const resolvedFile = path.resolve(file)

    if (!resolvedFile.startsWith(resolvedDir + path.sep)) {
      throw new Error("refusing to write outside .plans")
    }

    await fs.mkdir(dir, { recursive: true })
    await fs.writeFile(resolvedFile, args.content, "utf8")

    return `Wrote ${path.relative(root, resolvedFile)}`
  },
})
