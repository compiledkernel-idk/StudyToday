// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { useState, useMemo } from 'react'
import { motion } from 'framer-motion'
import { useNavigate } from 'react-router-dom'
import { springs, staggerContainer, staggerItem } from '@/lib/motion'
import { useApp } from '@/lib/store'
import { GlassPanel } from '@/components/ui/GlassPanel'
import { GlassInput } from '@/components/ui/GlassInput'
import { Search, FileText, BookOpen, ArrowRight } from 'lucide-react'

export function ZoekenPage() {
  const [query, setQuery] = useState('')
  const { state } = useApp()
  const navigate = useNavigate()

  const results = useMemo(() => {
    if (!query.trim()) return []
    const q = query.toLowerCase()
    const items: { type: string; title: string; subtitle: string; path: string; icon: string }[] = []

    for (const subject of state.subjects) {
      if (subject.naam.toLowerCase().includes(q)) {
        items.push({
          type: 'subject',
          title: subject.naam,
          subtitle: `${subject.topics.length} onderwerpen`,
          path: `/vakken/${subject.id}`,
          icon: subject.icon,
        })
      }
      for (const topic of subject.topics) {
        if (topic.titel.toLowerCase().includes(q) || topic.content.toLowerCase().includes(q)) {
          items.push({
            type: 'topic',
            title: topic.titel,
            subtitle: subject.naam,
            path: `/vakken/${subject.id}/${topic.slug}`,
            icon: subject.icon,
          })
        }
      }
    }
    return items
  }, [query, state.subjects])

  return (
    <div className="space-y-8 max-w-[680px] mx-auto">
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={springs.smooth}
        className="text-center"
      >
        <span className="text-[11px] uppercase tracking-[0.15em] font-semibold text-[#8b8bf5] mb-2 block">
          Zoeken
        </span>
        <h1 className="text-4xl font-extrabold tracking-tight text-[#e8e8ea] mb-6">
          Wat wil je leren?
        </h1>
      </motion.div>

      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1, ...springs.smooth }}
      >
        <GlassInput
          icon={<Search size={18} />}
          placeholder="Zoek onderwerpen, vakken, termen..."
          value={query}
          onChange={e => setQuery(e.target.value)}
          autoFocus
          className="h-14 text-base"
        />
      </motion.div>

      {results.length > 0 && (
        <motion.div
          variants={staggerContainer}
          initial="initial"
          animate="enter"
          className="space-y-2"
        >
          <p className="text-xs text-[#6e6e76] uppercase tracking-wider font-medium px-1">
            {results.length} resultaten
          </p>
          {results.map((result, i) => (
            <motion.div key={`${result.path}-${i}`} variants={staggerItem}>
              <GlassPanel
                className="p-4 flex items-center gap-4 cursor-pointer group"
                hover
                onClick={() => navigate(result.path)}
              >
                <div className="w-10 h-10 rounded-xl bg-[rgba(255,255,255,0.04)] flex items-center justify-center flex-shrink-0">
                  {result.type === 'subject' ? (
                    <span className="text-lg">{result.icon}</span>
                  ) : (
                    <FileText size={18} className="text-[#6e6e76]" />
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="text-sm font-semibold text-[#e8e8ea] truncate">{result.title}</div>
                  <div className="text-xs text-[#6e6e76]">{result.subtitle}</div>
                </div>
                <ArrowRight size={14} className="text-[#4a4a52] group-hover:text-[#8b8bf5] transition-colors flex-shrink-0" />
              </GlassPanel>
            </motion.div>
          ))}
        </motion.div>
      )}

      {query && results.length === 0 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="text-center py-12"
        >
          <Search size={40} className="text-[#4a4a52] mx-auto mb-4" />
          <p className="text-[#6e6e76]">Geen resultaten voor "{query}"</p>
        </motion.div>
      )}

      {!query && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.2 }}
          className="text-center py-8"
        >
          <p className="text-[#4a4a52] text-sm">
            Tip: Gebruik <kbd className="px-1.5 py-0.5 rounded-md bg-[rgba(255,255,255,0.04)] border border-[rgba(255,255,255,0.06)] text-[#6e6e76] text-xs font-mono">Ctrl+K</kbd> om snel te zoeken
          </p>
        </motion.div>
      )}
    </div>
  )
}
