// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { useState, useCallback } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { springs, staggerContainer, staggerItem } from '@/lib/motion'
import { cn, shuffleArray } from '@/lib/utils'
import { GlassPanel } from '@/components/ui/GlassPanel'
import { ConfettiEffect } from '@/components/ui/ConfettiEffect'
import type { KoppelenQuestion } from '@/lib/content-parser'
import { Link2, Check } from 'lucide-react'

interface Props {
  question: KoppelenQuestion
}

export function KoppelenCard({ question }: Props) {
  const [selectedLeft, setSelectedLeft] = useState<number | null>(null)
  const [matches, setMatches] = useState<Map<number, number>>(new Map())
  const [wrongPair, setWrongPair] = useState<[number, number] | null>(null)

  // Shuffle right side once
  const [shuffledRight] = useState(() => {
    const indices = question.paren.map((_, i) => i)
    return shuffleArray(indices)
  })

  const allMatched = matches.size === question.paren.length
  const correctCount = Array.from(matches.entries()).filter(([l, r]) => l === r).length

  const handleLeftClick = (index: number) => {
    if (matches.has(index)) return
    setSelectedLeft(index)
    setWrongPair(null)
  }

  const handleRightClick = useCallback((shuffledIndex: number) => {
    if (selectedLeft === null) return
    const realRightIndex = shuffledRight[shuffledIndex]

    // Check if this right item is already matched
    const alreadyMatched = Array.from(matches.values()).includes(realRightIndex)
    if (alreadyMatched) return

    if (selectedLeft === realRightIndex) {
      // Correct match
      setMatches(prev => new Map([...prev, [selectedLeft, realRightIndex]]))
      setSelectedLeft(null)
    } else {
      // Wrong match - flash
      setWrongPair([selectedLeft, realRightIndex])
      setTimeout(() => {
        setWrongPair(null)
        setSelectedLeft(null)
      }, 600)
    }
  }, [selectedLeft, shuffledRight, matches])

  return (
    <GlassPanel className="p-6 space-y-5">
      <ConfettiEffect trigger={allMatched && correctCount === question.paren.length} />

      {/* Header */}
      <div className="flex items-start gap-3">
        <div className="w-8 h-8 rounded-lg bg-[rgba(139,139,245,0.1)] border border-[rgba(139,139,245,0.15)] flex items-center justify-center flex-shrink-0 mt-0.5">
          <Link2 size={16} className="text-[#8b8bf5]" />
        </div>
        <div>
          <span className="text-[10px] uppercase tracking-[0.15em] font-semibold text-[#8b8bf5] block mb-1">Koppelen</span>
          <h4 className="text-base font-semibold text-[#e8e8ea] leading-relaxed">{question.vraag}</h4>
        </div>
      </div>

      {/* Matching grid */}
      <div className="grid grid-cols-2 gap-4">
        {/* Left column - terms */}
        <motion.div variants={staggerContainer} initial="initial" animate="enter" className="space-y-2">
          {question.paren.map(([term], index) => {
            const isMatched = matches.has(index)
            const isSelected = selectedLeft === index
            const isWrong = wrongPair?.[0] === index

            return (
              <motion.button
                key={`left-${index}`}
                variants={staggerItem}
                onClick={() => handleLeftClick(index)}
                disabled={isMatched}
                className={cn(
                  'w-full p-3.5 rounded-xl border text-left text-sm font-medium transition-all duration-200 cursor-pointer',
                  'disabled:cursor-default',
                  isMatched && 'bg-[rgba(16,185,129,0.06)] border-[rgba(16,185,129,0.2)] text-[#10b981]',
                  isSelected && !isMatched && 'bg-[rgba(139,139,245,0.08)] border-[rgba(139,139,245,0.25)] text-[#e8e8ea]',
                  isWrong && 'bg-[rgba(239,68,68,0.06)] border-[rgba(239,68,68,0.2)]',
                  !isMatched && !isSelected && !isWrong && 'bg-[rgba(255,255,255,0.02)] border-[rgba(255,255,255,0.06)] text-[#e8e8ea] hover:bg-[rgba(255,255,255,0.04)]',
                )}
                animate={isWrong ? { x: [0, -4, 4, -2, 2, 0] } : {}}
                transition={{ duration: 0.3 }}
              >
                <div className="flex items-center gap-2">
                  {isMatched && <Check size={14} className="text-[#10b981] flex-shrink-0" />}
                  <span>{term}</span>
                </div>
              </motion.button>
            )
          })}
        </motion.div>

        {/* Right column - definitions (shuffled) */}
        <motion.div variants={staggerContainer} initial="initial" animate="enter" className="space-y-2">
          {shuffledRight.map((realIndex, shuffledIdx) => {
            const [, definition] = question.paren[realIndex]
            const isMatched = Array.from(matches.values()).includes(realIndex)
            const isWrong = wrongPair?.[1] === realIndex

            return (
              <motion.button
                key={`right-${shuffledIdx}`}
                variants={staggerItem}
                onClick={() => handleRightClick(shuffledIdx)}
                disabled={isMatched || selectedLeft === null}
                className={cn(
                  'w-full p-3.5 rounded-xl border text-left text-sm transition-all duration-200 cursor-pointer',
                  'disabled:cursor-default',
                  isMatched && 'bg-[rgba(16,185,129,0.06)] border-[rgba(16,185,129,0.2)] text-[#10b981]',
                  isWrong && 'bg-[rgba(239,68,68,0.06)] border-[rgba(239,68,68,0.2)]',
                  !isMatched && !isWrong && selectedLeft !== null && 'bg-[rgba(255,255,255,0.02)] border-[rgba(255,255,255,0.06)] text-[#b4b4ba] hover:bg-[rgba(255,255,255,0.04)] hover:border-[rgba(139,139,245,0.15)]',
                  !isMatched && !isWrong && selectedLeft === null && 'bg-[rgba(255,255,255,0.02)] border-[rgba(255,255,255,0.06)] text-[#b4b4ba] opacity-60',
                )}
                animate={isWrong ? { x: [0, 4, -4, 2, -2, 0] } : {}}
                transition={{ duration: 0.3 }}
              >
                <div className="flex items-center gap-2">
                  {isMatched && <Check size={14} className="text-[#10b981] flex-shrink-0" />}
                  <span>{definition}</span>
                </div>
              </motion.button>
            )
          })}
        </motion.div>
      </div>

      {/* Completion message */}
      <AnimatePresence>
        {allMatched && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            transition={springs.gentle}
            className="overflow-hidden"
          >
            <div className="p-4 rounded-xl bg-[rgba(16,185,129,0.04)] border border-[rgba(16,185,129,0.1)] text-center">
              <p className="text-sm font-semibold text-[#10b981]">
                Alles gekoppeld! 🎉
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </GlassPanel>
  )
}
