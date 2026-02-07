# SPDX-FileCopyrightText: 2026 compiledkernel-idk
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""
content_parser.py - Parse markdown content with embedded question blocks.

Supported block types:
  :::meerkeuze   (multiple choice)
  :::invullen    (fill in the blank)
  :::waar-of-niet (true or false)
  :::koppelen    (matching)
  :::open        (open-ended)

Each block is replaced with an HTML comment placeholder <!-- question-N -->
in the returned markdown, and the parsed question objects are returned
separately.
"""

from __future__ import annotations

import re
from typing import Any


_BLOCK_RE = re.compile(
    r"^:::(meerkeuze|invullen|waar-of-niet|koppelen|open)\s*\n"
    r"(.*?)"
    r"^:::\s*$",
    re.MULTILINE | re.DOTALL,
)


def _parse_meerkeuze(body: str, qid: int) -> dict[str, Any]:
    """Parse a multiple-choice question block."""
    question: dict[str, Any] = {"type": "meerkeuze", "id": qid}
    vraag = ""
    opties: list[str] = []
    correct = 0
    uitleg = ""

    for line in body.strip().splitlines():
        line = line.strip()
        lower = line.lower()
        if lower.startswith("vraag:"):
            vraag = line.split(":", 1)[1].strip()
        elif lower.startswith("opties:"):
            opts_str = line.split(":", 1)[1].strip()
            # Split on A) B) C) D) etc.
            parts = re.split(r"[A-Z]\)\s*", opts_str)
            opties = [p.strip() for p in parts if p.strip()]
        elif lower.startswith("correct:"):
            try:
                correct = int(line.split(":", 1)[1].strip())
            except ValueError:
                correct = 0
        elif lower.startswith("uitleg:"):
            uitleg = line.split(":", 1)[1].strip()

    question["vraag"] = vraag
    question["opties"] = opties
    question["correct"] = correct
    question["uitleg"] = uitleg
    return question


def _parse_invullen(body: str, qid: int) -> dict[str, Any]:
    """Parse a fill-in-the-blank question block."""
    question: dict[str, Any] = {"type": "invullen", "id": qid}
    vraag = ""
    antwoord = ""
    hint = ""

    for line in body.strip().splitlines():
        line = line.strip()
        lower = line.lower()
        if lower.startswith("vraag:"):
            vraag = line.split(":", 1)[1].strip()
        elif lower.startswith("antwoord:"):
            antwoord = line.split(":", 1)[1].strip()
        elif lower.startswith("hint:"):
            hint = line.split(":", 1)[1].strip()

    question["vraag"] = vraag
    question["antwoord"] = antwoord
    question["hint"] = hint
    return question


def _parse_waar_of_niet(body: str, qid: int) -> dict[str, Any]:
    """Parse a true-or-false question block."""
    question: dict[str, Any] = {"type": "waar-of-niet", "id": qid}
    vraag = ""
    antwoord = ""
    uitleg = ""

    for line in body.strip().splitlines():
        line = line.strip()
        lower = line.lower()
        if lower.startswith("vraag:"):
            vraag = line.split(":", 1)[1].strip()
        elif lower.startswith("antwoord:"):
            antwoord = line.split(":", 1)[1].strip().lower()
        elif lower.startswith("uitleg:"):
            uitleg = line.split(":", 1)[1].strip()

    question["vraag"] = vraag
    question["antwoord"] = antwoord
    question["uitleg"] = uitleg
    return question


def _parse_koppelen(body: str, qid: int) -> dict[str, Any]:
    """Parse a matching question block."""
    question: dict[str, Any] = {"type": "koppelen", "id": qid}
    vraag = ""
    paren: list[dict[str, str]] = []

    for line in body.strip().splitlines():
        line = line.strip()
        lower = line.lower()
        if lower.startswith("vraag:"):
            vraag = line.split(":", 1)[1].strip()
        elif lower.startswith("paren:"):
            pairs_str = line.split(":", 1)[1].strip()
            for pair in pairs_str.split(","):
                if "=" in pair:
                    term, definition = pair.split("=", 1)
                    paren.append({
                        "term": term.strip(),
                        "definitie": definition.strip(),
                    })

    question["vraag"] = vraag
    question["paren"] = paren
    return question


def _parse_open(body: str, qid: int) -> dict[str, Any]:
    """Parse an open-ended question block."""
    question: dict[str, Any] = {"type": "open", "id": qid}
    vraag = ""
    kernwoorden: list[str] = []

    for line in body.strip().splitlines():
        line = line.strip()
        lower = line.lower()
        if lower.startswith("vraag:"):
            vraag = line.split(":", 1)[1].strip()
        elif lower.startswith("kernwoorden:"):
            kw_str = line.split(":", 1)[1].strip()
            kernwoorden = [w.strip() for w in kw_str.split(",") if w.strip()]

    question["vraag"] = vraag
    question["kernwoorden"] = kernwoorden
    return question


_PARSERS = {
    "meerkeuze": _parse_meerkeuze,
    "invullen": _parse_invullen,
    "waar-of-niet": _parse_waar_of_niet,
    "koppelen": _parse_koppelen,
    "open": _parse_open,
}


def parse_content(markdown_str: str) -> dict[str, Any]:
    """Parse markdown content and extract embedded question blocks.

    Returns a dict with two keys:
      - ``markdown``: the markdown string with question blocks replaced by
        ``<!-- question-N -->`` placeholder comments.
      - ``questions``: a list of parsed question dicts, each containing at
        minimum ``type`` and ``id`` fields plus type-specific data.
    """
    questions: list[dict[str, Any]] = []
    question_index = 0

    def _replace(match: re.Match) -> str:
        nonlocal question_index
        block_type = match.group(1)
        body = match.group(2)
        parser = _PARSERS.get(block_type)
        if parser:
            question = parser(body, question_index)
            questions.append(question)
            placeholder = f"<!-- question-{question_index} -->"
            question_index += 1
            return placeholder
        return match.group(0)

    cleaned_markdown = _BLOCK_RE.sub(_replace, markdown_str)

    return {
        "markdown": cleaned_markdown.strip(),
        "questions": questions,
    }
