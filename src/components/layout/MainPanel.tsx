// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { motion, AnimatePresence } from 'framer-motion'
import { useLocation, Routes, Route } from 'react-router-dom'
import { pageVariants } from '@/lib/motion'
import { HuisPage } from '@/components/pages/HuisPage'
import { VakkenPage } from '@/components/pages/VakkenPage'
import { SubjectPage } from '@/components/pages/SubjectPage'
import { TopicPage } from '@/components/pages/TopicPage'
import { ZoekenPage } from '@/components/pages/ZoekenPage'
import { FlashcardsPage } from '@/components/pages/FlashcardsPage'
import { NotitiesPage } from '@/components/pages/NotitiesPage'
import { TimerPage } from '@/components/pages/TimerPage'
import { Minus, Square, X } from 'lucide-react'

function WindowControls() {
  const handleMinimize = async () => {
    try {
      const { getCurrentWindow } = await import('@tauri-apps/api/window')
      await getCurrentWindow().minimize()
    } catch {}
  }

  const handleMaximize = async () => {
    try {
      const { getCurrentWindow } = await import('@tauri-apps/api/window')
      await getCurrentWindow().toggleMaximize()
    } catch {}
  }

  const handleClose = async () => {
    try {
      const { getCurrentWindow } = await import('@tauri-apps/api/window')
      await getCurrentWindow().close()
    } catch {}
  }

  return (
    <div className="absolute top-3 right-4 flex items-center gap-2 z-30">
      <button
        onClick={handleMinimize}
        className="w-3.5 h-3.5 rounded-full bg-[rgba(255,255,255,0.08)] hover:bg-[rgba(255,255,255,0.15)] flex items-center justify-center group transition-colors cursor-pointer"
      >
        <Minus size={8} className="text-transparent group-hover:text-[#a8a8b0] transition-colors" />
      </button>
      <button
        onClick={handleMaximize}
        className="w-3.5 h-3.5 rounded-full bg-[rgba(255,255,255,0.08)] hover:bg-[rgba(255,255,255,0.15)] flex items-center justify-center group transition-colors cursor-pointer"
      >
        <Square size={7} className="text-transparent group-hover:text-[#a8a8b0] transition-colors" />
      </button>
      <button
        onClick={handleClose}
        className="w-3.5 h-3.5 rounded-full bg-[rgba(255,255,255,0.08)] hover:bg-[#ef4444] flex items-center justify-center group transition-colors cursor-pointer"
      >
        <X size={8} className="text-transparent group-hover:text-white transition-colors" />
      </button>
    </div>
  )
}

export function MainPanel() {
  const location = useLocation()

  return (
    <div className="fixed top-3 bottom-3 right-3 left-[90px] z-10">
      <div className="w-full h-full bg-[rgba(255,255,255,0.02)] backdrop-blur-[40px] saturate-[1.2] border border-[rgba(255,255,255,0.06)] rounded-2xl shadow-[0_8px_32px_rgba(0,0,0,0.12)] overflow-hidden relative">
        {/* Inner highlight */}
        <div className="absolute top-0 left-4 right-4 h-px bg-gradient-to-r from-transparent via-[rgba(255,255,255,0.06)] to-transparent pointer-events-none z-20" />

        {/* Drag region - uses both CSS and Tauri attribute for compatibility */}
        <div
          data-tauri-drag-region
          className="drag-region absolute top-0 left-0 right-0 h-10 z-10"
        />

        {/* Window controls */}
        <WindowControls />

        {/* Content */}
        <div className="h-full overflow-y-auto pt-12 px-8 pb-8">
          <AnimatePresence mode="wait">
            <motion.div
              key={location.pathname}
              variants={pageVariants}
              initial="initial"
              animate="enter"
              exit="exit"
              className="max-w-[1200px] mx-auto"
            >
              <Routes location={location}>
                <Route path="/" element={<HuisPage />} />
                <Route path="/vakken" element={<VakkenPage />} />
                <Route path="/vakken/:subjectId" element={<SubjectPage />} />
                <Route path="/vakken/:subjectId/:topicSlug" element={<TopicPage />} />
                <Route path="/zoeken" element={<ZoekenPage />} />
                <Route path="/flashcards" element={<FlashcardsPage />} />
                <Route path="/notities" element={<NotitiesPage />} />
                <Route path="/timer" element={<TimerPage />} />
              </Routes>
            </motion.div>
          </AnimatePresence>
        </div>
      </div>
    </div>
  )
}
