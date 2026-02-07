// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

export interface MeerkeuzeQuestion {
  type: 'meerkeuze'
  vraag: string
  opties: string[]
  correct: number
  uitleg?: string
}

export interface InvullenQuestion {
  type: 'invullen'
  vraag: string
  antwoord: string
  hint?: string
}

export interface AfbeeldingQuestion {
  type: 'afbeelding'
  vraag: string
  bron: string
  gebieden: { label: string; x: number; y: number }[]
}

export interface KoppelenQuestion {
  type: 'koppelen'
  vraag: string
  paren: [string, string][]
}

export interface WaarOfNietQuestion {
  type: 'waar-of-niet'
  vraag: string
  antwoord: boolean
  uitleg?: string
}

export interface OpenQuestion {
  type: 'open'
  vraag: string
  kernwoorden: string[]
}

export type Question =
  | MeerkeuzeQuestion
  | InvullenQuestion
  | AfbeeldingQuestion
  | KoppelenQuestion
  | WaarOfNietQuestion
  | OpenQuestion

export interface ParsedContent {
  markdown: string
  questions: Question[]
}

export function parseContent(raw: string): ParsedContent {
  const questions: Question[] = []
  const blockRegex = /:::(meerkeuze|invullen|afbeelding|koppelen|waar-of-niet|open)\n([\s\S]*?):::/g

  let markdown = raw
  let match: RegExpExecArray | null

  while ((match = blockRegex.exec(raw)) !== null) {
    const type = match[1]
    const body = match[2].trim()

    try {
      const question = parseQuestionBlock(type, body)
      if (question) questions.push(question)
    } catch {
      // Skip malformed blocks
    }

    markdown = markdown.replace(match[0], `<!-- question-${questions.length - 1} -->`)
  }

  return { markdown, questions }
}

function parseQuestionBlock(type: string, body: string): Question | null {
  const lines = body.split('\n')
  const props: Record<string, string> = {}
  let currentKey = ''
  const listItems: string[] = []
  let inList = false

  for (const line of lines) {
    const keyMatch = line.match(/^(\w+):\s*(.*)$/)
    if (keyMatch && !inList) {
      currentKey = keyMatch[1]
      props[currentKey] = keyMatch[2]
      inList = false
    } else if (line.trim().startsWith('- ')) {
      inList = true
      listItems.push(line.trim().slice(2))
    } else if (line.trim().startsWith('[') && inList) {
      listItems.push(line.trim())
    }
  }

  switch (type) {
    case 'meerkeuze': {
      const opties = listItems.map(o => o.replace('*', ''))
      const correct = listItems.findIndex(o => o.endsWith('*'))
      return {
        type: 'meerkeuze',
        vraag: props.vraag || '',
        opties,
        correct: correct >= 0 ? correct : 0,
        uitleg: props.uitleg,
      }
    }
    case 'invullen':
      return {
        type: 'invullen',
        vraag: props.vraag || '',
        antwoord: props.antwoord || '',
        hint: props.hint,
      }
    case 'afbeelding': {
      const gebieden: { label: string; x: number; y: number }[] = []
      let currentGebied: Partial<{ label: string; x: number; y: number }> = {}
      for (const line of lines) {
        const labelMatch = line.match(/label:\s*(.+)/)
        const xMatch = line.match(/x:\s*(\d+)/)
        const yMatch = line.match(/y:\s*(\d+)/)
        if (labelMatch) currentGebied.label = labelMatch[1]
        if (xMatch) currentGebied.x = parseInt(xMatch[1])
        if (yMatch) {
          currentGebied.y = parseInt(yMatch[1])
          if (currentGebied.label !== undefined && currentGebied.x !== undefined) {
            gebieden.push(currentGebied as { label: string; x: number; y: number })
            currentGebied = {}
          }
        }
      }
      return {
        type: 'afbeelding',
        vraag: props.vraag || '',
        bron: props.bron || '',
        gebieden,
      }
    }
    case 'koppelen': {
      const paren: [string, string][] = listItems
        .map(item => {
          const m = item.match(/\[(.+?),\s*(.+?)\]/)
          return m ? [m[1].trim(), m[2].trim()] as [string, string] : null
        })
        .filter((p): p is [string, string] => p !== null)
      return {
        type: 'koppelen',
        vraag: props.vraag || '',
        paren,
      }
    }
    case 'waar-of-niet':
      return {
        type: 'waar-of-niet',
        vraag: props.vraag || '',
        antwoord: (props.antwoord || '').toLowerCase() === 'waar',
        uitleg: props.uitleg,
      }
    case 'open': {
      const kernMatch = props.kernwoorden?.match(/\[(.+)\]/)
      const kernwoorden = kernMatch ? kernMatch[1].split(',').map(k => k.trim()) : []
      return {
        type: 'open',
        vraag: props.vraag || '',
        kernwoorden,
      }
    }
    default:
      return null
  }
}
