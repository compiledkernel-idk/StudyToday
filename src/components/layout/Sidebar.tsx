// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useNavigate, useLocation } from 'react-router-dom'
import { springs } from '@/lib/motion'
import { cn } from '@/lib/utils'
import { useApp } from '@/lib/store'
import {
  Home,
  BookOpen,
  Search,
  Layers,
  StickyNote,
  Timer,
  Moon,
  Sun,
  Settings,
} from 'lucide-react'

const navItems = [
  { id: 'huis', icon: Home, label: 'Huis', path: '/' },
  { id: 'vakken', icon: BookOpen, label: 'Vakken', path: '/vakken' },
  { id: 'zoeken', icon: Search, label: 'Zoeken', path: '/zoeken' },
  { id: 'divider-1', divider: true },
  { id: 'flashcards', icon: Layers, label: 'Flashcards', path: '/flashcards' },
  { id: 'notities', icon: StickyNote, label: 'Notities', path: '/notities' },
  { id: 'timer', icon: Timer, label: 'Timer', path: '/timer' },
] as const

interface NavItem {
  id: string
  icon?: any
  label?: string
  path?: string
  divider?: boolean
}

export function Sidebar() {
  const [expanded, setExpanded] = useState(false)
  const [darkMode, setDarkMode] = useState(true)
  const navigate = useNavigate()
  const location = useLocation()
  const { state } = useApp()

  const isActive = (path: string) => {
    if (path === '/') return location.pathname === '/'
    return location.pathname.startsWith(path)
  }

  return (
    <motion.nav
      className={cn(
        'fixed left-3 top-3 bottom-3 z-50',
        'bg-[rgba(255,255,255,0.03)] backdrop-blur-[60px] saturate-[1.3]',
        'border border-[rgba(255,255,255,0.06)] rounded-2xl',
        'shadow-[0_8px_32px_rgba(0,0,0,0.2)]',
        'flex flex-col items-center py-4 overflow-hidden',
      )}
      initial={{ width: 72 }}
      animate={{ width: expanded ? 240 : 72 }}
      transition={springs.stiff}
      onMouseEnter={() => setExpanded(true)}
      onMouseLeave={() => setExpanded(false)}
    >
      {/* Inner highlight */}
      <div className="absolute top-0 left-4 right-4 h-px bg-gradient-to-r from-transparent via-[rgba(255,255,255,0.06)] to-transparent" />

      {/* Logo */}
      <motion.div
        className="flex items-center gap-3 px-5 mb-6 w-full cursor-pointer no-drag"
        onClick={() => navigate('/')}
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.98 }}
      >
        <div className="w-10 h-10 rounded-xl bg-[rgba(139,139,245,0.15)] border border-[rgba(139,139,245,0.2)] flex items-center justify-center flex-shrink-0">
          <span className="text-lg font-black text-[#8b8bf5]">S</span>
        </div>
        <AnimatePresence>
          {expanded && (
            <motion.span
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -10 }}
              transition={{ duration: 0.15 }}
              className="text-sm font-bold text-[#e8e8ea] whitespace-nowrap"
            >
              StudyToday
            </motion.span>
          )}
        </AnimatePresence>
      </motion.div>

      {/* Sync indicator */}
      <div className="px-5 mb-4 w-full">
        <div className="flex items-center gap-2">
          <div className={cn(
            'w-2 h-2 rounded-full flex-shrink-0',
            state.syncStatus === 'syncing' && 'bg-[#f59e0b] animate-pulse',
            state.syncStatus === 'done' && 'bg-[#10b981]',
            state.syncStatus === 'error' && 'bg-[#ef4444]',
            state.syncStatus === 'idle' && 'bg-[#6e6e76]',
          )} />
          <AnimatePresence>
            {expanded && (
              <motion.span
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                className="text-[11px] uppercase tracking-wider text-[#6e6e76] font-medium whitespace-nowrap"
              >
                {state.syncStatus === 'syncing' ? 'Synchroniseren...' :
                 state.syncStatus === 'done' ? 'Gesynchroniseerd' :
                 state.syncStatus === 'error' ? 'Sync fout' : 'Offline'}
              </motion.span>
            )}
          </AnimatePresence>
        </div>
      </div>

      {/* Nav items */}
      <div className="flex-1 w-full flex flex-col gap-1 px-3">
        {(navItems as readonly NavItem[]).map((item) => {
          if (item.divider) {
            return (
              <div key={item.id} className="my-2 mx-2 h-px bg-[rgba(255,255,255,0.04)]" />
            )
          }

          const Icon = item.icon!
          const active = isActive(item.path!)

          return (
            <motion.button
              key={item.id}
              onClick={() => navigate(item.path!)}
              className={cn(
                'relative flex items-center gap-3 w-full h-10 rounded-xl px-4',
                'transition-colors duration-200 cursor-pointer no-drag',
                active
                  ? 'text-[#e8e8ea]'
                  : 'text-[#6e6e76] hover:text-[#e8e8ea]',
              )}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              {/* Active background indicator */}
              {active && (
                <motion.div
                  layoutId="sidebar-active"
                  className="absolute inset-0 bg-[rgba(139,139,245,0.1)] border border-[rgba(139,139,245,0.15)] rounded-xl"
                  style={{ boxShadow: '0 0 20px rgba(139, 139, 245, 0.08)' }}
                  transition={springs.stiff}
                />
              )}

              <Icon size={20} strokeWidth={2} className="flex-shrink-0 relative z-10" />

              <AnimatePresence>
                {expanded && (
                  <motion.span
                    initial={{ opacity: 0, x: -10 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: -10 }}
                    transition={{ duration: 0.15 }}
                    className="text-sm font-medium whitespace-nowrap relative z-10"
                  >
                    {item.label}
                  </motion.span>
                )}
              </AnimatePresence>
            </motion.button>
          )
        })}
      </div>

      {/* Bottom actions */}
      <div className="w-full px-3 flex flex-col gap-1">
        <div className="my-2 mx-2 h-px bg-[rgba(255,255,255,0.04)]" />

        <motion.button
          onClick={() => setDarkMode(!darkMode)}
          className="flex items-center gap-3 w-full h-10 rounded-xl px-4 text-[#6e6e76] hover:text-[#e8e8ea] transition-colors cursor-pointer no-drag"
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
        >
          {darkMode ? <Moon size={20} strokeWidth={2} className="flex-shrink-0" /> : <Sun size={20} strokeWidth={2} className="flex-shrink-0" />}
          <AnimatePresence>
            {expanded && (
              <motion.span
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -10 }}
                transition={{ duration: 0.15 }}
                className="text-sm font-medium whitespace-nowrap"
              >
                {darkMode ? 'Donker' : 'Licht'}
              </motion.span>
            )}
          </AnimatePresence>
        </motion.button>

        <motion.button
          onClick={() => navigate('/instellingen')}
          className={cn(
            'flex items-center gap-3 w-full h-10 rounded-xl px-4',
            'text-[#6e6e76] hover:text-[#e8e8ea] transition-colors cursor-pointer no-drag',
          )}
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
        >
          <Settings size={20} strokeWidth={2} className="flex-shrink-0" />
          <AnimatePresence>
            {expanded && (
              <motion.span
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -10 }}
                transition={{ duration: 0.15 }}
                className="text-sm font-medium whitespace-nowrap"
              >
                Instellingen
              </motion.span>
            )}
          </AnimatePresence>
        </motion.button>
      </div>
    </motion.nav>
  )
}
