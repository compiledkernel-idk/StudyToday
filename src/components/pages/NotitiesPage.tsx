// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { useState } from 'react'
import { motion } from 'framer-motion'
import { springs, staggerContainer, staggerItem } from '@/lib/motion'
import { useApp } from '@/lib/store'
import { GlassPanel } from '@/components/ui/GlassPanel'
import { GlassButton } from '@/components/ui/GlassButton'
import { Plus, StickyNote, Trash2 } from 'lucide-react'
import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'

export function NotitiesPage() {
  const { state, dispatch } = useApp()
  const [selectedNote, setSelectedNote] = useState<string | null>(null)
  const [editContent, setEditContent] = useState('')
  const [editTitle, setEditTitle] = useState('')

  const activeNote = state.notes.find(n => n.id === selectedNote)

  const createNote = () => {
    const id = `note-${Date.now()}`
    const note = {
      id,
      title: 'Nieuwe notitie',
      content: '',
      updatedAt: Date.now(),
    }
    dispatch({ type: 'ADD_NOTE', payload: note })
    setSelectedNote(id)
    setEditTitle(note.title)
    setEditContent(note.content)
  }

  const saveNote = () => {
    if (selectedNote) {
      dispatch({
        type: 'UPDATE_NOTE',
        payload: {
          id: selectedNote,
          title: editTitle,
          content: editContent,
          updatedAt: Date.now(),
        },
      })
    }
  }

  const deleteNote = (id: string) => {
    dispatch({ type: 'DELETE_NOTE', payload: id })
    if (selectedNote === id) {
      setSelectedNote(null)
    }
  }

  return (
    <div className="space-y-6">
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={springs.smooth}
        className="flex items-center justify-between"
      >
        <div>
          <span className="text-[11px] uppercase tracking-[0.15em] font-semibold text-[#8b8bf5] mb-1 block">
            Notities
          </span>
          <h1 className="text-3xl font-extrabold tracking-tight text-[#e8e8ea]">
            Jouw notities
          </h1>
        </div>

        <GlassButton variant="accent" size="sm" icon={<Plus size={16} />} onClick={createNote}>
          Nieuw
        </GlassButton>
      </motion.div>

      <div className="grid grid-cols-[280px_1fr] gap-4 min-h-[500px]">
        {/* Notes list */}
        <motion.div
          variants={staggerContainer}
          initial="initial"
          animate="enter"
          className="space-y-2"
        >
          {state.notes.length === 0 && (
            <GlassPanel className="p-6 text-center">
              <StickyNote size={24} className="text-[#4a4a52] mx-auto mb-2" />
              <p className="text-xs text-[#6e6e76]">Nog geen notities</p>
            </GlassPanel>
          )}

          {state.notes.map(note => (
            <motion.div key={note.id} variants={staggerItem}>
              <GlassPanel
                className={`p-4 cursor-pointer group ${
                  selectedNote === note.id ? 'border-[rgba(139,139,245,0.2)] bg-[rgba(139,139,245,0.05)]' : ''
                }`}
                hover
                onClick={() => {
                  setSelectedNote(note.id)
                  setEditTitle(note.title)
                  setEditContent(note.content)
                }}
              >
                <div className="flex items-start justify-between">
                  <div className="min-w-0 flex-1">
                    <h4 className="text-sm font-semibold text-[#e8e8ea] truncate">{note.title}</h4>
                    <p className="text-xs text-[#6e6e76] mt-1 truncate">
                      {note.content.slice(0, 60) || 'Lege notitie...'}
                    </p>
                  </div>
                  <button
                    onClick={e => { e.stopPropagation(); deleteNote(note.id) }}
                    className="text-[#4a4a52] hover:text-[#ef4444] transition-colors opacity-0 group-hover:opacity-100 p-1 cursor-pointer"
                  >
                    <Trash2 size={14} />
                  </button>
                </div>
              </GlassPanel>
            </motion.div>
          ))}
        </motion.div>

        {/* Editor / Preview */}
        {selectedNote ? (
          <GlassPanel className="p-6 flex flex-col">
            <input
              value={editTitle}
              onChange={e => setEditTitle(e.target.value)}
              onBlur={saveNote}
              className="bg-transparent text-xl font-bold text-[#e8e8ea] outline-none mb-4 border-b border-[rgba(255,255,255,0.04)] pb-3"
              placeholder="Titel..."
            />
            <div className="grid grid-cols-2 gap-4 flex-1 min-h-0">
              <textarea
                value={editContent}
                onChange={e => setEditContent(e.target.value)}
                onBlur={saveNote}
                className="bg-[rgba(255,255,255,0.02)] rounded-xl p-4 text-sm text-[#b4b4ba] font-mono resize-none outline-none border border-[rgba(255,255,255,0.04)] focus:border-[rgba(139,139,245,0.2)]"
                placeholder="Schrijf je notities in Markdown..."
              />
              <div className="bg-[rgba(255,255,255,0.01)] rounded-xl p-4 overflow-y-auto border border-[rgba(255,255,255,0.04)]">
                <div className="text-sm text-[#b4b4ba] prose-sm">
                  <ReactMarkdown remarkPlugins={[remarkGfm]}>{editContent || '*Begin met schrijven...*'}</ReactMarkdown>
                </div>
              </div>
            </div>
          </GlassPanel>
        ) : (
          <GlassPanel className="flex items-center justify-center">
            <div className="text-center">
              <StickyNote size={40} className="text-[#4a4a52] mx-auto mb-4" />
              <p className="text-sm text-[#6e6e76]">Selecteer of maak een notitie</p>
            </div>
          </GlassPanel>
        )}
      </div>
    </div>
  )
}
