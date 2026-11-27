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

When you undertake a substantial coding or configuration effort, that spans many user turns (say > 10) to accomplish the thing
you will want to record that you worked on those changes, somewhere.

### With associated Asana task
When you are working on an Asana task (provided by user), add session-identifying info to the Asana task description
If there is no know Asana task, first ask the user if there is an Asana task that has not yet been revealed.

Add an H1 named "AI Session(s)" to the description of the asana task (unless a similarly, not necessarily identical, heading is already present).
Under that, append a line like this:

`OC:${HOST}:${USER}:${OPENCODE_SESSION_ID}`


### Without associated Asana task:
If there is no Asana task, annotate changed files instead, as follows.

If there are multiple files involved, create or append a file at the root of the project like this:

{PROJ_ROOT}/AI_SESSIONS.txt

Into this file append a line like this:
`OC:${HOST}:${USER}:${OPENCODE_SESSION_ID}` followed by a TERSE summary of the work
Git add/commit the file along with others pertaining to the work, if asked to commit.

When you create a new file, or make **substantial** edits to a file (not trivial changes), add a comment at top to identify
the agent session that worked on the file.  If many files are involved, 

When working outside the context of a GIT project

- If the file supprorts comments (that are user-visible) add a comment like the above inside each edited file
- If the file does not support comments, but has metadata capability, attach that info as metadata
- If the file format does not support comments or metadata, alert the user that the above instruction is not
  going to be followed.
