<!-- context7 -->
Use Context7 MCP to fetch current documentation whenever the user asks about a library, framework, SDK, API, CLI tool, or cloud service -- even well-known ones like React, Next.js, Prisma, Express, Tailwind, Django, or Spring Boot. This includes API syntax, configuration, version migration, library-specific debugging, setup instructions, and CLI tool usage. Use even when you think you know the answer -- your training data may not reflect recent changes. Prefer this over web search for library docs.

Do not use for: refactoring, writing scripts from scratch, debugging business logic, code review, or general programming concepts.

## Steps

1. Always start with `resolve-library-id` using the library name and the user's question, unless the user provides an exact library ID in `/org/project` format
2. Pick the best match (ID format: `/org/project`) by: exact name match, description relevance, code snippet count, source reputation (High/Medium preferred), and benchmark score (higher is better). If results don't look right, try alternate names or queries (e.g., "next.js" not "nextjs", or rephrase the question). Use version-specific IDs when the user mentions a version
3. `query-docs` with the selected library ID and the user's full question (not single words)
4. Answer using the fetched docs
<!-- context7 -->

## Self-attribution

When you create a new file, or make significant edits to a file, add a comment at top to identify
the agent session that worked on the file.

use format:
`OC:${HOST}:${USER}:${OPENCODE_SESSION_ID}` followed by `Created` or `Edited`

e.g.

```
/* Agent sessions:
   OC:cuda-linux:sal:ses_e288709b5ffe1RkD4obCbdzsTP Created
   OC:x13-cachy:dev:ses_e0000000000000000000900009 Edited
*/
```

If the file format does not support user-visible comments, but does support user-visible metadata,
use metadata insetead.

If the file format does not support comments or metadata, alert the user that the above instruction is not
going to be followed.
