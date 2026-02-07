// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { useState, useMemo } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useParams, useNavigate } from 'react-router-dom'
import { springs, staggerContainer, staggerItem } from '@/lib/motion'
import { useApp } from '@/lib/store'
import { parseContent } from '@/lib/content-parser'
import { GlassPanel } from '@/components/ui/GlassPanel'
import { GlassButton } from '@/components/ui/GlassButton'
import { MeerkeuzeCard } from '@/components/study/MeerkeuzeCard'
import { InvullenCard } from '@/components/study/InvullenCard'
import { WaarOfNietCard } from '@/components/study/WaarOfNietCard'
import { KoppelenCard } from '@/components/study/KoppelenCard'
import { OpenCard } from '@/components/study/OpenCard'
import { ArrowLeft, BookOpen, Brain, Layers, Bookmark, BookmarkCheck } from 'lucide-react'
import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'

type StudyMode = 'lezen' | 'oefenen' | 'flashcards'

export function TopicPage() {
  const { subjectId, topicSlug } = useParams()
  const { state, dispatch } = useApp()
  const navigate = useNavigate()
  const [mode, setMode] = useState<StudyMode>('lezen')

  const subject = state.subjects.find(s => s.id === subjectId)
  const topic = subject?.topics.find(t => t.slug === topicSlug)
  const isBookmarked = state.bookmarks.some(b => b.topicId === topic?.id)

  const parsed = useMemo(() => {
    if (!topic) return null
    return parseContent(topic.content)
  }, [topic])

  if (!subject || !topic || !parsed) {
    return (
      <GlassPanel className="p-12 text-center">
        <h3 className="text-lg font-bold text-[#e8e8ea]">Onderwerp niet gevonden</h3>
      </GlassPanel>
    )
  }

  const toggleBookmark = () => {
    if (isBookmarked) {
      dispatch({ type: 'REMOVE_BOOKMARK', payload: topic.id })
    } else {
      dispatch({ type: 'ADD_BOOKMARK', payload: { topicId: topic.id, timestamp: Date.now() } })
    }
  }

  const renderQuestion = (question: any, index: number) => {
    switch (question.type) {
      case 'meerkeuze':
        return <MeerkeuzeCard key={index} question={question} />
      case 'invullen':
        return <InvullenCard key={index} question={question} />
      case 'waar-of-niet':
        return <WaarOfNietCard key={index} question={question} />
      case 'koppelen':
        return <KoppelenCard key={index} question={question} />
      case 'open':
        return <OpenCard key={index} question={question} />
      default:
        return null
    }
  }

  return (
    <div className="space-y-6">
      {/* Top bar */}
      <div className="flex items-center justify-between">
        <motion.div
          initial={{ opacity: 0, x: -10 }}
          animate={{ opacity: 1, x: 0 }}
          transition={springs.gentle}
          className="flex items-center gap-3"
        >
          <GlassButton
            variant="ghost"
            size="sm"
            icon={<ArrowLeft size={16} />}
            onClick={() => navigate(`/vakken/${subjectId}`)}
          >
            {subject.naam}
          </GlassButton>
        </motion.div>

        <motion.div
          className="flex items-center gap-2"
          initial={{ opacity: 0, x: 10 }}
          animate={{ opacity: 1, x: 0 }}
          transition={springs.gentle}
        >
          <GlassButton
            variant="ghost"
            size="sm"
            icon={isBookmarked ? <BookmarkCheck size={16} className="text-[#8b8bf5]" /> : <Bookmark size={16} />}
            onClick={toggleBookmark}
          />
        </motion.div>
      </div>

      {/* Progress bar */}
      <motion.div
        className="h-0.5 bg-[rgba(255,255,255,0.04)] rounded-full overflow-hidden"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
      >
        <motion.div
          className="h-full bg-[#8b8bf5] rounded-full"
          initial={{ width: '0%' }}
          animate={{ width: '0%' }}
          transition={springs.smooth}
        />
      </motion.div>

      {/* Mode tabs */}
      <GlassPanel className="p-1.5 flex gap-1 w-fit">
        {([
          { id: 'lezen' as const, icon: BookOpen, label: 'Lezen' },
          { id: 'oefenen' as const, icon: Brain, label: 'Oefenen' },
          { id: 'flashcards' as const, icon: Layers, label: 'Flashcards' },
        ]).map((tab) => (
          <motion.button
            key={tab.id}
            onClick={() => setMode(tab.id)}
            className={`relative flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-colors cursor-pointer ${
              mode === tab.id ? 'text-[#e8e8ea]' : 'text-[#6e6e76] hover:text-[#e8e8ea]'
            }`}
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
          >
            {mode === tab.id && (
              <motion.div
                layoutId="mode-tab"
                className="absolute inset-0 bg-[rgba(139,139,245,0.12)] border border-[rgba(139,139,245,0.15)] rounded-xl"
                transition={springs.stiff}
              />
            )}
            <tab.icon size={16} className="relative z-10" />
            <span className="relative z-10">{tab.label}</span>
          </motion.button>
        ))}
      </GlassPanel>

      {/* Content */}
      <AnimatePresence mode="wait">
        <motion.div
          key={mode}
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -10 }}
          transition={springs.smooth}
        >
          {mode === 'lezen' && (
            <div className="max-w-[720px]">
              {/* Render markdown content */}
              <div className="prose-custom">
                <ReactMarkdown
                  remarkPlugins={[remarkGfm]}
                  components={{
                    h1: ({ children }) => (
                      <motion.h1
                        className="text-4xl font-extrabold tracking-tight text-[#e8e8ea] mb-4 mt-2"
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={springs.gentle}
                      >
                        {children}
                      </motion.h1>
                    ),
                    h2: ({ children }) => (
                      <h2 className="text-2xl font-bold text-[#e8e8ea] mb-3 mt-8">{children}</h2>
                    ),
                    h3: ({ children }) => (
                      <h3 className="text-lg font-bold text-[#e8e8ea] mb-2 mt-6">{children}</h3>
                    ),
                    p: ({ children }) => (
                      <p className="text-base text-[#b4b4ba] leading-relaxed mb-4">{children}</p>
                    ),
                    strong: ({ children }) => (
                      <strong className="text-[#e8e8ea] font-semibold">{children}</strong>
                    ),
                    blockquote: ({ children }) => (
                      <GlassPanel className="p-4 my-4 border-l-2 border-l-[#8b8bf5]">
                        <div className="text-[#b4b4ba] font-mono text-sm">{children}</div>
                      </GlassPanel>
                    ),
                    ul: ({ children }) => (
                      <ul className="space-y-2 mb-4 ml-1">{children}</ul>
                    ),
                    ol: ({ children }) => (
                      <ol className="space-y-2 mb-4 ml-1 list-decimal list-inside">{children}</ol>
                    ),
                    li: ({ children }) => (
                      <li className="text-[#b4b4ba] flex items-start gap-2">
                        <span className="text-[#8b8bf5] mt-1.5 w-1.5 h-1.5 rounded-full bg-[#8b8bf5] flex-shrink-0 block" />
                        <span className="flex-1">{children}</span>
                      </li>
                    ),
                    table: ({ children }) => (
                      <GlassPanel className="my-4 overflow-hidden">
                        <table className="w-full">{children}</table>
                      </GlassPanel>
                    ),
                    thead: ({ children }) => (
                      <thead className="border-b border-[rgba(255,255,255,0.06)]">{children}</thead>
                    ),
                    th: ({ children }) => (
                      <th className="text-left p-3 text-xs uppercase tracking-wider text-[#6e6e76] font-semibold">{children}</th>
                    ),
                    td: ({ children }) => (
                      <td className="p-3 text-sm text-[#b4b4ba] border-t border-[rgba(255,255,255,0.03)]">{children}</td>
                    ),
                  }}
                >
                  {parsed.markdown}
                </ReactMarkdown>
              </div>

              {/* Questions inline */}
              {parsed.questions.length > 0 && (
                <motion.div
                  variants={staggerContainer}
                  initial="initial"
                  animate="enter"
                  className="mt-8 space-y-6"
                >
                  {parsed.questions.map((q, i) => (
                    <motion.div key={i} variants={staggerItem}>
                      {renderQuestion(q, i)}
                    </motion.div>
                  ))}
                </motion.div>
              )}
            </div>
          )}

          {mode === 'oefenen' && (
            <motion.div
              variants={staggerContainer}
              initial="initial"
              animate="enter"
              className="max-w-[720px] space-y-6"
            >
              <GlassPanel className="p-5">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-[rgba(139,139,245,0.1)] flex items-center justify-center">
                    <Brain size={20} className="text-[#8b8bf5]" />
                  </div>
                  <div>
                    <h3 className="text-base font-bold text-[#e8e8ea]">Oefenmodus</h3>
                    <p className="text-xs text-[#6e6e76]">{parsed.questions.length} vragen</p>
                  </div>
                </div>
              </GlassPanel>

              {parsed.questions.map((q, i) => (
                <motion.div key={i} variants={staggerItem}>
                  {renderQuestion(q, i)}
                </motion.div>
              ))}
            </motion.div>
          )}

          {mode === 'flashcards' && (
            <div className="flex items-center justify-center min-h-[400px]">
              <GlassPanel className="p-12 text-center max-w-md">
                <Layers size={40} className="text-[#4a4a52] mx-auto mb-4" />
                <h3 className="text-lg font-bold text-[#e8e8ea] mb-2">Flashcards</h3>
                <p className="text-sm text-[#6e6e76] mb-4">
                  Gebruik de flashcards pagina voor een volledige ervaring.
                </p>
                <GlassButton
                  variant="accent"
                  onClick={() => navigate(`/flashcards?subject=${subjectId}`)}
                >
                  Open Flashcards
                </GlassButton>
              </GlassPanel>
            </div>
          )}
        </motion.div>
      </AnimatePresence>
    </div>
  )
}
