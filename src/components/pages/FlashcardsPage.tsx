// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { useState, useMemo, useCallback } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { springs } from '@/lib/motion'
import { useApp } from '@/lib/store'
import { parseContent } from '@/lib/content-parser'
import { GlassPanel } from '@/components/ui/GlassPanel'
import { GlassButton } from '@/components/ui/GlassButton'
import { shuffleArray } from '@/lib/utils'
import { RotateCcw, ChevronLeft, ChevronRight, Shuffle, Layers } from 'lucide-react'

interface Flashcard {
  front: string
  back: string
  subject: string
}

export function FlashcardsPage() {
  const { state } = useApp()
  const [currentIndex, setCurrentIndex] = useState(0)
  const [isFlipped, setIsFlipped] = useState(false)
  const [direction, setDirection] = useState(0)

  const cards = useMemo(() => {
    const allCards: Flashcard[] = []
    for (const subject of state.subjects) {
      for (const topic of subject.topics) {
        const parsed = parseContent(topic.content)
        for (const q of parsed.questions) {
          if (q.type === 'meerkeuze') {
            allCards.push({
              front: q.vraag,
              back: q.opties[q.correct],
              subject: subject.naam,
            })
          } else if (q.type === 'invullen') {
            allCards.push({
              front: q.vraag,
              back: q.antwoord,
              subject: subject.naam,
            })
          } else if (q.type === 'waar-of-niet') {
            allCards.push({
              front: q.vraag,
              back: q.antwoord ? 'Waar' : 'Niet waar',
              subject: subject.naam,
            })
          }
        }
      }
    }
    return allCards
  }, [state.subjects])

  const [shuffledCards, setShuffledCards] = useState(cards)

  const handleShuffle = useCallback(() => {
    setShuffledCards(shuffleArray(cards))
    setCurrentIndex(0)
    setIsFlipped(false)
  }, [cards])

  const goNext = () => {
    if (currentIndex < shuffledCards.length - 1) {
      setDirection(1)
      setIsFlipped(false)
      setCurrentIndex(prev => prev + 1)
    }
  }

  const goPrev = () => {
    if (currentIndex > 0) {
      setDirection(-1)
      setIsFlipped(false)
      setCurrentIndex(prev => prev - 1)
    }
  }

  const card = shuffledCards[currentIndex]

  if (cards.length === 0) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <GlassPanel className="p-12 text-center max-w-md">
          <Layers size={48} className="text-[#4a4a52] mx-auto mb-4" />
          <h3 className="text-xl font-bold text-[#e8e8ea] mb-2">Geen flashcards</h3>
          <p className="text-sm text-[#6e6e76]">
            Er zijn nog geen vragen beschikbaar om als flashcard te tonen.
          </p>
        </GlassPanel>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={springs.smooth}
        className="flex items-center justify-between"
      >
        <div>
          <span className="text-[11px] uppercase tracking-[0.15em] font-semibold text-[#8b8bf5] mb-1 block">
            Flashcards
          </span>
          <h1 className="text-3xl font-extrabold tracking-tight text-[#e8e8ea]">
            Oefen je kennis
          </h1>
        </div>

        <GlassButton
          variant="ghost"
          size="sm"
          icon={<Shuffle size={16} />}
          onClick={handleShuffle}
        >
          Shuffle
        </GlassButton>
      </motion.div>

      {/* Card */}
      <div className="flex items-center justify-center py-8">
        <div className="w-full max-w-[520px]" style={{ perspective: '1200px' }}>
          <AnimatePresence mode="wait" custom={direction}>
            <motion.div
              key={currentIndex}
              initial={{ opacity: 0, x: direction * 100 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: direction * -100 }}
              transition={springs.smooth}
              onClick={() => setIsFlipped(!isFlipped)}
              className="cursor-pointer"
            >
              <motion.div
                animate={{ rotateY: isFlipped ? 180 : 0 }}
                transition={springs.smooth}
                style={{ transformStyle: 'preserve-3d' }}
                className="relative w-full aspect-[4/3]"
              >
                {/* Front */}
                <div
                  className="absolute inset-0 bg-[rgba(255,255,255,0.04)] backdrop-blur-[60px] border border-[rgba(255,255,255,0.06)] rounded-3xl shadow-[0_12px_48px_rgba(0,0,0,0.18)] flex flex-col items-center justify-center p-10"
                  style={{ backfaceVisibility: 'hidden' }}
                >
                  <div className="absolute top-0 left-6 right-6 h-px bg-gradient-to-r from-transparent via-[rgba(255,255,255,0.06)] to-transparent" />
                  <span className="text-[11px] uppercase tracking-wider text-[#6e6e76] font-medium mb-4">{card?.subject}</span>
                  <p className="text-xl font-bold text-[#e8e8ea] text-center leading-relaxed">{card?.front}</p>
                  <span className="text-[11px] text-[#4a4a52] mt-6 uppercase tracking-wider">Klik om te draaien</span>
                </div>

                {/* Back */}
                <div
                  className="absolute inset-0 bg-[rgba(139,139,245,0.06)] backdrop-blur-[60px] border border-[rgba(139,139,245,0.12)] rounded-3xl shadow-[0_12px_48px_rgba(0,0,0,0.18)] flex flex-col items-center justify-center p-10"
                  style={{ backfaceVisibility: 'hidden', transform: 'rotateY(180deg)' }}
                >
                  <div className="absolute top-0 left-6 right-6 h-px bg-gradient-to-r from-transparent via-[rgba(139,139,245,0.15)] to-transparent" />
                  <span className="text-[11px] uppercase tracking-wider text-[#8b8bf5] font-medium mb-4">Antwoord</span>
                  <p className="text-2xl font-bold text-[#e8e8ea] text-center">{card?.back}</p>
                </div>
              </motion.div>
            </motion.div>
          </AnimatePresence>
        </div>
      </div>

      {/* Controls */}
      <div className="flex items-center justify-center gap-4">
        <GlassButton
          variant="ghost"
          icon={<ChevronLeft size={20} />}
          onClick={goPrev}
          disabled={currentIndex === 0}
        />

        <GlassPanel className="px-4 py-2">
          <span className="text-sm font-medium text-[#e8e8ea]">
            {currentIndex + 1} <span className="text-[#6e6e76]">/ {shuffledCards.length}</span>
          </span>
        </GlassPanel>

        <GlassButton
          variant="ghost"
          icon={<ChevronRight size={20} />}
          onClick={goNext}
          disabled={currentIndex === shuffledCards.length - 1}
        />
      </div>

      {/* Progress dots */}
      <div className="flex justify-center gap-1.5">
        {shuffledCards.slice(0, Math.min(20, shuffledCards.length)).map((_, i) => (
          <motion.div
            key={i}
            className={`w-1.5 h-1.5 rounded-full transition-colors ${
              i === currentIndex ? 'bg-[#8b8bf5]' : 'bg-[rgba(255,255,255,0.08)]'
            }`}
            animate={i === currentIndex ? { scale: [1, 1.3, 1] } : {}}
            transition={{ duration: 0.3 }}
          />
        ))}
      </div>
    </div>
  )
}
