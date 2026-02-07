// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { useState, useEffect, useMemo } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useNavigate } from 'react-router-dom'
import { Search, FileText, BookOpen, ArrowRight } from 'lucide-react'
import { scaleIn, staggerContainer, staggerItem } from '@/lib/motion'
import { GlassInput } from '@/components/ui/GlassInput'
import { useApp } from '@/lib/store'

export function CommandPalette() {
  const [open, setOpen] = useState(false)
  const [query, setQuery] = useState('')
  const navigate = useNavigate()
  const { state } = useApp()

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault()
        setOpen(prev => !prev)
      }
      if (e.key === 'Escape') setOpen(false)
    }
    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [])

  const results = useMemo(() => {
    if (!query.trim()) return []
    const q = query.toLowerCase()
    const items: { type: string; title: string; subtitle: string; path: string }[] = []

    for (const subject of state.subjects) {
      if (subject.naam.toLowerCase().includes(q)) {
        items.push({
          type: 'subject',
          title: `${subject.icon} ${subject.naam}`,
          subtitle: `${subject.topics.length} onderwerpen`,
          path: `/vakken/${subject.id}`,
        })
      }
      for (const topic of subject.topics) {
        if (topic.titel.toLowerCase().includes(q) || topic.content.toLowerCase().includes(q)) {
          items.push({
            type: 'topic',
            title: topic.titel,
            subtitle: subject.naam,
            path: `/vakken/${subject.id}/${topic.slug}`,
          })
        }
      }
    }
    return items.slice(0, 8)
  }, [query, state.subjects])

  if (!open) return null

  return (
    <AnimatePresence>
      <motion.div
        className="fixed inset-0 z-[100] flex items-start justify-center pt-[20vh]"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
      >
        {/* Backdrop */}
        <motion.div
          className="absolute inset-0 bg-[rgba(0,0,0,0.5)] backdrop-blur-sm"
          onClick={() => setOpen(false)}
        />

        {/* Palette */}
        <motion.div
          variants={scaleIn}
          initial="initial"
          animate="enter"
          exit="exit"
          className="relative w-full max-w-[560px] mx-4"
        >
          <div className="bg-[rgba(30,30,35,0.9)] backdrop-blur-[60px] border border-[rgba(255,255,255,0.08)] rounded-2xl shadow-[0_24px_64px_rgba(0,0,0,0.4)] overflow-hidden">
            {/* Search input */}
            <div className="p-4 border-b border-[rgba(255,255,255,0.06)]">
              <GlassInput
                icon={<Search size={18} />}
                placeholder="Zoek onderwerpen, vakken..."
                value={query}
                onChange={e => setQuery(e.target.value)}
                autoFocus
                className="bg-transparent border-none"
              />
            </div>

            {/* Results */}
            {results.length > 0 && (
              <motion.div
                variants={staggerContainer}
                initial="initial"
                animate="enter"
                className="p-2 max-h-[320px] overflow-y-auto"
              >
                {results.map((result, i) => (
                  <motion.button
                    key={`${result.path}-${i}`}
                    variants={staggerItem}
                    onClick={() => { navigate(result.path); setOpen(false); setQuery('') }}
                    className="w-full flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-[rgba(255,255,255,0.04)] transition-colors cursor-pointer group"
                  >
                    <div className="w-8 h-8 rounded-lg bg-[rgba(255,255,255,0.04)] flex items-center justify-center flex-shrink-0">
                      {result.type === 'subject' ? <BookOpen size={16} className="text-[#8b8bf5]" /> : <FileText size={16} className="text-[#6e6e76]" />}
                    </div>
                    <div className="flex-1 text-left">
                      <div className="text-sm font-medium text-[#e8e8ea]">{result.title}</div>
                      <div className="text-xs text-[#6e6e76]">{result.subtitle}</div>
                    </div>
                    <ArrowRight size={14} className="text-[#4a4a52] group-hover:text-[#6e6e76] transition-colors" />
                  </motion.button>
                ))}
              </motion.div>
            )}

            {/* Empty state */}
            {query && results.length === 0 && (
              <div className="p-8 text-center">
                <p className="text-[#6e6e76] text-sm">Geen resultaten gevonden</p>
              </div>
            )}

            {/* Hint */}
            {!query && (
              <div className="p-6 text-center">
                <p className="text-[#4a4a52] text-xs uppercase tracking-wider font-medium">Begin met typen om te zoeken</p>
              </div>
            )}
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  )
}
