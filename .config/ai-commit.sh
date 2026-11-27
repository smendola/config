generate_ai_commit_comment() {
  opencode run --archived --model openai/gpt-6.1-terra "$(cat)"
}
