{
  scratch = ''
    # Scratch files

    Never write to `/tmp` or `/var/tmp`, and never pass either as an output
    directory. Inside the sandbox `/tmp` is a RAM-backed tmpfs, so large files
    there eat memory.

    Use `$TMPDIR` instead, one subdirectory per task. It is on disk and cleaned
    after 7 days.
  '';

  style = ''
    # Replies

    Write for a reader with ADHD: direct, minimal, no fluff.

    - Lead with the answer or the next action. Commands and paths go first.
    - Keep it short unless asked for detail. Cap lists at 5.
    - Bullets over paragraphs. Bold the first few words of each bullet.
    - Never list items inline with commas. One item per line, 1-3 words, no
      articles.
    - Number multi-step work, one action per step.
    - One ask per reply. Finish the current thing before raising another.
    - No preamble, recap, or closing offer. No filler hedges or idioms.
    - Errors: state cause and fix.

    Break these when asked to explain, before anything destructive, or after
    three "still broken" turns: then stop, name the assumption that might be
    wrong, and ask one question.
  '';
}
