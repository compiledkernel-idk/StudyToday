// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { motion } from 'framer-motion'
import { staggerContainer, staggerItem, springs, cardHover } from '@/lib/motion'
import { useApp } from '@/lib/store'
import { useParams, useNavigate } from 'react-router-dom'
import { GlassPanel } from '@/components/ui/GlassPanel'
import { GlassButton } from '@/components/ui/GlassButton'
import { ArrowLeft, ArrowRight, FileText, Layers } from 'lucide-react'

export function SubjectPage() {
  const { subjectId } = useParams()
  const { state } = useApp()
  const navigate = useNavigate()

  const subject = state.subjects.find(s => s.id === subjectId)

  if (!subject) {
    return (
      <GlassPanel className="p-12 text-center">
        <h3 className="text-lg font-bold text-[#e8e8ea]">Vak niet gevonden</h3>
      </GlassPanel>
    )
  }

  return (
    <div className="space-y-8">
      {/* Back button + header */}
      <div>
        <motion.div
          initial={{ opacity: 0, x: -10 }}
          animate={{ opacity: 1, x: 0 }}
          transition={springs.gentle}
        >
          <GlassButton
            variant="ghost"
            size="sm"
            icon={<ArrowLeft size={16} />}
            onClick={() => navigate('/vakken')}
            className="mb-4"
          >
            Terug
          </GlassButton>
        </motion.div>

        <motion.div
          className="flex items-center gap-4"
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={springs.smooth}
        >
          <span className="text-5xl">{subject.icon}</span>
          <div>
            <h1 className="text-4xl font-extrabold tracking-tight text-[#e8e8ea]">
              {subject.naam}
            </h1>
            <p className="text-[#6e6e76] mt-1">{subject.topics.length} onderwerpen</p>
          </div>
        </motion.div>
      </div>

      {/* Action buttons */}
      <motion.div
        className="flex gap-3"
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1, ...springs.smooth }}
      >
        <GlassButton
          variant="accent"
          icon={<Layers size={16} />}
          onClick={() => navigate(`/flashcards?subject=${subject.id}`)}
        >
          Flashcards starten
        </GlassButton>
      </motion.div>

      {/* Topics list */}
      <motion.div
        variants={staggerContainer}
        initial="initial"
        animate="enter"
        className="space-y-3"
      >
        {subject.topics.map((topic, index) => (
          <motion.div key={topic.id} variants={staggerItem}>
            <motion.div
              variants={cardHover}
              initial="rest"
              whileHover="hover"
              whileTap="tap"
              onClick={() => navigate(`/vakken/${subject.id}/${topic.slug}`)}
              className="cursor-pointer"
            >
              <GlassPanel className="p-5 flex items-center gap-4 group">
                <div className="w-10 h-10 rounded-xl bg-[rgba(139,139,245,0.08)] border border-[rgba(139,139,245,0.12)] flex items-center justify-center flex-shrink-0">
                  <FileText size={18} className="text-[#8b8bf5]" />
                </div>

                <div className="flex-1 min-w-0">
                  <h3 className="text-base font-semibold text-[#e8e8ea] truncate">{topic.titel}</h3>
                  <p className="text-xs text-[#6e6e76]">Onderwerp {index + 1}</p>
                </div>

                <ArrowRight size={16} className="text-[#4a4a52] group-hover:text-[#8b8bf5] transition-colors flex-shrink-0" />
              </GlassPanel>
            </motion.div>
          </motion.div>
        ))}
      </motion.div>
    </div>
  )
}
