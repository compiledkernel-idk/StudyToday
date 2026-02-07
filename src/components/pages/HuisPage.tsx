// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { motion } from 'framer-motion'
import { staggerContainer, staggerItem, springs, cardHover } from '@/lib/motion'
import { getGreeting } from '@/lib/utils'
import { useApp } from '@/lib/store'
import { GlassPanel } from '@/components/ui/GlassPanel'
import { ProgressRing } from '@/components/ui/ProgressRing'
import { useNavigate } from 'react-router-dom'
import { BookOpen, Flame, Clock, Zap, ArrowRight, Sparkles } from 'lucide-react'

export function HuisPage() {
  const { state } = useApp()
  const navigate = useNavigate()
  const greeting = getGreeting()

  const totalTopics = state.subjects.reduce((acc, s) => acc + s.topics.length, 0)
  const totalSessions = state.sessions.length
  const totalMinutes = Math.floor(state.sessions.reduce((acc, s) => acc + s.duration, 0) / 60)

  return (
    <div className="space-y-8">
      {/* Hero greeting */}
      <motion.div
        className="relative overflow-hidden rounded-3xl p-10"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={springs.smooth}
      >
        {/* Gradient background for hero */}
        <div className="absolute inset-0 bg-gradient-to-br from-[rgba(139,139,245,0.08)] via-[rgba(139,139,245,0.03)] to-transparent rounded-3xl" />
        <div className="absolute inset-0 bg-[rgba(255,255,255,0.02)] backdrop-blur-[40px] border border-[rgba(255,255,255,0.06)] rounded-3xl" />

        {/* Floating accent orb */}
        <motion.div
          className="absolute top-4 right-12 w-32 h-32 bg-[rgba(139,139,245,0.06)] rounded-full blur-2xl"
          animate={{ scale: [1, 1.1, 1], opacity: [0.5, 0.8, 0.5] }}
          transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut' }}
        />
        <motion.div
          className="absolute bottom-2 left-20 w-20 h-20 bg-[rgba(100,100,220,0.04)] rounded-full blur-xl"
          animate={{ y: [0, -8, 0], x: [0, 4, 0] }}
          transition={{ duration: 5, repeat: Infinity, ease: 'easeInOut' }}
        />

        <div className="relative z-10">
          <motion.div
            className="flex items-center gap-2 mb-2"
            initial={{ opacity: 0, x: -10 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.1, ...springs.gentle }}
          >
            <Sparkles size={14} className="text-[#8b8bf5]" />
            <span className="text-[11px] uppercase tracking-[0.15em] font-semibold text-[#8b8bf5]">
              StudyToday
            </span>
          </motion.div>

          <motion.h1
            className="text-5xl font-extrabold tracking-tight text-[#e8e8ea] mb-2"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.15, ...springs.gentle }}
          >
            {greeting}
          </motion.h1>

          <motion.p
            className="text-lg text-[#6e6e76] font-medium"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.25, ...springs.gentle }}
          >
            Klaar om te studeren? Je hebt {totalTopics} onderwerpen beschikbaar.
          </motion.p>
        </div>
      </motion.div>

      {/* Stats row */}
      <motion.div
        variants={staggerContainer}
        initial="initial"
        animate="enter"
        className="grid grid-cols-3 gap-4"
      >
        {[
          { icon: Flame, label: 'Studiedagen', value: totalSessions || 0, color: '#f59e0b' },
          { icon: Clock, label: 'Minuten gestudeerd', value: totalMinutes || 0, color: '#8b8bf5' },
          { icon: Zap, label: 'Onderwerpen', value: totalTopics, color: '#10b981' },
        ].map((stat) => (
          <motion.div key={stat.label} variants={staggerItem}>
            <GlassPanel className="p-5 flex items-center gap-4" hover>
              <div
                className="w-11 h-11 rounded-xl flex items-center justify-center flex-shrink-0"
                style={{ background: `${stat.color}15`, border: `1px solid ${stat.color}25` }}
              >
                <stat.icon size={20} style={{ color: stat.color }} />
              </div>
              <div>
                <div className="text-2xl font-bold text-[#e8e8ea]">{stat.value}</div>
                <div className="text-[11px] uppercase tracking-wider text-[#6e6e76] font-medium">{stat.label}</div>
              </div>
            </GlassPanel>
          </motion.div>
        ))}
      </motion.div>

      {/* Subjects section */}
      <div>
        <div className="flex items-center justify-between mb-5">
          <h2 className="text-xl font-bold text-[#e8e8ea]">Jouw vakken</h2>
          <motion.button
            onClick={() => navigate('/vakken')}
            className="flex items-center gap-1.5 text-xs font-medium text-[#6e6e76] hover:text-[#8b8bf5] transition-colors cursor-pointer"
            whileHover={{ x: 2 }}
          >
            Alles bekijken <ArrowRight size={14} />
          </motion.button>
        </div>

        <motion.div
          variants={staggerContainer}
          initial="initial"
          animate="enter"
          className="grid grid-cols-2 lg:grid-cols-3 gap-4"
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
                <GlassPanel className="p-6 relative overflow-hidden group">
                  {/* Hover gradient */}
                  <div className="absolute inset-0 bg-gradient-to-br from-[rgba(139,139,245,0.05)] to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />

                  <div className="relative z-10">
                    <span className="text-3xl mb-3 block">{subject.icon}</span>
                    <h3 className="text-lg font-bold text-[#e8e8ea] mb-1">{subject.naam}</h3>
                    <p className="text-xs text-[#6e6e76] mb-4">{subject.topics.length} onderwerpen</p>

                    <div className="flex items-center justify-between">
                      <ProgressRing progress={0} size={36} strokeWidth={2.5} />
                      <ArrowRight size={16} className="text-[#4a4a52] group-hover:text-[#8b8bf5] transition-colors" />
                    </div>
                  </div>
                </GlassPanel>
              </motion.div>
            </motion.div>
          ))}
        </motion.div>
      </div>

      {/* Quick tip / empty state */}
      {state.subjects.length === 0 && (
        <GlassPanel className="p-8 text-center">
          <motion.div
            animate={{ y: [0, -5, 0] }}
            transition={{ duration: 3, repeat: Infinity, ease: 'easeInOut' }}
          >
            <BookOpen size={40} className="text-[#4a4a52] mx-auto mb-4" />
          </motion.div>
          <h3 className="text-lg font-bold text-[#e8e8ea] mb-2">Geen vakken gevonden</h3>
          <p className="text-sm text-[#6e6e76]">Content wordt geladen vanuit GitHub...</p>
        </GlassPanel>
      )}
    </div>
  )
}
