// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { springs } from '@/lib/motion'
import { cn, fuzzyMatch } from '@/lib/utils'
import { GlassPanel } from '@/components/ui/GlassPanel'
import { GlassButton } from '@/components/ui/GlassButton'
import { ConfettiEffect } from '@/components/ui/ConfettiEffect'
import type { InvullenQuestion } from '@/lib/content-parser'
import { PenLine, Lightbulb, Check, X } from 'lucide-react'

interface Props {
  question: InvullenQuestion
}

export function InvullenCard({ question }: Props) {
  const [answer, setAnswer] = useState('')
  const [revealed, setRevealed] = useState(false)
  const [showHint, setShowHint] = useState(false)

  const isCorrect = fuzzyMatch(answer, question.antwoord)

  const handleSubmit = () => {
    if (!answer.trim()) return
    setRevealed(true)
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') handleSubmit()
  }

  return (
    <GlassPanel className="p-6 space-y-5">
      <ConfettiEffect trigger={revealed && isCorrect} />

      {/* Header */}
      <div className="flex items-start gap-3">
        <div className="w-8 h-8 rounded-lg bg-[rgba(139,139,245,0.1)] border border-[rgba(139,139,245,0.15)] flex items-center justify-center flex-shrink-0 mt-0.5">
          <PenLine size={16} className="text-[#8b8bf5]" />
        </div>
        <div>
          <span className="text-[10px] uppercase tracking-[0.15em] font-semibold text-[#8b8bf5] block mb-1">Invullen</span>
          <h4 className="text-base font-semibold text-[#e8e8ea] leading-relaxed">{question.vraag}</h4>
        </div>
      </div>

      {/* Input */}
      <motion.div
        className="flex gap-3"
        animate={revealed && !isCorrect ? {
          x: [0, -6, 6, -4, 4, -2, 2, 0],
          transition: { duration: 0.4 }
        } : {}}
      >
        <div className={cn(
          'flex-1 flex items-center gap-3 h-12 px-4 rounded-xl border transition-all duration-200',
          'bg-[rgba(255,255,255,0.03)] backdrop-blur-xl',
          revealed && isCorrect && 'border-[rgba(16,185,129,0.3)] bg-[rgba(16,185,129,0.04)]',
          revealed && !isCorrect && 'border-[rgba(239,68,68,0.3)] bg-[rgba(239,68,68,0.04)]',
          !revealed && 'border-[rgba(255,255,255,0.06)] focus-within:border-[rgba(139,139,245,0.3)]',
        )}>
          <input
            value={answer}
            onChange={e => setAnswer(e.target.value)}
            onKeyDown={handleKeyDown}
            disabled={revealed}
            placeholder="Typ je antwoord..."
            className="flex-1 bg-transparent outline-none text-[#e8e8ea] placeholder-[#4a4a52] text-sm font-medium disabled:opacity-60"
          />
          {revealed && (
            isCorrect
              ? <Check size={18} className="text-[#10b981]" />
              : <X size={18} className="text-[#ef4444]" />
          )}
        </div>

        {!revealed && (
          <GlassButton onClick={handleSubmit} variant="accent" disabled={!answer.trim()}>
            Controleer
          </GlassButton>
        )}
      </motion.div>

      {/* Hint */}
      {question.hint && !revealed && (
        <AnimatePresence>
          {showHint ? (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              className="overflow-hidden"
            >
              <div className="flex items-center gap-2 p-3 rounded-xl bg-[rgba(245,158,11,0.04)] border border-[rgba(245,158,11,0.1)]">
                <Lightbulb size={14} className="text-[#f59e0b] flex-shrink-0" />
                <p className="text-xs text-[#f59e0b]">{question.hint}</p>
              </div>
            </motion.div>
          ) : (
            <motion.button
              onClick={() => setShowHint(true)}
              className="flex items-center gap-1.5 text-xs text-[#6e6e76] hover:text-[#f59e0b] transition-colors cursor-pointer"
              whileHover={{ x: 2 }}
            >
              <Lightbulb size={12} /> Toon hint
            </motion.button>
          )}
        </AnimatePresence>
      )}

      {/* Correct answer reveal on wrong */}
      <AnimatePresence>
        {revealed && !isCorrect && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            transition={springs.gentle}
            className="overflow-hidden"
          >
            <div className="p-4 rounded-xl bg-[rgba(16,185,129,0.04)] border border-[rgba(16,185,129,0.1)]">
              <p className="text-sm text-[#b4b4ba]">
                <span className="font-semibold text-[#10b981]">Juiste antwoord: </span>
                {question.antwoord}
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </GlassPanel>
  )
}
