// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { springs } from '@/lib/motion'
import { cn } from '@/lib/utils'
import { GlassPanel } from '@/components/ui/GlassPanel'
import { ConfettiEffect } from '@/components/ui/ConfettiEffect'
import type { WaarOfNietQuestion } from '@/lib/content-parser'
import { Scale, Check, X } from 'lucide-react'

interface Props {
  question: WaarOfNietQuestion
}

export function WaarOfNietCard({ question }: Props) {
  const [answer, setAnswer] = useState<boolean | null>(null)
  const [revealed, setRevealed] = useState(false)

  const isCorrect = answer === question.antwoord
  const answered = answer !== null && revealed

  const handleAnswer = (value: boolean) => {
    if (revealed) return
    setAnswer(value)
    setTimeout(() => setRevealed(true), 150)
  }

  return (
    <GlassPanel className="p-6 space-y-5">
      <ConfettiEffect trigger={answered && isCorrect} />

      {/* Header */}
      <div className="flex items-start gap-3">
        <div className="w-8 h-8 rounded-lg bg-[rgba(139,139,245,0.1)] border border-[rgba(139,139,245,0.15)] flex items-center justify-center flex-shrink-0 mt-0.5">
          <Scale size={16} className="text-[#8b8bf5]" />
        </div>
        <div>
          <span className="text-[10px] uppercase tracking-[0.15em] font-semibold text-[#8b8bf5] block mb-1">Waar of niet waar</span>
          <h4 className="text-base font-semibold text-[#e8e8ea] leading-relaxed">{question.vraag}</h4>
        </div>
      </div>

      {/* Buttons */}
      <div className="grid grid-cols-2 gap-3">
        {[
          { value: true, label: 'Waar', icon: Check, color: '#10b981' },
          { value: false, label: 'Niet waar', icon: X, color: '#ef4444' },
        ].map(({ value, label, icon: Icon, color }) => {
          const isSelected = answer === value
          const isCorrectAnswer = question.antwoord === value

          let borderColor = 'border-[rgba(255,255,255,0.06)]'
          let bgColor = 'bg-[rgba(255,255,255,0.02)]'

          if (answered) {
            if (isCorrectAnswer) {
              borderColor = `border-[rgba(16,185,129,0.3)]`
              bgColor = `bg-[rgba(16,185,129,0.06)]`
            } else if (isSelected) {
              borderColor = `border-[rgba(239,68,68,0.3)]`
              bgColor = `bg-[rgba(239,68,68,0.06)]`
            }
          } else if (isSelected) {
            borderColor = `border-[${color}40]`
            bgColor = `bg-[${color}10]`
          }

          return (
            <motion.button
              key={label}
              onClick={() => handleAnswer(value)}
              disabled={revealed}
              className={cn(
                'flex items-center justify-center gap-2 p-4 rounded-xl border transition-all duration-200 cursor-pointer',
                'disabled:cursor-default',
                bgColor,
                borderColor,
                !revealed && 'hover:bg-[rgba(255,255,255,0.04)]',
              )}
              whileHover={!revealed ? { scale: 1.02 } : {}}
              whileTap={!revealed ? { scale: 0.98 } : {}}
              animate={answered && isSelected && !isCorrect ? {
                x: [0, -4, 4, -3, 3, 0],
                transition: { duration: 0.3 }
              } : {}}
            >
              <Icon size={18} style={{ color: answered && isCorrectAnswer ? '#10b981' : answered && isSelected ? '#ef4444' : '#6e6e76' }} />
              <span className={cn(
                'text-sm font-semibold',
                answered && isCorrectAnswer ? 'text-[#10b981]' :
                answered && isSelected ? 'text-[#ef4444]' :
                'text-[#e8e8ea]'
              )}>
                {label}
              </span>
            </motion.button>
          )
        })}
      </div>

      {/* Explanation */}
      <AnimatePresence>
        {answered && question.uitleg && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            transition={springs.gentle}
            className="overflow-hidden"
          >
            <div className={cn(
              'p-4 rounded-xl border',
              isCorrect
                ? 'bg-[rgba(16,185,129,0.04)] border-[rgba(16,185,129,0.1)]'
                : 'bg-[rgba(239,68,68,0.04)] border-[rgba(239,68,68,0.1)]'
            )}>
              <p className="text-sm text-[#b4b4ba] leading-relaxed">
                <span className="font-semibold text-[#e8e8ea]">Uitleg: </span>
                {question.uitleg}
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </GlassPanel>
  )
}
