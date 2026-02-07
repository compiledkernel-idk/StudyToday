// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { motion } from 'framer-motion'
import { staggerContainer, staggerItem, cardHover, springs } from '@/lib/motion'
import { useApp } from '@/lib/store'
import { useNavigate } from 'react-router-dom'
import { GlassPanel } from '@/components/ui/GlassPanel'
import { ProgressRing } from '@/components/ui/ProgressRing'
import { ArrowRight, BookOpen } from 'lucide-react'

export function VakkenPage() {
  const { state } = useApp()
  const navigate = useNavigate()

  return (
    <div className="space-y-8">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={springs.smooth}
      >
        <span className="text-[11px] uppercase tracking-[0.15em] font-semibold text-[#8b8bf5] mb-2 block">
          Overzicht
        </span>
        <h1 className="text-4xl font-extrabold tracking-tight text-[#e8e8ea]">Vakken</h1>
        <p className="text-[#6e6e76] mt-2">Kies een vak om te beginnen met studeren.</p>
      </motion.div>

      {/* Subject grid */}
      <motion.div
        variants={staggerContainer}
        initial="initial"
        animate="enter"
        className="grid grid-cols-2 lg:grid-cols-3 gap-5"
      >
        {state.subjects.map((subject) => (
          <motion.div key={subject.id} variants={staggerItem}>
            <motion.div
              variants={cardHover}
              initial="rest"
              whileHover="hover"
              whileTap="tap"
              onClick={() => navigate(`/vakken/${subject.id}`)}
              className="cursor-pointer"
            >
              <GlassPanel className="p-7 relative overflow-hidden group h-full">
                <div className="absolute inset-0 bg-gradient-to-br from-[rgba(139,139,245,0.06)] to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />

                {/* Decorative orb */}
                <motion.div
                  className="absolute -top-4 -right-4 w-24 h-24 bg-[rgba(139,139,245,0.03)] rounded-full blur-xl"
                  animate={{ scale: [1, 1.1, 1] }}
                  transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut' }}
                />

                <div className="relative z-10">
                  <div className="flex items-start justify-between mb-5">
                    <span className="text-4xl">{subject.icon}</span>
                    <ProgressRing progress={0} size={40} strokeWidth={2.5} />
                  </div>

                  <h3 className="text-xl font-bold text-[#e8e8ea] mb-1">{subject.naam}</h3>
                  <p className="text-sm text-[#6e6e76] mb-5">
                    {subject.topics.length} onderwerpen
                  </p>

                  <div className="flex items-center gap-2 text-xs font-medium text-[#8b8bf5] opacity-0 group-hover:opacity-100 transition-opacity">
                    Openen <ArrowRight size={14} />
                  </div>
                </div>
              </GlassPanel>
            </motion.div>
          </motion.div>
        ))}
      </motion.div>

      {state.subjects.length === 0 && (
        <GlassPanel className="p-12 text-center">
          <BookOpen size={48} className="text-[#4a4a52] mx-auto mb-4" />
          <h3 className="text-lg font-bold text-[#e8e8ea] mb-2">Geen vakken beschikbaar</h3>
          <p className="text-sm text-[#6e6e76]">Wacht tot de content is gesynchroniseerd...</p>
        </GlassPanel>
      )}
    </div>
  )
}
