// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { springs } from '@/lib/motion'
import { cn } from '@/lib/utils'
import { GlassPanel } from '@/components/ui/GlassPanel'
import { GlassButton } from '@/components/ui/GlassButton'
import type { OpenQuestion } from '@/lib/content-parser'
import { MessageSquare, Check, Star } from 'lucide-react'

interface Props {
  question: OpenQuestion
}

export function OpenCard({ question }: Props) {
  const [answer, setAnswer] = useState('')
  const [revealed, setRevealed] = useState(false)
  const [selfScore, setSelfScore] = useState<number | null>(null)

  const matchedKeywords = question.kernwoorden.filter(k =>
    answer.toLowerCase().includes(k.toLowerCase())
  )
  const keywordScore = Math.round((matchedKeywords.length / question.kernwoorden.length) * 100)

  const handleSubmit = () => {
    if (!answer.trim()) return
    setRevealed(true)
  }

  return (
    <GlassPanel className="p-6 space-y-5">
      {/* Header */}
      <div className="flex items-start gap-3">
        <div className="w-8 h-8 rounded-lg bg-[rgba(139,139,245,0.1)] border border-[rgba(139,139,245,0.15)] flex items-center justify-center flex-shrink-0 mt-0.5">
          <MessageSquare size={16} className="text-[#8b8bf5]" />
        </div>
        <div>
          <span className="text-[10px] uppercase tracking-[0.15em] font-semibold text-[#8b8bf5] block mb-1">Open vraag</span>
          <h4 className="text-base font-semibold text-[#e8e8ea] leading-relaxed">{question.vraag}</h4>
        </div>
      </div>

      {/* Text area */}
      <textarea
        value={answer}
        onChange={e => setAnswer(e.target.value)}
        disabled={revealed}
        placeholder="Schrijf je antwoord hier..."
        className={cn(
          'w-full h-28 p-4 rounded-xl border text-sm text-[#e8e8ea] placeholder-[#4a4a52]',
          'bg-[rgba(255,255,255,0.02)] backdrop-blur-xl resize-none outline-none',
          'focus:border-[rgba(139,139,245,0.3)] transition-all duration-200',
          'disabled:opacity-60',
          !revealed ? 'border-[rgba(255,255,255,0.06)]' : 'border-[rgba(139,139,245,0.15)]',
        )}
      />

      {!revealed && (
        <GlassButton onClick={handleSubmit} variant="accent" disabled={!answer.trim()}>
          Controleer
        </GlassButton>
      )}

      {/* Feedback */}
      <AnimatePresence>
        {revealed && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            transition={springs.gentle}
            className="overflow-hidden space-y-4"
          >
            {/* Keyword matches */}
            <div className="p-4 rounded-xl bg-[rgba(255,255,255,0.02)] border border-[rgba(255,255,255,0.06)]">
              <p className="text-xs uppercase tracking-wider text-[#6e6e76] font-medium mb-3">
                Kernwoorden ({matchedKeywords.length}/{question.kernwoorden.length})
              </p>
              <div className="flex flex-wrap gap-2">
                {question.kernwoorden.map(keyword => {
                  const matched = matchedKeywords.includes(keyword)
                  return (
                    <span
                      key={keyword}
                      className={cn(
                        'px-2.5 py-1 rounded-lg text-xs font-medium border',
                        matched
                          ? 'bg-[rgba(16,185,129,0.08)] border-[rgba(16,185,129,0.2)] text-[#10b981]'
                          : 'bg-[rgba(255,255,255,0.02)] border-[rgba(255,255,255,0.06)] text-[#6e6e76]'
                      )}
                    >
                      {matched && <Check size={10} className="inline mr-1" />}
                      {keyword}
                    </span>
                  )
                })}
              </div>
            </div>

            {/* Self-grade */}
            <div className="p-4 rounded-xl bg-[rgba(255,255,255,0.02)] border border-[rgba(255,255,255,0.06)]">
              <p className="text-xs uppercase tracking-wider text-[#6e6e76] font-medium mb-3">
                Hoe goed was je antwoord?
              </p>
              <div className="flex gap-2">
                {[1, 2, 3, 4, 5].map(score => (
                  <motion.button
                    key={score}
                    onClick={() => setSelfScore(score)}
                    className={cn(
                      'w-10 h-10 rounded-xl border flex items-center justify-center cursor-pointer transition-all',
                      selfScore === score
                        ? 'bg-[rgba(139,139,245,0.15)] border-[rgba(139,139,245,0.3)]'
                        : 'bg-[rgba(255,255,255,0.02)] border-[rgba(255,255,255,0.06)] hover:bg-[rgba(255,255,255,0.04)]'
                    )}
                    whileHover={{ scale: 1.1 }}
                    whileTap={{ scale: 0.95 }}
                  >
                    <Star
                      size={16}
                      className={selfScore !== null && score <= selfScore ? 'text-[#f59e0b]' : 'text-[#4a4a52]'}
                      fill={selfScore !== null && score <= selfScore ? '#f59e0b' : 'none'}
                    />
                  </motion.button>
                ))}
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </GlassPanel>
  )
}
