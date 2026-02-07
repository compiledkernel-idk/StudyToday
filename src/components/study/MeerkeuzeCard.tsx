// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { springs, staggerContainer, staggerItem } from '@/lib/motion'
import { cn } from '@/lib/utils'
import { GlassPanel } from '@/components/ui/GlassPanel'
import { ConfettiEffect } from '@/components/ui/ConfettiEffect'
import type { MeerkeuzeQuestion } from '@/lib/content-parser'
import { CheckCircle2, XCircle, HelpCircle } from 'lucide-react'

interface Props {
  question: MeerkeuzeQuestion
}

export function MeerkeuzeCard({ question }: Props) {
  const [selected, setSelected] = useState<number | null>(null)
  const [revealed, setRevealed] = useState(false)

  const isCorrect = selected === question.correct
  const answered = selected !== null && revealed

  const handleSelect = (index: number) => {
    if (revealed) return
    setSelected(index)
    setTimeout(() => setRevealed(true), 200)
  }

  return (
    <GlassPanel className="p-6 space-y-5">
      <ConfettiEffect trigger={answered && isCorrect} />

      {/* Question header */}
      <div className="flex items-start gap-3">
        <div className="w-8 h-8 rounded-lg bg-[rgba(139,139,245,0.1)] border border-[rgba(139,139,245,0.15)] flex items-center justify-center flex-shrink-0 mt-0.5">
          <HelpCircle size={16} className="text-[#8b8bf5]" />
        </div>
        <div>
          <span className="text-[10px] uppercase tracking-[0.15em] font-semibold text-[#8b8bf5] block mb-1">Meerkeuze</span>
          <h4 className="text-base font-semibold text-[#e8e8ea] leading-relaxed">{question.vraag}</h4>
        </div>
      </div>

      {/* Options */}
      <motion.div
        variants={staggerContainer}
        initial="initial"
        animate="enter"
        className="space-y-2"
      >
        {question.opties.map((optie, index) => {
          const isThis = selected === index
          const isCorrectOption = index === question.correct

          let borderColor = 'border-[rgba(255,255,255,0.06)]'
          let bgColor = 'bg-[rgba(255,255,255,0.02)]'
          let iconEl = null

          if (answered) {
            if (isCorrectOption) {
              borderColor = 'border-[rgba(16,185,129,0.3)]'
              bgColor = 'bg-[rgba(16,185,129,0.06)]'
              iconEl = <CheckCircle2 size={18} className="text-[#10b981]" />
            } else if (isThis && !isCorrect) {
              borderColor = 'border-[rgba(239,68,68,0.3)]'
              bgColor = 'bg-[rgba(239,68,68,0.06)]'
              iconEl = <XCircle size={18} className="text-[#ef4444]" />
            }
          } else if (isThis) {
            borderColor = 'border-[rgba(139,139,245,0.3)]'
            bgColor = 'bg-[rgba(139,139,245,0.06)]'
          }

          return (
            <motion.button
              key={index}
              variants={staggerItem}
              onClick={() => handleSelect(index)}
              disabled={revealed}
              className={cn(
                'w-full flex items-center gap-3 p-4 rounded-xl border transition-all duration-200 cursor-pointer text-left',
                'disabled:cursor-default',
                bgColor,
                borderColor,
                !revealed && !isThis && 'hover:bg-[rgba(255,255,255,0.04)] hover:border-[rgba(255,255,255,0.1)]',
              )}
              whileHover={!revealed ? { scale: 1.01 } : {}}
              whileTap={!revealed ? { scale: 0.99 } : {}}
              animate={answered && isThis && !isCorrect ? {
                x: [0, -6, 6, -4, 4, -2, 2, 0],
                transition: { duration: 0.4 }
              } : {}}
            >
              {/* Letter indicator */}
              <div className={cn(
                'w-8 h-8 rounded-lg flex items-center justify-center text-xs font-bold flex-shrink-0',
                answered && isCorrectOption ? 'bg-[rgba(16,185,129,0.15)] text-[#10b981]' :
                answered && isThis && !isCorrect ? 'bg-[rgba(239,68,68,0.15)] text-[#ef4444]' :
                isThis ? 'bg-[rgba(139,139,245,0.15)] text-[#8b8bf5]' :
                'bg-[rgba(255,255,255,0.04)] text-[#6e6e76]'
              )}>
                {String.fromCharCode(65 + index)}
              </div>

              <span className={cn(
                'flex-1 text-sm font-medium',
                answered && isCorrectOption ? 'text-[#10b981]' :
                answered && isThis && !isCorrect ? 'text-[#ef4444]' :
                'text-[#e8e8ea]'
              )}>
                {optie}
              </span>

              {iconEl && <span className="flex-shrink-0">{iconEl}</span>}
            </motion.button>
          )
        })}
      </motion.div>

      {/* Explanation */}
      <AnimatePresence>
        {answered && question.uitleg && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
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
